//
//  Database.swift
//  WPI_CSA
//
//  Created by NingFangming on 3/21/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

class Database {
    
    private let dbPointer: OpaquePointer
    
    private init(dbPointer: OpaquePointer) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func connect() throws -> Database {
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let dbPath = doumentDirectoryPath.appendingPathComponent("Database.sqlite")
        
        var db: OpaquePointer? = nil
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK {
            return Database(dbPointer: db!)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            let message = String(cString : sqlite3_errmsg(db))
            if !message.isEmpty {
                throw SQLiteError.OpenDatabase(message: message)//TODO: Exception or friendly error msg?
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    func getSubMenus(by menuId: Int, withPrefix prefix: String) -> [Menu]{
        var query: String
        var queryStatement: OpaquePointer? = nil
        var menuList = [Menu]()
        
        if menuId == 0 {
            query = "SELECT ID, TITLE FROM ARTICLES WHERE PARENT_ID IS NULL ORDER BY POSITION ASC"
        }else{
            query = "SELECT ID, TITLE FROM ARTICLES WHERE PARENT_ID = \(menuId) ORDER BY POSITION ASC"
        }
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                var name = String(cString: sqlite3_column_text(queryStatement, 1)!) //Not null column
                name = prefix + name
                let menu = Menu(id: Int(id), name: name)
                
                menu.subMenus = self.getSubMenus(by: Int(id), withPrefix: prefix + "   ")
                menu.isParentMenu = menu.subMenus.count > 0
                if !menu.isParentMenu {
                    Utils.menuOrderList.append(Int(id))
                }
                menuList.append(menu)
            }
        }else{
            print("query cannot be prepared")
        }
        sqlite3_finalize(queryStatement)
        return menuList
    }
    
    func searchArticles(withKeyword keyword: String) -> [Menu] {
        let query = "SELECT ID, NAME FROM MENUS WHERE NAME LIKE '%\(keyword)%' UNION SELECT ID, NAME FROM MENUS WHERE ID IN (SELECT MENU_ID FROM ARTICLES WHERE TITLE LIKE '%\(keyword)%' OR CONTENT LIKE '%\(keyword)%')"
        var queryStatement: OpaquePointer? = nil
        var menuList = [Menu]()
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(cString: sqlite3_column_text(queryStatement, 1)!) //Not null column
                menuList.append(Menu(id: Int(id), name: name))
            }
        }else{
            print("query cannot be prepared")
        }
        sqlite3_finalize(queryStatement)
        return menuList
    }
    
    func getMenuTitle(byMenuId menuId: Int) -> String{
        let query = "SELECT TITLE FROM ARTICLES WHERE ID = \(menuId)"
        var queryStatement: OpaquePointer? = nil
        var name = ""
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                name = String(cString: sqlite3_column_text(queryStatement, 0)) //Not null column
            }else{
                print("Article not found")
            }
        }else{
            print("query cannot be prepared")
        }
        sqlite3_finalize(queryStatement)
        return name
    }
    
    func getArticle(byMenuId menuId: Int) -> Article{
        let query = "SELECT CONTENT FROM ARTICLES WHERE ID = \(menuId)"
        var queryStatement: OpaquePointer? = nil
        var article: Article
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let content = String(cString: sqlite3_column_text(queryStatement, 0))
                article = Article(content: content)
            }else{
                print("Article not found")
                article = Article(content: "")
            }
        }else{
            print("query cannot be prepared")
            article = Article(content: "")
        }
        sqlite3_finalize(queryStatement)
        article.menuId = menuId
        if let index = Utils.menuOrderList.index(of: menuId) {
            if index != Utils.menuOrderList.count - 1 {
                article.nextMenuId = Utils.menuOrderList[index + 1] //TODO: Check for index?
                article.nextMenuText = getMenuTitle(byMenuId: Utils.menuOrderList[index + 1])
            }
            if index != 0 {
                article.prevMenuId = Utils.menuOrderList[index - 1] //TODO: Check for index?
                article.prevMenuText = getMenuTitle(byMenuId: Utils.menuOrderList[index - 1])
            }
            
        }
        return article
    }
    
    open class func localDirInitiateSetup() {
        let fileManager = FileManager.default
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        // Copy database file to document folder. Replace it if the file already exists
        let dbDestinationPath = documentDirectoryPath.appendingPathComponent("Database.sqlite")
        if fileManager.fileExists(atPath: dbDestinationPath){
            do{
                try fileManager.removeItem(atPath: dbDestinationPath)
            }catch let error {
                print(error.localizedDescription)
            }
        }
        do{
            try fileManager.copyItem(atPath: Bundle.main.path(forResource: "Database",
                                                              ofType: "sqlite")!,
                                     toPath: dbDestinationPath)
        }catch let error as NSError {
            print("error occurred, here are the details:\n \(error)")
        }
        
        /* DB 2.0 Migration code starts */
        let legacyDBPath = documentDirectoryPath.appendingPathComponent("SG.sqlite")
        if fileManager.fileExists(atPath: legacyDBPath){
            do{
                try fileManager.removeItem(atPath: legacyDBPath)
            }catch let error {
                print(error.localizedDescription)
            }
        }
        /* DB 2.0 Migration code ends */
        
        // Creating image cache folder
        let imageCacheDir = documentDirectoryPath.appendingPathComponent("imageCache")
        do {
            if !fileManager.fileExists(atPath: imageCacheDir) {
                try fileManager.createDirectory(atPath: imageCacheDir,
                                                withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        /*let pdfCacheDir = documentDirectoryPath.appendingPathComponent("pdfCache")
        do {
            if !fileManager.fileExists(atPath: pdfCacheDir) {
                try fileManager.createDirectory(atPath: pdfCacheDir,
                                                withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error {
            print(error.localizedDescription)
        }*/
        
        // Exclude files or directories from icloud backup
        var dbPathUrl = URL(fileURLWithPath: dbDestinationPath)
        var imgCachePathUrl = URL(fileURLWithPath: imageCacheDir)
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try dbPathUrl.setResourceValues(resourceValues)
            try imgCachePathUrl.setResourceValues(resourceValues)
            
        } catch let error{
            print(error.localizedDescription)
        }
    }
    
    open class func migrationToVersion2() {
        //let fileManager = FileManager.default
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        
        let img = UIImage(named: "1_2.jpg")
        let imgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("1.jpg"))
        
        do{
            try UIImageJPEGRepresentation(img!, 1.0)?.write(to: imgPath, options: .atomic)
        }catch let error{
            print(error.localizedDescription)
        }
    }
    /*
    open class func getParam(named key: String) ->String? {
        do{
            let db = try Database.connect()
            
            let query = "SELECT VALUE FROM PARAMS WHERE KEY = '\(key)'"
            var queryStatement: OpaquePointer? = nil
            var value: String?
            
            if sqlite3_prepare_v2(db.dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    value = String(cString: sqlite3_column_text(queryStatement, 0))
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
            
            return value
        }catch{
            return nil
        }
    }
    
    open class func setParam(named key:String, withValue value:String) {
        do{
            let db = try Database.connect()
            let processedValue = value.replacingOccurrences(of: "'", with: "''")
            let query = "INSERT OR REPLACE INTO PARAMS VALUES ('\(key)', '\(processedValue)')"
            var queryStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db.dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) != SQLITE_DONE {
                    print("Cannot update param \(key) with value \(value)")
                }
            } else {
                print("INSERT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }catch {}
    }
    
    open class func deleteParam(named key:String) {
        do{
            let db = try Database.connect()
            
            let query = "DELETE FROM PARAMS WHERE KEY = '\(key)'"
            var queryStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db.dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) != SQLITE_DONE {
                    print("Cannot delete param \(key)")
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }catch {}
    }
    */
    open class func run(queries: String){
        do{
            let db = try Database.connect()
            
            var errMsg: UnsafeMutablePointer<Int8>? = nil
            
            if sqlite3_exec(db.dbPointer, queries, nil, nil, &errMsg) != SQLITE_OK {
                print("Cannot execute query")//TODO: Do somethere here
                if let errMsg = errMsg {
                    print(String(cString: errMsg))
                }
            }else{
                print("Query is successfully executed")
            }
        }catch {}
    }
    
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

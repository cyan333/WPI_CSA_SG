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
        let query = "SELECT ID, TITLE FROM ARTICLES WHERE CONTENT LIKE '%\(keyword)%'"
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
    
        
    open class func getCache(type: CacheType, mappingId id: Int = 0) -> Cache? {
        var cache: Cache?
        do{
            let db = try Database.connect()
            var query = "SELECT ID, NAME, MAPPING_ID, VALUE FROM CACHE "
            
            switch type {
            case .Image, .PDF:
                query += "WHERE TYPE = '\(type.rawValue)' AND MAPPING_ID = \(id)"
                break
            default:
                break
            }
            
            var queryStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db.dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    let cacheId = Int(sqlite3_column_int(queryStatement, 0))
                    var name = ""
                    if let nameChar = sqlite3_column_text(queryStatement, 1) {
                        name = String(cString: nameChar)
                    }
                    let mappingId = Int(sqlite3_column_int(queryStatement, 2))
                    var value = ""
                    if let valueChar = sqlite3_column_text(queryStatement, 3) {
                        value = String(cString: valueChar)
                    }
                    
                    cache = Cache(id: cacheId, name: name, type: type, mappingId: mappingId, value: value)
                }
            } else {
                print("query cannot be prepared")
            }
            sqlite3_finalize(queryStatement)
            
            return cache
        }catch{
            return nil
        }
    }
    
    open class func createCache(type: CacheType, name: String? = nil, mappingId: Int? = nil, value: String? = nil) {
        var query = "INSERT INTO CACHE (NAME, TYPE, MAPPING_ID, VALUE) VALUES ("
        query += name == nil ? "null" : "'\(name!)'"
        query += ", '\(type.rawValue)', "
        query += mappingId == nil ? "null" : "\(mappingId!)"
        query += ", "
        query += value == nil ? "null)" : "'\(value!)')"
        run(queries: query)
    }
    
    open class func deleteCache(id: Int) {
        run(queries: "DELETE FROM CACHE WHERE ID = \(id)")
    }
    
    open class func imageHit(id: Int) {
        run(queries: "UPDATE CACHE SET VALUE = VALUE + 1 WHERE TYPE = 'Image' AND MAPPING_ID = \(id)")
    }
    
    open class func getImgHit(id: Int) {
        do{
            let db = try Database.connect()
            let query = "select value from cache where type = 'Image' and mapping_id = \(id)"
            var queryStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db.dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    let hit = Int(sqlite3_column_int(queryStatement, 0))
                    print("Current image hit \(hit)")
                }
            } else {
                print("INSERT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }catch {}
    }
    
    /*
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

//
//  SGDatabase.swift
//  WPI_SG
//
//  Created by NingFangming on 3/21/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

class SGDatabase {
    private let dbPointer: OpaquePointer
    
    private init(dbPointer: OpaquePointer) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        //print("DB disconnected")
        sqlite3_close(dbPointer)
    }
    
    static func connect() throws -> SGDatabase {
        let fileManger = FileManager.default
        var doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let dbPath = doumentDirectoryPath.appendingPathComponent("SG.sqlite")
        if !fileManger.fileExists(atPath: dbPath){
            let path = Bundle.main.path(forResource: "SG", ofType: "sqlite")
            do{
                try fileManger.copyItem(atPath: path!, toPath: dbPath)
            }catch let error as NSError {
                print("error occurred, here are the details:\n \(error)")
            }
            var dbPathUrl = URL(fileURLWithPath: dbPath)
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try dbPathUrl.setResourceValues(resourceValues)
                
            } catch { print("failed to set resource value") }
            
            /*do {
                let a = try dbPathUrl.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup
                if(a)!{
                    print("excluded!")
                }else{
                    print("Not excluded!")
                }
            } catch {}*/
        }
        
        
        var db: OpaquePointer? = nil
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK {
            return SGDatabase(dbPointer: db!)
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
    
    func getSubMenusById(menuId: Int, prefix: String) -> [Menu]{
        var query: String
        var queryStatement: OpaquePointer? = nil
        var menuList = [Menu]()
        
        if menuId == 0 {
            query = "SELECT ID, NAME FROM MENUS WHERE PARENT_ID IS NULL ORDER BY POSITION ASC"
        }else{
            query = "SELECT ID, NAME FROM MENUS WHERE PARENT_ID = \(menuId) ORDER BY POSITION ASC"
        }
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                var name = String(cString: sqlite3_column_text(queryStatement, 1)!) //Not null column
                name = prefix + name
                let menu = Menu(id: Int(id), name: name)
                menu.subMenus = self.getSubMenusById(menuId: Int(id), prefix: prefix + "   ")
                menu.isParentMenu = menu.subMenus.count > 0
                menuList.append(menu)
            }
        }else{
            print("query cannot be prepared")
        }
        sqlite3_finalize(queryStatement)
        return menuList
    }
    
    func searchArticles(keyword: String) -> [Menu] {
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
    
    func getArticleByMenuId(menuId: Int) -> Article{
        let query = "SELECT TITLE, CONTENT FROM ARTICLES WHERE MENU_ID = \(menuId)"
        var queryStatement: OpaquePointer? = nil
        var article: Article
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(queryStatement, 0)!) //Not null column
                //let title = "<span style=\"font-weight:bold;font-size:50px;color:grey;\">关于我们</span>"
                let content = String(cString: sqlite3_column_text(queryStatement, 1)!) //Not null column
                article = Article(title: title, content: content)
            }else{
                print("query return 0 row")
                article = Article(content: "")
            }
        }else{
            print("query cannot be prepared")
            article = Article(content: "")
        }
        sqlite3_finalize(queryStatement)
        article.menuId = menuId
        return article
    }
    
    func printBtnList(query: String){
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbPointer, "select ID, NAME  from menus ORDER BY ID ASC",
                              -1, &queryStatement, nil) == SQLITE_OK {
            /*
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                // 3
                let id = sqlite3_column_int(queryStatement, 0)
                
                // 4
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let name = String(cString: queryResultCol1!)
                
                // 5
                print("Query Result:")
                print("\(id) | \(name)")
                
            } else {
                print("Query returned no results")
            }*/
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let name = String(cString: queryResultCol1!)
                /*let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                var position : String
                if(queryResultCol2 == nil){
                    position = "null"
                }else{
                    position = String(cString: queryResultCol2!)
                }*/
                print("<button type=\"button\" class=\"list-group-item list-group-item-action\" onclick=\"getArticle(\(id))\">\(name)</button>")
            }
            
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    
    
    func createTable() {
        let createTableString = "CREATE TABLE Contact(" +
            "Id INT PRIMARY KEY NOT NULL," +
        "Name CHAR(255));"
        
        // 1
        var createTableStatement: OpaquePointer? = nil
        // 2
        if sqlite3_prepare_v2(dbPointer, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            // 3
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Contact table created.")
            } else {
                print("Contact table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        // 4
        sqlite3_finalize(createTableStatement)
    }
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

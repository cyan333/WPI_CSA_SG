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
        sqlite3_close(dbPointer)
    }
    
    static func connect() throws -> SGDatabase {
        var db: OpaquePointer? = nil
        let path = Bundle.main.path(forResource: "SG", ofType: "sqlite")
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SGDatabase(dbPointer: db!)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            let message = String(cString : sqlite3_errmsg(db))
            if !message.isEmpty {
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    func run(query: String){
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbPointer, "SELECT * FROM MENUS ",
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
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                var position : String
                if(queryResultCol2 == nil){
                    position = "null"
                }else{
                    position = String(cString: queryResultCol2!)
                }
                print("\(id) | \(name) | \(position)")
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

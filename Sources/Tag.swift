//
//  Tag.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 22/03/17.
//
//

import Foundation
import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectLib

public class Tag : PostgresStORM {
    
    /// Unique ID
    public var uniqueID: String = ""
    
    ///
    public var feedID: String = ""
    
    ///
    public var tag: String = ""
    
    /// Date created
    public var count: Int = 0
    
    /// Date created
    public var createdDate: Int = 0
    
    /// The table to store the data
    override open func table() -> String {
        return "tags"
    }
    
    public override init() {
        super.init()
        self.createdDate = now()
        let rand = URandom()
        let uniqueId = rand.secureToken
        self.uniqueID = uniqueId
    }
    
    private func now() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
    /// Set incoming data from database to object
    override open func to(_ this: StORMRow) {
        uniqueID    = this.data["uniqueid"] as? String ?? ""
        feedID      = this.data["feedid"] as? String ?? ""
        tag         = this.data["tag"] as? String ?? ""
        count       = this.data["count"] as? Int ?? 0
        createdDate = this.data["createddate"] as? Int ?? now()
    }
    
    func getJSONValues() -> [String : Any] {
        return [
            "tag"       :tag,
            "count"     :count
        ]
    }

    
    /// Iterate through rows and set to object data
    public func rows() -> [Tag] {
        var rows = [Tag]()
        for i in 0..<self.results.rows.count {
            let row = Tag()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    open func topTags() throws -> [Tag] {
        let cursor = StORMCursor(limit: 20, offset: 0)
        do {
            let paramsString = [String]()
            var query = "SELECT tag, COUNT(*) AS count FROM  tags GROUP BY tag order by count desc"
            
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rows()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func searchTags(_ searchText: String) throws -> [Tag] {
        let cursor = StORMCursor(limit: 20, offset: 0)
        do {
            var paramsString = [String]()
            var query = "SELECT tag FROM tags where lower(tag) like $1 GROUP BY tag"
            paramsString = ["%\(searchText)%"]
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rows()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
}

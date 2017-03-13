//
//  Favourite.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 08/03/17.
//
//

import Foundation
import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectLib

public class Favourite: PostgresStORM {
    
    /// Unique ID
    public var uniqueID: String = ""
    
    /// 
    public var feedID: String = ""
    
    ///
    public var userID: String = ""
    
    /// Date created
    public var createdDate: Int = 0
    
    /// The table to store the data
    override open func table() -> String {
        return "favourite"
    }
    
    public override init() {
        super.init()
        self.createdDate = now()
    }
    
    private func now() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }

    
    /// Set incoming data from database to object
    override open func to(_ this: StORMRow) {
        uniqueID	= this.data["uniqueid"] as? String ?? ""
        userID      = this.data["userid"] as? String ?? ""
        feedID      = this.data["feedid"] as? String ?? ""
        createdDate = this.data["createddate"] as? Int ?? now()
    }
    
    /// Iterate through rows and set to object data
    public func rows() -> [Feed] {
        var rows = [Feed]()
        for i in 0..<self.results.rows.count {
            let row = Feed()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    open func getFav(feedID: String, userID: String) throws -> Favourite {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "feedid = $1 and userid=$2", params: [feedID, userID], orderby: [], cursor: cursor)
            if self.results.rows.count == 0 {
                throw StORMError.noRecordFound
            }
            to(self.results.rows[0])
            return self
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }

    }
}

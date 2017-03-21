//
//  Follow.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 10/03/17.
//
//

import Foundation
import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectLib

public class Follow: PostgresStORM {
    /// Unique ID
    public var uniqueID: String = ""
    
    ///
    public var followID: String = ""
    
    ///follower id/ created user id
    public var userID: String = ""
    
    /// Date created
    public var createdDate: Int = 0
    
    /// The table to store the data
    override open func table() -> String {
        return "follow"
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
        uniqueID	= this.data["uniqueid"] as? String ?? ""
        userID      = this.data["userid"] as? String ?? ""
        followID    = this.data["followid"] as? String ?? ""
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
    
    open func isFollowing(checkUserID: String, userID: String) throws -> Bool {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "followid = $1 and userid=$2", params: [checkUserID, userID], orderby: [], cursor: cursor)
            if self.results.rows.count == 0 {
                return false
            }
            to(self.results.rows[0])
            return true
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
        
    }
    
    open func followersCount(userID: String) throws -> Int {
        let cursor = StORMCursor(limit: 9999999, offset: 0)
        do {
            try select(whereclause: "followid = $1", params: [userID], orderby: [], cursor: cursor)
            return self.results.rows.count
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func followingCount(userID: String) throws -> Int {
        let cursor = StORMCursor(limit: 9999999, offset: 0)
        do {
            try select(whereclause: "userid = $1", params: [userID], orderby: [], cursor: cursor)
            return self.results.rows.count
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
}

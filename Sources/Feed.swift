//
//  Feed.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 07/03/17.
//
//

import Foundation
import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectLib

public class Feed: PostgresStORM {
    
    static let registerName = "feed"
    
    /// The Feed's Unique ID
    public var uniqueID: String = ""
    
    /// Unique ID of Feed owner
    public var userID: String = ""
    
    /// Feed status
    public var status: String = ""
    
    /// Date created
    public var createdDate: Int = 0
    
    /// Location of created Feed
    public var location: String = ""
    
    ///
    public var imageUrl: String {
        get {
            return "/files/feeds/" + uniqueID
        }
    }
    
    private var _owner: User =  User()
    
    private var _isFav: Bool = false
    
    /// The table to store the data
    override open func table() -> String {
        return "feeds"
    }
    
    public override init() {
        super.init()
        self.createdDate = now()
    }
    
    private func now() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
    func getJSONValues() -> [String : Any] {
        return [
            "uniqueID":uniqueID,
            "userID":userID,
            "status":status,
            "createdDate":createdDate,
            "location":location,
            "imageUrl":imageUrl,
            "isFav": _isFav,
            "owner": [
                "uniqueID" : _owner.uniqueID,
                "firstname" : _owner.firstname,
                "lastname" : _owner.lastname,
                "profileimage" : _owner.profileImageUrl
            ]
        ]
    }
    
    /// Set incoming data from database to object
    override open func to(_ this: StORMRow) {
        uniqueID	= this.data["uniqueid"] as? String ?? ""
        userID      = this.data["userid"] as? String ?? ""
        status      = this.data["status"] as? String ?? ""
        createdDate = this.data["createddate"] as? Int ?? now()
        location    = this.data["location"] as? String ?? ""
    }
    
    /// Set incoming data from database to object
    private func toWithRelation(_ this: StORMRow) {
        uniqueID	= this.data["uniqueid"] as? String ?? ""
        userID      = this.data["userid"] as? String ?? ""
        status      = this.data["status"] as? String ?? ""
        createdDate = this.data["createddate"] as? Int ?? now()
        location    = this.data["location"] as? String ?? ""
        _owner.uniqueID      = this.data["userid"] as? String ?? ""
        _owner.firstname     = this.data["firstname"] as? String ?? ""
        _owner.lastname      = this.data["lastname"] as? String ?? ""
        _owner.profileimage  = this.data["profileimage"] as? String ?? ""
        let favStatus = this.data["isfav"] as? String ?? ""
        if (favStatus.characters.count > 0) {
            _isFav = true
        } else {
            _isFav = false
        }
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
    
    private func rowsWithRelation() -> [Feed] {
        var rows = [Feed]()
        for i in 0..<self.results.rows.count {
            let row = Feed()
            row.toWithRelation(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    /// Performs a find on supplied username, and matches hashed password
    open func get(user: String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            try select(whereclause: "userid = $1", params: [user], orderby: ["createddate", "DESC"], cursor: cursor)
            if self.results.rows.count == 0 {
                throw StORMError.noRecordFound
            }
            return rows()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
        
        
    }
    
    open func allFeeds(_ user: String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            try select(whereclause: "userid = $1", params: [user], orderby: ["createddate"], cursor: cursor)
            if self.results.rows.count == 0 {
                throw StORMError.noRecordFound
            }
            return rows()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func myFeeds(_ user: String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            let paramsString = [user, user]
            var query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid and f.userid=$1  left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$2 order by createddate DESC"
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rowsWithRelation()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func userFeeds(_ user: String, requestUser: String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            let paramsString = [requestUser, user]
            var query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid   left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$1 where f.userid=$2 order by createddate DESC"
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rowsWithRelation()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func allFeedWithOwner(_ user: String, requestUser: String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            var paramsString = [String]()
//            var query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$1 order by createddate DESC"
            var query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid inner join follow as fol on f.userid=fol.followid and fol.userid=$1 left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$2 order by createddate DESC"
            
            paramsString = [requestUser, requestUser]
            if (user.characters.count > 0) {
//                query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid   left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$1 where f.userid=$2 order by createddate DESC"
                query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid and f.userid=$1 inner join follow as fol on f.userid=fol.followid and fol.userid=$2 left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$3 order by createddate DESC"
                paramsString = [user, requestUser, requestUser]
            }
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rowsWithRelation()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func allFavoriteFeedsOfOwner(_ user: String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            var paramsString = [String]()
            var query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid inner join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$1 order by createddate DESC"
            paramsString = [user]
            
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rowsWithRelation()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
    
    open func feedsOfTag(_ tag: String, user:String) throws -> [Feed] {
        let cursor = StORMCursor(limit: 100, offset: 0)
        do {
            var paramsString = [String]()
            var query = "select f.uniqueid, f.userid, f.status, f.createddate, f.location, u.firstname, u.lastname, u.profileimage, fav.uniqueid as isFav from feeds as f inner join users as u on f.userid=u.uniqueid inner join tags as t on f.uniqueid=t.feedid and t.tag=$1 left join favourite as fav on f.uniqueid=fav.feedid and fav.userid=$2  order by createddate DESC"
            paramsString = [tag, user]
            
            if cursor.limit > 0 {
                query += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                query += " OFFSET \(cursor.offset)"
            }
            try executeQuery(query: query, paramsString: paramsString)
            return rowsWithRelation()
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
    }
}

extension PostgresStORM {
    
    public func executeQuery(query: String, paramsString: [String]) throws {
        do {
            // save results into ResultSet
            self.results.rows = try execRows(query, params: paramsString)
        } catch {
            throw StORMError.error("\(error)")
        }
    }
}

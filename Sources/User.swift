//
//  User.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 23/02/17.
//
//

import Foundation
import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectTurnstilePostgreSQL

public class User: PostgresStORM, Account {
    /// The User account's Unique ID
    public var uniqueID: String = ""
    
    /// The username with which the user will log in with
    public var username: String = ""
    
    /// The password to be set for the user
    public var password: String = ""
    
    /// Stored Facebook ID when logging in with Facebook
    public var facebookID: String = ""
    
    /// Stored Google ID when logging in with Google
    public var googleID: String = ""
    
    /// Optional first name
    public var firstname: String = ""
    
    /// Optional last name
    public var lastname: String = ""
    
    /// email
    public var email: String = ""
    
    /// Date of birth
    public var dob: Int = 0
    
    /// Gender 
    public var gender: String = ""
    
    /// Profile Image identifier
    public var profileimage: String = ""
    
    public var profileImageUrl: String {
        get {
            return "/files/profile/" + profileimage
        }
    }
    
    /// Internal container variable for the current Token object
    public var internal_token: AccessTokenStore = AccessTokenStore()
    
    /// The table to store the data
    override open func table() -> String {
        return "users"
    }
    
    private func now() -> Int {
        return Int(Date.timeIntervalSinceReferenceDate)
    }
    
    /// Shortcut to store the id
    public func id(_ newid: String) {
        uniqueID = newid
    }
    
    /// Set incoming data from database to object
    override open func to(_ this: StORMRow) {
        uniqueID	= this.data["uniqueid"] as? String ?? ""
        username	= this.data["username"] as? String ?? ""
        password	= this.data["password"] as? String ?? ""
        facebookID	= this.data["facebookid"] as? String ?? ""
        googleID	= this.data["googleid"] as? String ?? ""
        firstname	= this.data["firstname"] as? String ?? ""
        lastname	= this.data["lastname"] as? String ?? ""
        email		= this.data["email"] as? String ?? ""
        dob         = this.data["dob"] as? Int ?? now()
        gender      = this.data["gender"] as? String ?? ""
        profileimage = this.data["profileimage"] as? String ?? ""
    }
    
    /// Iterate through rows and set to object data
    public func rows() -> [User] {
        var rows = [User]()
        for i in 0..<self.results.rows.count {
            let row = User()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    /// Forces a create with a hashed password
    public func make() throws {
        do {
            password = BCrypt.hash(password: password)
            try create() // can't use save as the id is populated
        } catch {
            print(error)
        }
    }
    
    /// Performs a find on supplied username, and matches hashed password
    open func get(_ un: String, _ pw: String) throws -> User {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "username = $1", params: [un], orderby: [], cursor: cursor)
            if self.results.rows.count == 0 {
                throw StORMError.noRecordFound
            }
            to(self.results.rows[0])
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
        if try BCrypt.verify(password: pw, matchesHash: password) {
            return self
        } else {
            throw StORMError.noRecordFound
        }
        
    }
    
    open func getAccount(_ accountID: String) throws -> User {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "uniqueid = $1", params: [accountID], orderby: [], cursor: cursor)
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
    
    /// Returns a true / false depending on if the username exits in the database.
    func exists(_ un: String) -> Bool {
        do {
            try select(whereclause: "username = $1", params: [un], orderby: [], cursor: StORMCursor(limit: 1, offset: 0))
            if results.rows.count == 1 {
                return true
            } else {
                return false
            }
        } catch {
            print("Exists error: \(error)")
            return false
        }
    }
}

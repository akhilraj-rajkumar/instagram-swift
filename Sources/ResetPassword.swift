//
//  ResetPassword.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 20/03/17.
//
//

import Foundation
import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectLib

public class ResetPassword: PostgresStORM {
    /// Unique ID
    public var uniqueID: String = ""
    
    ///
    public var resetPasswordID: String = ""
    
    ///
    public var userEmail: String = ""
    
    /// Date created
    public var createdDate: Int = 0
    
    /// The table to store the data
    override open func table() -> String {
        return "resetpassword"
    }
    
    public override init() {
        super.init()
        self.createdDate = now()
        var rand = URandom()
        let uniqueId = rand.secureToken
        self.uniqueID = uniqueId
        rand = URandom()
        let passwordId = rand.secureToken
        self.resetPasswordID = passwordId
    }
    
    private func now() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
    /// Set incoming data from database to object
    override open func to(_ this: StORMRow) {
        uniqueID            = this.data["uniqueid"] as? String ?? ""
        userEmail           = this.data["useremail"] as? String ?? ""
        resetPasswordID     = this.data["resetpasswordid"] as? String ?? ""
        createdDate         = this.data["createddate"] as? Int ?? now()
    }
    
    /// Iterate through rows and set to object data
    public func rows() -> [ResetPassword] {
        var rows = [ResetPassword]()
        for i in 0..<self.results.rows.count {
            let row = ResetPassword()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }

    open func isResetIdValid(_ resetId: String) -> Bool {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "resetpasswordid = $1", params: [resetId], orderby: [], cursor: cursor)
            if self.results.rows.count == 0 {
                return false
            }
            to(self.results.rows[0])
            let now = self.now()
            let validity = 60 * 60
            if (now < self.createdDate + validity) {
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    open func requestWithID(_ resetId: String) throws -> ResetPassword {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "resetpasswordid = $1", params: [resetId], orderby: [], cursor: cursor)
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

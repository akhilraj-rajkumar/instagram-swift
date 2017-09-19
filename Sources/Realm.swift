//
//  Realm.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 23/02/17.
//
//

import Foundation
import Turnstile
import PerfectTurnstilePostgreSQL

public class LoginRealm: AuthRealm {
    
    /// Used when a "UsernamePassword" onject is passed to the authenticate function. Returns an Account object.
    open override func authenticate(credentials: UsernamePassword) throws -> Account {
        print("inside my auth")
        let account = User()
        do {
            let thisAccount = try account.get(credentials.username, credentials.password)
            print(thisAccount.uniqueID)
            return thisAccount
        } catch {
            throw IncorrectCredentialsError()
        }
    }
    
    /// Registers PasswordCredentials against the AuthRealm.
    open override func register(credentials: Credentials) throws -> Account {
        print("inside login realm")
        let account = User()
        let newAccount = User()
        newAccount.id(String(random.secureToken))
        
        switch credentials {
        case let credentials as UsernamePassword:
            do {
                if account.exists(credentials.username) {
                    throw AccountTakenError()
                }
                newAccount.username = credentials.username
                newAccount.password = credentials.password
                do {
                    try newAccount.make() // can't use save as the id is populated
                } catch {
                    print("REGISTER ERROR: \(error)")
                }
            } catch {
                throw AccountTakenError()
            }
            //		case let credentials as FacebookAccount:
            //			guard accounts.filter({$0.facebookID == credentials.uniqueID}).first == nil else {
            //				throw AccountTakenError()
            //			}
            //			newAccount.facebookID = credentials.uniqueID
            //		case let credentials as GoogleAccount:
            //			guard accounts.filter({$0.googleID == credentials.uniqueID}).first == nil else {
            //				throw AccountTakenError()
            //			}
        //			newAccount.googleID = credentials.uniqueID
        case let credentials as RegisterCredentials:
            do {
                if account.exists(credentials.username) {
                    throw AccountTakenError()
                }
                newAccount.username = credentials.username
                newAccount.password = credentials.password
                newAccount.firstname = credentials.firstname
                newAccount.lastname = credentials.lastname
                newAccount.email = credentials.email
                newAccount.dob = credentials.dob
                newAccount.gender = credentials.gender
                newAccount.profileimage = credentials.profileimage
                do {
                    try newAccount.make() // can't use save as the id is populated
                } catch {
                    print("REGISTER ERROR: \(error)")
                }
            } catch {
                throw AccountTakenError()
            }
            break
            
        default:
            throw UnsupportedCredentialsError()
        }
        return newAccount
    }
}

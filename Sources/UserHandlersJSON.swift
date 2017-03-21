//
//  UserHandlersJSON.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 10/03/17.
//
//

import Foundation
import PerfectLib
import PerfectHTTP

import TurnstilePerfect
import Turnstile
import TurnstileCrypto
import TurnstileWeb

public class UserHandlersJSON {
    
    open static func userDetailsPOST(request: HTTPRequest, _ response: HTTPResponse) {
        print("user details")
        var resp = [String: Any]()
        if (request.user.authenticated) {
            guard let userID = request.param(name: "userID") else {
                print("params not found")
                resp["error"] = "Missing parameters"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
            }
            
            var account = User()
            do {
                account = try account.getAccount(userID)
                let user = account.getJSONValues()
                
                resp["user"] = user
                resp["error"] = "none"
                print(resp)
            } catch {
                resp["error"] = "An unknown error occurred."
            }
            
            do {
                print("fetching follow details")
                let accountID = request.user.authDetails!.account.uniqueID
                let follower = Follow()
                let followerCount = try follower.followersCount(userID: userID)
                let following = Follow()
                let followingCount = try following.followingCount(userID: userID)
                let follow = Follow()
                let isFollowing = try follow.isFollowing(checkUserID: userID, userID: accountID)
                if var user = resp["user"] as? [String: Any] {
                    print("found user element")
                    user["followerCount"] = followerCount
                    user["followingCount"] = followingCount
                    user["isFollowing"] = isFollowing
                    resp["user"] = user
                }
            } catch {
                
            }
            
        } else {
            resp["error"] = "You must login to continue."
            
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func followHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        
        guard let userID = request.param(name: "userID") else {
            print("params not found")
            resp["error"] = "Missing parameters"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        var noError = false
        let accountID = request.user.authDetails!.account.uniqueID
        let follow = Follow()
        do {
            let isFollowing = try follow.isFollowing(checkUserID: userID, userID: accountID)
            if isFollowing {
                resp["error"] = "Already following"
            } else {
                follow.userID = accountID
                follow.followID = userID
                try follow.create()
            }
            resp["error"] = "none"
            noError = true
        } catch let e as TurnstileError {
            resp["error"] = e.description
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        do {
            if (noError) {
                let followers = try follow.followersCount(userID: userID)
                resp["followersCount"] = followers
            }
        } catch {
            
        }
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func unFollowHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        
        guard let userID = request.param(name: "userID") else {
            print("params not found")
            resp["error"] = "Missing parameters"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        var noError = false
        let accountID = request.user.authDetails!.account.uniqueID
        let follow = Follow()
        do {
            let isFollowing = try follow.isFollowing(checkUserID: userID, userID: accountID)
            if isFollowing {
                try follow.delete()
            } else {
                resp["error"] = "Not following this user"
            }
            resp["error"] = "none"
            noError = true
        } catch let e as TurnstileError {
            resp["error"] = e.description
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        do {
            if (noError) {
                let followers = Follow()
                let followersCount = try followers.followersCount(userID: userID)
                resp["followersCount"] = followersCount
            }
        } catch {
            
        }
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func recommendedUsersGET(request: HTTPRequest, _ response: HTTPResponse) {
        var resp = [String: Any]()
        if (request.user.authenticated) {
            
            let account = User()
            let accountID = request.user.authDetails!.account.uniqueID
            do {
                let users = try account.recommendedUsersForUser(accountID)
                var userList = [[String: Any]]()
                for user in users {
                    let values = user.getJSONValues()
                    userList.append(values)
                }
                
                resp["users"] = userList
                resp["error"] = "none"
                print(resp)
            } catch {
                resp["error"] = "An unknown error occurred."
            }
            
        } else {
            resp["error"] = "You must login to continue."
            
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    /// JSON Update Profile action (POST)
    open static func updateProfileHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: String]()
        print("our handler: \(request.headers) - \(request.postParams)")
        var encoded = request.postParams[0].1
        for param in request.postParams {
            if (param.0 == "model") {
                encoded = param.1
            }
        }
        
        var params: [String:Any]?
        do {
            guard let decoded = try encoded.jsonDecode() as? [String:Any] else {
                resp["error"] = "Parameters not in expected format"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
            }
            params = decoded
        } catch {
            print(error)
            resp["error"] = "Parameters not in expected format"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        // create uploads dir to store files
        let fileDir = Dir(Dir.workingDir.path + "webroot/files/profile")
        do {
            try fileDir.create()
        } catch {
            print(error)
        }
        
        guard let firstname = params!["firstname"]! as? String,
            let lastname = params!["lastname"]! as? String,
            let location = params!["location"]! as? String,
            let country = params!["country"]! as? String else {
                resp["error"] = "Missing required parameters for profile update"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        
        let rand = URandom()
        var filename = rand.secureToken
        // Grab the fileUploads array and see what's there
        // If this POST was not multi-part, then this array will be empty
        if let uploads = request.postFileUploads {
            print("uploads found")
            if uploads.count > 0 {
                
                let upload = uploads[0]
                
                // move file to webroot
                let thisFile = File(upload.tmpFileName)
                do {
                    let _ = try thisFile.moveTo(path: fileDir.path + filename, overWrite: true)
                    print("saved file")
                } catch {
                    filename = ""
                    print(error)
                }
                
            }
        } else {
            filename = ""
        }
        
        let accountID = request.user.authDetails!.account.uniqueID
        var account = User()
        do {
            account = try account.getAccount(accountID)
            var cols = ["firstname", "lastname", "location", "country"]
            var vals = [firstname, lastname, location, country]
            if filename.characters.count > 0 {
                cols.append("profileimage")
                vals.append(filename)
            }
            try account.update(cols: cols, params: vals, idName: "uniqueid", idValue: accountID)
            resp["error"] = "none"
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    
    open static func changePasswordHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        
        guard let currentPassword = request.param(name: "currentPassword"),
        let newPassword = request.param(name: "newPassword") else {
            print("params not found")
            resp["error"] = "Missing parameters"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        let accountID = request.user.authDetails!.account.uniqueID
        
        var account = User()
        do {
            account = try account.getAccount(accountID)
            if try BCrypt.verify(password: currentPassword, matchesHash: account.password) {
                let hashedNewPassword = BCrypt.hash(password: newPassword)
                let cols = ["password"]
                let vals = [hashedNewPassword]
                try account.update(cols: cols, params: vals, idName: "uniqueid", idValue: accountID)
                resp["error"] = "none"
            } else {
                resp["error"] = "Incorrect current password"
            }
            print(resp)
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func requestResetPasswordHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        
        guard let email = request.param(name: "email") else {
                print("params not found")
                resp["error"] = "Missing parameters"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        
        let account = User()
        do {
            let exist = account.exists(email)
            if exist {
                let reset = ResetPassword()
                reset.userEmail = email
                try reset.create()
                
                resp["error"] = "none"
            } else {
                resp["error"] = "Invalid email address"
            }
            print(resp)
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func validateResetRequestIdHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        guard let resetID = request.param(name: "resetID") else {
            print("params not found")
            resp["error"] = "Missing parameters"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        let reset = ResetPassword()
        let isValid = reset.isResetIdValid(resetID)
        if (isValid) {
            resp["error"] = "none"
        } else {
            resp["error"] = "Invalid or expired link"
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func resetPasswordHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        guard let resetID = request.param(name: "resetID"),
        let password = request.param(name: "password") else {
            print("params not found")
            resp["error"] = "Missing parameters"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        let reset = ResetPassword()
        do {
            let isValid = reset.isResetIdValid(resetID)
            if (isValid) {
                var resetRquest = ResetPassword()
                resetRquest = try resetRquest.requestWithID(resetID)
                var user = User()
                user = try user.getAccountByUsername(resetRquest.userEmail)
                let hashedNewPassword = BCrypt.hash(password: password)
                let cols = ["password"]
                let vals = [hashedNewPassword]
                try user.update(cols: cols, params: vals, idName: "uniqueid", idValue: user.uniqueID)
                resp["error"] = "none"
            } else {
                resp["error"] = "Invalid or expired link"
            }
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
}

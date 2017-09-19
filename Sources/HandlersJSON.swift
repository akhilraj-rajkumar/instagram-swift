//
//  HandlersJSON.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 13/02/17.
//
//

import Foundation
import PerfectLib
import PerfectHTTP

import TurnstilePerfect
import Turnstile
import TurnstileCrypto
import TurnstileWeb

//import SwiftRandom

import PerfectTurnstilePostgreSQL

/// public var that houses the Token object

public class HandlersJSON {
    
    /* =================================================================================================================
     Login
     ================================================================================================================= */
    /// JSON Login action (POST)
    open static func loginHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        print("my login")
        var resp = [String: String]()
        guard let username = request.param(name: "username"),
            let password = request.param(name: "password") else {
                print("username not found")
                resp["error"] = "Missing username or password"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        let credentials = UsernamePassword(username: username, password: password)
        print("got username and password")
        do {
            try request.user.login(credentials: credentials, persist:true)
            var token = ""
            if let val = request.user.authDetails?.sessionID {
                token = val
                print("session: \(token)")
            }
            if let val = tokenStore?.new((request.user.authDetails?.account.uniqueID)!){
                token = val
                print("token: \(token)")
            }
            
            resp["error"] = "none"
            resp["login"] = "ok"
            resp["token"] = token
        } catch {
            resp["error"] = "Invalid username or password"
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    /* =================================================================================================================
     Register
     ================================================================================================================= */
    /// JSON Register action (POST)
    open static func registerHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
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
        
        guard let email = params!["email"]! as? String,
            let password = params!["password"]! as? String,
            let firstname = params!["firstname"]! as? String,
            let lastname = params!["lastname"]! as? String,
            let dob = params!["dob"]! as? Int,
            let gender = params!["gender"]! as? String else {
                resp["error"] = "Missing required parameters for registration"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        if (!Utilities.isValidEmail(email: email)) {
            resp["error"] = "Email not valid"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        let location = params?["location"] as? String ?? ""
        let country = params?["country"] as? String ?? ""
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
                        filename = "profile-avtar.png"
                        print(error)
                    }
                
            }
        } else {
            filename = "profile-avtar.png"
        }
        
        print("creating reg credentials")
        let registercredentials = RegisterCredentials(firstname: firstname, lastname: lastname, email: email, password: password, dob: Int(dob) ?? 0, gender: gender, profileimage: filename, location: location, country: country)
        print("created reg credentials")
        let credentials = UsernamePassword(username: email, password: password)
        
        do {
            print("req for reg")
            try request.user.register(credentials: registercredentials)
            
            try request.user.login(credentials: credentials, persist:true)
            //register
            resp["error"] = "none"
            resp["login"] = "ok"
            resp["token"] = request.user.authDetails?.sessionID
        } catch let e as TurnstileError {
            resp["error"] = e.description
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
    
    open static func userDetailsGET(request: HTTPRequest, _ response: HTTPResponse) {
        print("me")
        var resp = [String: Any]()
        if (request.user.authenticated) {
            let accountID = request.user.authDetails!.account.uniqueID
            var account = User()
            do {
                account = try account.getAccount(accountID)
                let user = account.getJSONValues()
                resp["user"] = user
                resp["error"] = "none"
                print(resp)
            } catch {
                resp["error"] = "An unknown error occurred."
            }
            do {
                print("fetching follow details")
                let follower = Follow()
                let followerCount = try follower.followersCount(userID: accountID)
                let following = Follow()
                let followingCount = try following.followingCount(userID: accountID)
                if var user = resp["user"] as? [String: Any] {
                    print("found user element")
                    user["followerCount"] = followerCount
                    user["followingCount"] = followingCount
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
}

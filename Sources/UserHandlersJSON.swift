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
        
        let accountID = request.user.authDetails!.account.uniqueID
        let feed = Feed()
        do {
            let feedList:[Feed] = try feed.allFeedWithOwner(userID, requestUser: accountID)
            var outputList = [[String: Any]]()
            for feedItem in feedList {
                let converted = feedItem.getJSONValues()
                outputList.append(converted)
            }
            resp["error"] = "none"
            resp["feeds"] = outputList
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
}

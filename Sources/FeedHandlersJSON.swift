//
//  FeedHandlersJSON.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 07/03/17.
//
//

import Foundation
import PerfectLib
import PerfectHTTP

import TurnstilePerfect
import Turnstile
import TurnstileCrypto
import TurnstileWeb


public class FeedHandlersJSON {
    
    /// JSON Create feed action (POST)
    open static func createFeedHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
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
        let fileDir = Dir(Dir.workingDir.path + "webroot/files/feeds")
        do {
            try fileDir.create()
        } catch {
            print(error)
        }
        
        guard let status = params!["status"]! as? String,
            let location = params!["location"]! as? String else {
                resp["error"] = "Missing required parameters for registration"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        
        let rand = URandom()
        let filename = rand.secureToken
        // Grab the fileUploads array and see what's there
        // If this POST was not multi-part, then this array will be empty
        if let uploads = request.postFileUploads {
            print("uploads found")
            
            if uploads.count > 0 {
                var ary = [[String:Any]]()
                
                for upload in uploads {
                    ary.append([
                        "fieldName": upload.fieldName,
                        "contentType": upload.contentType,
                        "fileName": upload.fileName,
                        "fileSize": upload.fileSize,
                        "tmpFileName": upload.tmpFileName
                        ])
                }
                print(ary)
                let upload = uploads[0]
                
                // move file to webroot
                let thisFile = File(upload.tmpFileName)
                do {
                    let _ = try thisFile.moveTo(path: fileDir.path + filename, overWrite: true)
                    print("saved file")
                } catch {
                    print(error)
                }
                
            }
        }
        
        print("creating feed")
        let accountID = request.user.authDetails!.account.uniqueID
        let feed = Feed()
        feed.status = status
        feed.location = location
        feed.uniqueID = filename
        feed.userID = accountID
        do {
            try feed.create()
            let encoded = feed.getJSONValues()
            resp["error"] = "none"
            resp["login"] = "ok"
            resp["feed"] = encoded
        } catch let e as TurnstileError {
            resp["error"] = e.description
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        do {
            let tags = Utilities.matches(for: "(^|\\s)#(\\w*[a-zA-Z_]+\\w*)", in: status)
            print(tags)
            for tagItem in tags {
                let match = tagItem.replacingOccurrences(of: " ", with: "")
                let temp = match.replacingOccurrences(of: "#", with: "")
                let tag = Tag()
                tag.tag = temp
                tag.feedID = feed.uniqueID
                try tag.create()
            }
        } catch {
            print ("error occured on saving feed tags")
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func listFeedHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        let accountID = request.user.authDetails!.account.uniqueID
        let feed = Feed()
        do {
            let feedList:[Feed] = try feed.allFeedWithOwner("", requestUser: accountID)
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
    
    open static func myFeedsHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        let accountID = request.user.authDetails!.account.uniqueID
        let feed = Feed()
        do {
            let feedList:[Feed] = try feed.myFeeds(accountID)
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
    
    open static func userFeedsHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
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
            let feedList:[Feed] = try feed.userFeeds(userID, requestUser: accountID)
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
    
    open static func favouiteHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        
        guard let feedID = request.param(name: "feedID"),
            let makeFav = request.param(name: "makeFav") else {
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
        print("values : \(feedID) and \(makeFav)")
        let accountID = request.user.authDetails!.account.uniqueID
        var favourite = Favourite()
        if (makeFav != "true") {
            //delete fav
            
            do {
                favourite = try favourite.getFav(feedID: feedID, userID: accountID)
                try favourite.delete()
                resp["error"] = "none"
            } catch {
                 resp["error"] = "An unknown error occurred."
            }
        } else {
            do {
                let existingfavourite = try favourite.getFav(feedID: feedID, userID: accountID)
                try existingfavourite.delete()
            } catch {
            }
            //create fav
            favourite = Favourite()
            let rand = URandom()
            let uniqueID = rand.secureToken
            favourite.uniqueID = uniqueID
            favourite.feedID = feedID
            favourite.userID = accountID
            do {
                try favourite.create()
                resp["error"] = "none"
            } catch {
                resp["error"] = "An unknown error occurred."
            }
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    open static func myFavFeedsHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        let accountID = request.user.authDetails!.account.uniqueID
        let feed = Feed()
        do {
            let feedList:[Feed] = try feed.allFavoriteFeedsOfOwner(accountID)
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
    
    open static func getTopTagsHandlerGET(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        let tag = Tag()
        do {
            let tags = try tag.topTags()
            var outputList = [[String: Any]]()
            for tagItem in tags {
                let converted = tagItem.getJSONValues()
                outputList.append(converted)
            }
            resp["error"] = "none"
            resp["tags"] = outputList
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
    
    open static func getFeedsWithTagHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        guard let tag = request.param(name: "tag") else {
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
            let feedList:[Feed] = try feed.feedsOfTag(tag, user: accountID)
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
    
    open static func searchTagsHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: Any]()
        guard let searchText = request.param(name: "search") else {
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
        let tag = Tag()
        do {
            let tags = try tag.searchTags(searchText)
            var outputList = [[String: Any]]()
            for tagItem in tags {
                let converted = tagItem.getJSONValues()
                outputList.append(converted)
            }
            resp["error"] = "none"
            resp["tags"] = outputList
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

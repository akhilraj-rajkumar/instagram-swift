//
//  APIRoutes.swift
//  SwiftServerTest
//
//  Created by Akhilraj Rajkumar on 01/02/17.
//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public func makeAPIRoutes(_ root: String = "/api/v1") -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "\(root)/login", handler: HandlersJSON.loginHandlerPOST)
    routes.add(method: .post, uri: "\(root)/register", handler: HandlersJSON.registerHandlerPOST)
    routes.add(method: .get, uri: "\(root)/me", handler: HandlersJSON.userDetailsGET)
    routes.add(method: .post, uri: "\(root)/user", handler: HandlersJSON.userDetailsPOST)
    routes.add(method: .post, uri: "\(root)/create_feed", handler: FeedHandlersJSON.createFeedHandlerPOST)
    routes.add(method: .post, uri: "\(root)/feeds", handler: FeedHandlersJSON.listFeedHandlerPOST)
    routes.add(method: .post, uri: "\(root)/myfeeds", handler: FeedHandlersJSON.myFeedsHandlerPOST)
    routes.add(method: .post, uri: "\(root)/userfeeds", handler: FeedHandlersJSON.userFeedsHandlerPOST)
    routes.add(method: .post, uri: "\(root)/favourite", handler: FeedHandlersJSON.favouiteHandlerPOST)
    return routes
}

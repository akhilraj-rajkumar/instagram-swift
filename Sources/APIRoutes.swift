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
    routes.add(method: .post, uri: "\(root)/user", handler: UserHandlersJSON.userDetailsPOST)
    routes.add(method: .post, uri: "\(root)/create_feed", handler: FeedHandlersJSON.createFeedHandlerPOST)
    routes.add(method: .post, uri: "\(root)/feeds", handler: FeedHandlersJSON.listFeedHandlerPOST)
    routes.add(method: .post, uri: "\(root)/myfeeds", handler: FeedHandlersJSON.myFeedsHandlerPOST)
    routes.add(method: .post, uri: "\(root)/userfeeds", handler: FeedHandlersJSON.userFeedsHandlerPOST)
    routes.add(method: .post, uri: "\(root)/favorite_feeds", handler: FeedHandlersJSON.myFavFeedsHandlerPOST)
    routes.add(method: .post, uri: "\(root)/favourite", handler: FeedHandlersJSON.favouiteHandlerPOST)
    routes.add(method: .post, uri: "\(root)/follow", handler: UserHandlersJSON.followHandlerPOST)
    routes.add(method: .post, uri: "\(root)/un_follow", handler: UserHandlersJSON.unFollowHandlerPOST)
    routes.add(method: .get, uri: "\(root)/recommended_users", handler: UserHandlersJSON.recommendedUsersGET)
    routes.add(method: .post, uri: "\(root)/update_profile", handler: UserHandlersJSON.updateProfileHandlerPOST)
    routes.add(method: .post, uri: "\(root)/change_password", handler: UserHandlersJSON.changePasswordHandlerPOST)
    routes.add(method: .post, uri: "\(root)/request_reset_password", handler: UserHandlersJSON.requestResetPasswordHandlerPOST)
    routes.add(method: .post, uri: "\(root)/reset_password", handler: UserHandlersJSON.resetPasswordHandlerPOST)
    return routes
}

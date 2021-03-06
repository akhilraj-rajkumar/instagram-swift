//
//  WebRoutes.swift
//  SwiftServerTest
//
//  Created by Akhilraj Rajkumar on 01/02/17.
//
//

import PerfectLib
import PerfectHTTP

public func makeWebRoutes() -> Routes {
    var routes = Routes()
    routes.add(method: .get, uri: "/", handler: HandlersWeb.indexHandlerGet)
    routes.add(method: .get, uri: "/home", handler: HandlersWeb.homeHandlerGet)
    routes.add(method: .get, uri: "/views/**", handler: HandlersWeb.viewsWildCardHandlerGet)
    routes.add(method: .get, uri: "/*", handler: HandlersWeb.wildCardHandlerGet)
    routes.add(method: .get, uri: "/profile", handler: HandlersWeb.profileHandlerGet)
    routes.add(method: .get, uri: "/profile/*", handler: HandlersWeb.profileHandlerGet)
    routes.add(method: .get, uri: "/error", handler: HandlersWeb.errorHandler)
    routes.add(method: .get, uri: "/settings", handler: HandlersWeb.settingsHandler)
    routes.add(method: .get, uri: "/favorites", handler: HandlersWeb.favoritesHandler)
    routes.add(method: .get, uri: "/forgotpassword", handler: HandlersWeb.forgotPasswordHandler)
    routes.add(method: .get, uri: "/passwordreset/{resetID}", handler: HandlersWeb.resetPasswordHandler)
    routes.add(method: .get, uri: "/feed_search/{resetID}", handler: HandlersWeb.feedSearchHandler)
    return routes
}

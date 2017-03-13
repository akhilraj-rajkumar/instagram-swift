//
//  AuthHandlersWeb.swift
//  SwiftServerTest
//
//  Created by Akhilraj Rajkumar on 01/02/17.
//
//


import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class HandlersWeb {
    
    open static func indexHandlerGet(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (request.user.authenticated) {
            request.path = "views/home.html"
        } else {
            request.path = "views/login.html"
        }
        StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        
    }
    
    open static func homeHandlerGet(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (request.user.authenticated) {
            request.path = "views/home.html"
            StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        } else {
            response.redirect(path: "/")
        }
    }
    
    open static func profileHandlerGet(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (request.user.authenticated) {
            request.path = "views/profile.html"
            StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        } else {
            response.redirect(path: "/")
        }
    }
    
    open static func profileHandlerWithIdGet(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (request.user.authenticated) {
            request.path = "views/profile.html"
            StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        } else {
            response.redirect(path: "/")
        }
    }
    
    open static func errorHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (request.user.authenticated) {
            request.path = "views/error.html"
            StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        } else {
            response.redirect(path: "/")
        }
    }
    
    open static func viewsWildCardHandlerGet(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (!request.user.authenticated) {
            response.redirect(path: "/")
        } else {
            StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        }
        
    }
    
    open static func wildCardHandlerGet(request: HTTPRequest, _ response: HTTPResponse) {
        
        if (!request.user.authenticated) {
            response.redirect(path: "/")
        } else {
            StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
        }
        
    }
}

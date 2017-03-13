//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import TurnstilePerfect

// see next section for alternate daabase options
import PostgresStORM
import PerfectTurnstilePostgreSQL
import PerfectLib

//RequestLogFile.location = "./requests.log"

// Used later in script for the Realm and how the user authenticates.
let pturnstile = SwiftLoginRealm()

// Set the connection vatiable
// Replace with your values
PostgresConnector.host        = "localhost"
PostgresConnector.username    = "postgres"
PostgresConnector.password    = "postgres"
PostgresConnector.database    = "SwiftLogin"
PostgresConnector.port        = 5432


// Set up the Authentication table
let auth = User()
try? auth.setup()

let feed = Feed()
try? feed.setup()

let favourite = Favourite()
try? favourite.setup()

// Connect the AccessTokenStore
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

let server = HTTPServer()
server.serverPort = 8282

let webRoutes = makeWebRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")
let APIRoutes = makeAPIRoutes("/api/v1")

server.addRoutes(webRoutes)
server.addRoutes(authJSONRoutes)
server.addRoutes(APIRoutes)

// Adding a test route
var routes = Routes()
routes.add(method: .get, uri: "/api/v1/test", handler: AuthHandlersJSON.testHandler)
server.addRoutes(routes)

// Where to serve static files from
server.documentRoot = "./webroot"

// Setup logging
//let myLogger = RequestLogger()

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/api/v1/*")
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/register")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

//server.setRequestFilters([(myLogger, .high)])
//server.setResponseFilters([(myLogger, .low)])

do {
	// Launch the servers based on the configuration data.
	//try HTTPServer.launch(configurationData: confData)
    try server.start()
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}


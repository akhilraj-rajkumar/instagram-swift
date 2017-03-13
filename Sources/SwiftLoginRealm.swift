//
//  SwiftLoginRealm.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 23/02/17.
//
//

import Turnstile
import TurnstileWeb
import PerfectHTTP
import TurnstilePerfect
import PerfectTurnstilePostgreSQL

public class SwiftLoginRealm {
    public var requestFilter: (HTTPRequestFilter, HTTPFilterPriority)
    public var responseFilter: (HTTPResponseFilter, HTTPFilterPriority)
    
    private let turnstile: Turnstile
    
    public init(sessionManager: SessionManager = PerfectSessionManager(), realm: Realm = LoginRealm()) {
        turnstile = Turnstile(sessionManager: sessionManager, realm: realm)
        let filter = TurnstileFilter(turnstile: turnstile)
        
        requestFilter = (filter, HTTPFilterPriority.high)
        responseFilter = (filter, HTTPFilterPriority.high)
    }
}

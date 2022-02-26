//
//  Model+Handlers.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation

extension Model {
    
    func handleUnexpected(serverStatusCode: ServerStatusCode, errorMessage: String?) {
        
        //TODO: implementation required
        print("Unexpected status code: \(serverStatusCode), errorMessage: \(String(describing: errorMessage))")
    }
    
    func handleUnauthorizedRequestAttempt(_ method: String = #function) {
        
        //TODO: log
        print("Unauthorized Request Attempt, method: \(method)")
    }
}

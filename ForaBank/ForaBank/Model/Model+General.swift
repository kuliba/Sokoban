//
//  Model+Handlers.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation

extension Model {
    
    func handledUnauthorizedCommandAttempt(_ method: String = #function) {
        
        print("Unauthorized Request Attempt, method: \(method)")
    }
    
    func handleServerCommandStatus<Command: ServerCommand>(command: Command, serverStatusCode: ServerStatusCode, errorMessage: String?) {
        
        //TODO: handle unexpected server status
        print("Unexpected status code: \(serverStatusCode), errorMessage: \(String(describing: errorMessage))")
    }

    func handleServerCommandError<Command: ServerCommand>(error: Error, command: Command) {
        
        print("DownloadError: \(error.localizedDescription), command: \(command)")
        
    }
    
    func handleServerCommandCachingError<Command: ServerCommand>(error: Error, command: Command) {
        
        print("CachingError: \(error.localizedDescription), command: \(command)")
    }
    
    func handleServerCommandEmptyData<Command: ServerCommand>(command: Command){
        
        print("DownloadEmptyData command: \(command)")
    }

    func handleSettingsCachingError(error: Error) {

        print("CachingError: \(error.localizedDescription)")
    }
}

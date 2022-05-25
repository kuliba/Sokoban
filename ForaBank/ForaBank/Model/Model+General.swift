//
//  Model+Handlers.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation

extension ModelAction {
    
    enum General {
    
        enum DownloadImage {
            
            struct Request: Action {
                
                let endpoint: String
            }
            
            struct Response: Action {
                
                let endpoint: String
                let result: Result<Data, Error>
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleGeneralDownloadImageRequest(_ payload: ModelAction.General.DownloadImage.Request) {
        
        let command = ServerCommands.DictionaryController.GetProductCatalogImage(endpoint: payload.endpoint)
        serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                action.send(ModelAction.General.DownloadImage.Response(endpoint: payload.endpoint, result: .success(data)))
                
            case .failure(let error):
                action.send(ModelAction.General.DownloadImage.Response(endpoint: payload.endpoint, result: .failure(error)))
            }
        }
    }
}

//MARK: - Handlers

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
}

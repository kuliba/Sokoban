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

//MARK: - Helpers

extension Model {
    
    var defaultErrorMessage: String { "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения." }
}

//MARK: - Handlers

extension Model {
    
    func handleGeneralDownloadImageRequest(_ payload: ModelAction.General.DownloadImage.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DictionaryController.GetProductCatalogImage(token: token, endpoint: payload.endpoint)
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
        
        print("log: Unauthorized Request Attempt, method: \(method)")
    }
    
    func handleServerCommandStatus<Command: ServerCommand>(command: Command, serverStatusCode: ServerStatusCode, errorMessage: String?) {
        
        //TODO: handle unexpected server status
        print("log: Unexpected status code: \(serverStatusCode), errorMessage: \(String(describing: errorMessage)), endpoint: \(command.endpoint)")
    }

    func handleServerCommandError<Command: ServerCommand>(error: Error, command: Command) {
        
        print("log: DownloadError: \(error.localizedDescription), command: \(command)")
        
    }
    
    func handleServerCommandCachingError<Command: ServerCommand>(error: Error, command: Command) {
        
        print("CachingError: \(error.localizedDescription), command: \(command)")
    }
    
    func handleServerCommandEmptyData<Command: ServerCommand>(command: Command){
        
        print("log: DownloadEmptyData command: \(command)")
    }

    func handleSettingsCachingError(error: Error) {

        print("CachingError: \(error.localizedDescription)")
    }
}

enum ModelError: Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
}

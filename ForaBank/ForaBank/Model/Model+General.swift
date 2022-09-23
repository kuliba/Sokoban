//
//  Model+Handlers.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation
import SwiftUI

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
    
    enum Informer {

        struct Show: Action {

            let informer: InformerData
        }
        
        struct Dismiss: Action {
            
            let type: InformerData.CancelableType
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
    
    func handledUnauthorizedCommandAttempt(_ method: String = #function, file: String = #file, line: Int = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Unauthorized Request Attempt, method: \(method)", file: file, line: line)
    }
    
    func handleServerCommandStatus<Command: ServerCommand>(command: Command, serverStatusCode: ServerStatusCode, errorMessage: String?, file: String = #file, line: Int = #line) {
        
        if let errorMessage = errorMessage {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Server Command Status for command: \(command) with status code: \(serverStatusCode) errorMessage: \(errorMessage)", file: file, line: line)
        } else {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Server Command Status for command: \(command) with status code: \(serverStatusCode)", file: file, line: line)
        }
    }

    func handleServerCommandError<Command: ServerCommand>(error: Error, command: Command, file: String = #file, line: Int = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server Command Error for command: \(command) with error: \(error)", file: file, line: line)
    }
    
    func handleServerCommandCachingError<Command: ServerCommand>(error: Error, command: Command, file: String = #file, line: Int = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) caching error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandEmptyData<Command: ServerCommand>(command: Command, file: String = #file, line: Int = #line) {
            
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server Command return Empty Data for command \(command)", file: file, line: line)
    }

    func handleSettingsCachingError(error: Error, file: String = #file, line: Int = #line) {

        LoggerAgent.shared.log(level: .error, category: .model, message: "Settings Caching Error: \(error.localizedDescription)", file: file, line: line)
    }
}

enum ModelError: Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
    case unauthorizedCommandAttempt
}

//
//  Model+Handlers.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation
import ServerAgent
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
    
    
    var defaultErrorMessage: String { "Возникла техническая ошибка. Попробуйте перезапустить приложение, при повторной ошибке - свяжитесь с технической поддержкой банка для уточнения." }
    var emptyDataErrorMessage: String { "Не удалось получить данные.  Свяжитесь с технической поддержкой банка для уточнения." }
    
    var activateCertificateMessage: String { "\nСертификат позволяет просматривать CVV по картам и изменять PIN-код\nв течение 6 месяцев\n\nЭто мера предосторожности во избежание мошеннических операций" }
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
                
                self.images.value[payload.endpoint] = ImageData(data: data)
                
                action.send(ModelAction.General.DownloadImage.Response(endpoint: payload.endpoint, result: .success(data)))
                
                do {
                    
                    if let images = localAgent.load(type: [String: ImageData].self) {
                        
                        let updatedImages = self.dictionaryImagesReduce(images: self.images.value, updateItems: images.imageDataMapper())
                        try self.localAgent.store(updatedImages, serial: nil)
                        
                    } else {
                        
                        try self.localAgent.store(self.images.value, serial: nil)
                    }
                    
                } catch {
                    
                    handleServerDownloadCommandCachingError(error: error, command: command)
                }
                
            case .failure(let error):
                action.send(ModelAction.General.DownloadImage.Response(endpoint: payload.endpoint, result: .failure(error)))
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handledUnauthorizedCommandAttempt(_ method: String = #function, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Unauthorized request attempt, method: \(method)", file: file, line: line)
    }
    
    func handleServerCommandStatus<Command: ServerCommand>(command: Command, serverStatusCode: ServerStatusCode, errorMessage: String?, file: StaticString = #file, line: UInt = #line) {
        
        if let errorMessage = errorMessage {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) status code: \(serverStatusCode) errorMessage: \(errorMessage)", file: file, line: line)
        } else {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) status code: \(serverStatusCode)", file: file, line: line)
        }
    }
    
    func handleServerCommandStatus<Command: ServerUploadCommand>(command: Command, serverStatusCode: ServerStatusCode, errorMessage: String?, file: StaticString = #file, line: UInt = #line) {
        
        if let errorMessage = errorMessage {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) status code: \(serverStatusCode) errorMessage: \(errorMessage)", file: file, line: line)
        } else {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) status code: \(serverStatusCode)", file: file, line: line)
        }
    }

    func handleServerCommandError<Command: ServerCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command)  error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandError<Command: ServerUploadCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server upload command: \(command)  error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandError<Command: ServerDownloadCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server download command: \(command)  error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandCachingError<Command: ServerCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) caching error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandCachingError<Command: ServerUploadCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) caching error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandCachingError<Command: ServerDownloadCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server download command: \(command) caching error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerDownloadCommandCachingError<Command: ServerDownloadCommand>(error: Error, command: Command, file: StaticString = #file, line: UInt = #line) {
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server command: \(command) caching error: \(error.localizedDescription)", file: file, line: line)
    }
    
    func handleServerCommandEmptyData<Command: ServerCommand>(command: Command, file: StaticString = #file, line: UInt = #line) {
            
        LoggerAgent.shared.log(level: .error, category: .model, message: "Server command \(command) responded with unexpected empty data", file: file, line: line)
    }

    func handleSettingsCachingError(error: Error, file: StaticString = #file, line: UInt = #line) {

        LoggerAgent.shared.log(level: .error, category: .model, message: "Settings caching error: \(error.localizedDescription)", file: file, line: line)
    }
}

enum ModelError: Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
    case unauthorizedCommandAttempt
}

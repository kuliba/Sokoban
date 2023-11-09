//
//  ServerAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Combine
import Foundation
import ServerAgent
import SwiftUI

protocol ServerAgentProtocol {
    
    func executeCommand<Command: ServerCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
    func executeDownloadCommand<Command: ServerDownloadCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
    func executeUploadCommand<Command: ServerUploadCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
    
    // async api
    func executeCommand<Command: ServerCommand>(command: Command) async throws -> Command.Response.Payload
    func executeDownloadCommand<Command: ServerDownloadCommand>(command: Command) async throws ->  Command.Response
    func executeUploadCommand<Command: ServerUploadCommand>(command: Command) async throws
}

//MARK: - Default Implementation

extension ServerUploadCommand {

    var parameters: [ServerCommandParameter]? { nil }
    var timeout: TimeInterval? { nil }
}

//MARK: - Default Implementation

extension ServerCommand {
    
    var parameters: [ServerCommandParameter]? { nil }
    var payload: Payload? { nil }
    var timeout: TimeInterval? { nil }
    var cookiesProvider: Bool { false }
    var debugDescription: String {
        
        func parametersDescription() -> String {
            
            guard let parameters = parameters else {
                return ""
            }
            
            var result = ""
            for parameter in parameters {
                
                result += parameter.debugDescription
                result += " | "
            }
            
            return result
        }
        
        func payloadDescription() -> String {
            
            guard let payload = payload, let descriptable = payload as? CustomDebugStringConvertible else {
                return ""
            }
            
            return descriptable.debugDescription
        }
        
        return "\(endpoint)" + " | " + parametersDescription() + payloadDescription()
    }
}

extension ServerDownloadCommand {
    
    var parameters: [ServerCommandParameter]? { nil }
    var payload: Payload? { nil }
    var timeout: TimeInterval? { nil }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}

//MARK: - Async

extension ServerAgentProtocol {
    
    func executeCommand<Command: ServerCommand>(command: Command) async throws -> Command.Response.Payload {
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    
                    if let responseData = response.data {
                        
                        continuation.resume(with: .success(responseData))
                        
                    } else {

                        continuation.resume(with: .failure(ServerAgentError.serverStatus(response.statusCode, errorMessage: response.errorMessage)))
                    }
                    
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
    
    func executeDownloadCommand<Command: ServerDownloadCommand>(command: Command) async throws ->  Command.Response {
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            executeDownloadCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    continuation.resume(with: .success(response))

                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
    
    func executeUploadCommand<Command: ServerUploadCommand>(command: Command) async throws {
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            executeUploadCommand(command: command) { result in
                
                switch result {
                case .success:
                    continuation.resume(with: .success(()))

                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
}

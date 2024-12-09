//
//  ServerAgentEmptyMock.swift
//  Vortex
//
//  Created by Max Gribov on 25.01.2022.
//

import Combine
import Foundation
import ServerAgent

class ServerAgentEmptyMock: ServerAgentProtocol {
    
    func executeCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerCommand {
        
        completion(.failure(.emptyResponseData))
    }
    
    func executeDownloadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerDownloadCommand {
        
        completion(.failure(.emptyResponseData))
    }
    
    func executeUploadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerUploadCommand {
        
        completion(.failure(.emptyResponseData))
    }
}

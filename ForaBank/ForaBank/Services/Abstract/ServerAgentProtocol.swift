//
//  ServerAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import SwiftUI

protocol ServerAgentProtocol {
    
    func executeCommand<Command: ServerCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
}

protocol ServerCommand {
    
    associatedtype Payload: Encodable
    associatedtype Response: ServerResponse
    
    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var payload: Payload? { get }
}

protocol ServerResponse: Decodable, Equatable {
    
    associatedtype Payload: Decodable
    
    var statusCode: ServerStatusCode { get }
    var errorMessage: String? { get }
    var data: Payload { get }
}

enum ServerCommandAuth {
    
    case none
    case token(String)
}

enum ServerAgentError: Error {
    
    case requestCreationError(Error)
    case sessionError(Error)
    case emptyResponseData
    case curruptedData(Error)
    case serverStatus(ServerStatusCode, errorMessage: String?)
}

enum ServerRequestCreationError: Error {
    
    case unableConstructURL
    case unableCounstructURLWithParameters
    case unableEncodePayload(Error)
}

enum ServerCommandMethod: String {
    
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

struct ServerCommandParameter {
    
    let name: String
    let value: String
}

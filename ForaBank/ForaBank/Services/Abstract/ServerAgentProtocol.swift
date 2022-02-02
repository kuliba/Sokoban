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
    func executeDownloadCommand<Command: ServerDownloadCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
}

/// Regular server request
protocol ServerCommand {
    
    associatedtype Payload: Encodable
    associatedtype Response: ServerResponse
    
    var token: String { get } //FIXME: optional
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var payload: Payload? { get }
    //TODO: add timeoutInterval
//    var timeoutInterval: TimeInterval? { get }
}

/// Multipart download server request
protocol ServerDownloadCommand {
    
    associatedtype Payload: Encodable
    typealias Response = Data
    
    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var payload: Payload? { get }
    //TODO: add timeoutInterval
//    var timeoutInterval: TimeInterval? { get }
}

/// Regular server request response
protocol ServerResponse: Decodable, Equatable {
    
    associatedtype Payload: Decodable
    
    var statusCode: ServerStatusCode { get }
    var errorMessage: String? { get }
    var data: Payload { get }
}

/// ServerAgent's error
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

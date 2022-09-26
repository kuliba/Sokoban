//
//  ServerAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import SwiftUI
import Combine

protocol ServerAgentProtocol {
    
    var action: PassthroughSubject<Action, Never> { get }
    
    func executeCommand<Command: ServerCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
    func executeDownloadCommand<Command: ServerDownloadCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
    func executeUploadCommand<Command: ServerUploadCommand>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void)
}

/// Regular server request
protocol ServerCommand: CustomDebugStringConvertible {
    
    associatedtype Payload: Encodable
    associatedtype Response: ServerResponse
    
    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var payload: Payload? { get }
    var timeout: TimeInterval? { get }
    var cookiesProvider: Bool { get }
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
    var timeout: TimeInterval? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

/// Multipart upload server request
protocol ServerUploadCommand {
    
    associatedtype Response: ServerResponse

    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var media: ServerCommandMediaParameter { get }
    var timeout: TimeInterval? { get }
}

//MARK: - Default Implementation

extension ServerUploadCommand {

    var parameters: [ServerCommandParameter]? { nil }
    var timeout: TimeInterval? { nil }
}

/// Regular server request response
protocol ServerResponse: Decodable, Equatable {
    
    associatedtype Payload: Decodable
    
    var statusCode: ServerStatusCode { get }
    var errorMessage: String? { get }
    var data: Payload { get }
}

/// ServerAgent's error
enum ServerAgentError: LocalizedError {
    
    case requestCreationError(Error)
    case sessionError(Error)
    case emptyResponse
    case emptyResponseData
    case unexpectedResponseStatus(Int)
    case curruptedData(Error)
    case serverStatus(ServerStatusCode, errorMessage: String?)

    var errorDescription: String? {
        
        switch self {
        case .requestCreationError(let error):
            return "Request creation error: \(error.localizedDescription))"
            
        case .sessionError(let error):
            return "Session error: \(error.localizedDescription)"

        case .emptyResponse:
            return "Empty response"

        case .emptyResponseData:
            return "Empty response data"
            
        case .unexpectedResponseStatus(let statusCode):
            return "Unexpected response status code: \(statusCode)"

        case .curruptedData(let error):
            return "Currupted data: \(error.localizedDescription)"

        case .serverStatus(let serverStatusCode, let errorMessage):
            
            if let errorMessage = errorMessage {
                
                return "Server status: \(serverStatusCode) \(errorMessage)"
            } else {
                
                return "Server status: \(serverStatusCode)"
            }
        }
    }
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
    case patch = "PATCH"
}

struct ServerCommandParameter: CustomDebugStringConvertible {
    
    let name: String
    let value: String
    
    var debugDescription: String { "\(name), \(value)" }
}

struct ServerCommandMediaParameter {
    
    let fileName: String
    let data: Data
    let mimeType: String
    
    internal init(fileName: String, data: Data, mimeType: String) {
        self.fileName = fileName
        self.data = data
        self.mimeType = mimeType
    }
    
    init?(with imageData: ImageData, fileName: String) {

        guard let data = imageData.jpegData else {
            return nil
        }
        
        self.fileName = fileName + ".jpeg"
        self.data = data
        self.mimeType = "image/jpeg"
    }
}

enum ServerAgentAction {
    
    struct NetworkActivityEvent: Action {}
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

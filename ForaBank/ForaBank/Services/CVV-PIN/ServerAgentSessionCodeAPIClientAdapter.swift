//
//  ServerAgentSessionCodeAPIClientAdapter.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.07.2023.
//

import CvvPin
import Foundation
import enum ServerAgent.ServerStatusCode

struct APISessionCode: Decodable, Equatable {
 
    let value: String
}

final class ServerAgentSessionCodeAPIClientAdapter: CvvPin.APIClient {
    
    private let token: String
    private let serverAgent: ServerAgentProtocol
    
    init(
        token: String,
        serverAgent: ServerAgentProtocol
    ) {
        self.token = token
        self.serverAgent = serverAgent
    }
    
    typealias Payload = APISessionCode
    typealias ServerStatusCode = Int
    
    func data(
        _ request: CvvPin.APIRequest,
        completion: @escaping Completion
    ) {
        let command = ServerCommands.CvvPin.GetProcessingSessionCode(token: token)
        
        serverAgent.executeCommand(command: command) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(.init {
                
                try result.map(API.ServerResponse.init).get()
            })
        }
    }
}

private extension API.ServerResponse where Payload == APISessionCode, ServerStatusCode == Int {
    
    init(
        _ response: ServerCommands.CvvPin.GetProcessingSessionCode.Response
    ) {
        let code: APISessionCode? = response.data.map { APISessionCode(value: $0.code)
        }
        self.init(
            statusCode: .init(response.statusCode),
            errorMessage: response.errorMessage,
            payload: code
        )
    }
}
                    
private extension API.ServerResponse<APISessionCode, Int>.StatusCode {
    
    init(_ serverStatusCode: ServerAgent.ServerStatusCode) {
        
        switch serverStatusCode {
        case .ok:
            self = .ok
        default:
            self = .other(0)
        }
    }
}

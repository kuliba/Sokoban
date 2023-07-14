//
//  ServerAgentSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

import Combine
@testable import ForaBank

final class ServerAgentSpy: ServerAgentProtocol {
    
    private(set) var isSingleServiceRequestsPurefs = [String]()
    private let isSingleService: Bool?
    
    private(set) var getMosParkingListRequestCount = 0
    
    init(isSingleService: Bool? = nil) {
        self.isSingleService = isSingleService
    }
    
    func executeCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerCommand {
        
        switch command {
        case let command as ServerAgentTestStub.IsSingleService:
            
            if let puref = command.payload?.puref {
                
                isSingleServiceRequestsPurefs.append(puref)
            }
            let response = ServerCommands.TransferController.IsSingleService.Response(statusCode: .ok, errorMessage: nil, data: isSingleService)
            completion(.success(response as! Command.Response))
            return
            
        case _ as ServerAgentTestStub.GetMosParkingList:
            
            getMosParkingListRequestCount += 1
            completion(.failure(.curruptedData(anyNSError())))
            
        default:
            
            completion(.failure(.emptyResponse))
        }
    }
    
    func executeDownloadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerDownloadCommand {
        
        fatalError("unimplemented")
    }
    
    func executeUploadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerUploadCommand {
        
        fatalError("unimplemented")
    }
    
    let action = PassthroughSubject<Action, Never>()
}

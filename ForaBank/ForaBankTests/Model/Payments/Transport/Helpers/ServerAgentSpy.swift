//
//  ServerAgentSpy.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

import Combine
@testable import ForaBank
import ServerAgent

final class ServerAgentSpy: ServerAgentProtocol {
    
    private(set) var isSingleServiceRequestsPurefs = [String]()
    private let isSingleService: Bool?
    
    private(set) var getMosParkingListRequestCount = 0
    private(set) var processSbpPayTokens = [ServerCommands.SbpPayController.ProcessToken]()
    
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
            completion(.failure(.corruptedData(anyNSError())))
            
        case let processToken as ServerCommands.SbpPayController.ProcessToken:
            processSbpPayTokens.append(processToken)
            
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
}

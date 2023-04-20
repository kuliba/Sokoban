//
//  ServerAgentStub.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.02.2023.
//

@testable import ForaBank
import Combine
import Foundation

final class ServerAgentStub: ServerAgentProtocol {
    
    var action: PassthroughSubject<Action, Never> = .init()
    
    typealias GetPhoneInfo = ServerCommands.DaDataController.GetPhoneInfo
    typealias GetPhoneInfoResponse = GetPhoneInfo.Response
    
    typealias AnywayTransfer = ServerCommands.TransferController.CreateAnywayTransfer
    typealias AnywayTransferResponse = AnywayTransfer.Response
    
    typealias EssenceStub = [Essence: AnywayTransferResponse]
    
    private let stub: [String: DaDataPhoneData]
    private let essenceStub: EssenceStub
    
    init(
        stub: [String: DaDataPhoneData],
        essenceStub: EssenceStub
    ) {
        self.stub = stub
        self.essenceStub = essenceStub
    }
    
    func executeCommand<Command>(
        command: Command,
        completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
    ) where Command: ServerCommand {
        
        switch command {
        case let getPhoneInfo as GetPhoneInfo:
            completion(.success(response(for: getPhoneInfo) as! Command.Response))
            
        case let anywayTransfer as AnywayTransfer:
            completion(.success(response(for: anywayTransfer) as! Command.Response))
            
        default:
            completion(.failure(.emptyResponseData))
        }
    }
    
    // Unused but needed to conform to `ServerAgentProtocol`
    
    func executeDownloadCommand<Command>(
        command: Command,
        completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
    ) where Command: ServerDownloadCommand {
        
        fatalError("Unimplemented")
    }
    
    func executeUploadCommand<Command>(
        command: Command,
        completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
    ) where Command: ServerUploadCommand {
        
        fatalError("Unimplemented")
    }
}

extension ServerAgentStub {
    
    struct Essence: Hashable {
        
        let puref: String
        let phoneNumber: String
        let amount: Double
    }
}

// MARK: - GetPhoneInfo

private extension ServerAgentStub {
    
    func response(
        for getPhoneInfo: GetPhoneInfo
    ) -> GetPhoneInfoResponse {
        
        guard let list = getPhoneInfo.payload?.phoneNumbersList,
              let phoneNumber = list.first,
              let daDataPhoneData = stub[phoneNumber]
        else {
            return .error
        }
        
        return .data(daDataPhoneData)
    }
}


// MARK: - AnywayTransfer

private extension ServerAgentStub {
    
    func response(
        for anywayTransfer: AnywayTransfer
    ) -> AnywayTransferResponse {
        
        guard let puref = anywayTransfer.payload?.puref,
              let amount = anywayTransfer.payload?.amountDouble,
              let phoneNumber = anywayTransfer.payload?.phoneNumber,
              let response = essenceStub[.init(puref: puref, phoneNumber: phoneNumber, amount: amount)]
        else {
            return .error
        }
        
        return response
    }
}

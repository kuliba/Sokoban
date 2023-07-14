//
//  ServerAgentTestStub.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.06.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class ServerAgentTestStub: ServerAgentProtocol {
    
    let action = PassthroughSubject<ForaBank.Action, Never>()
    
    typealias CreateAnywayTransfer = ServerCommands.TransferController.CreateAnywayTransfer
    typealias CreateAnywayTransferResponse = CreateAnywayTransfer.Response
    
    typealias GetPhoneInfo = ServerCommands.DaDataController.GetPhoneInfo
    typealias GetPhoneInfoResponse = GetPhoneInfo.Response
    
    typealias IsSingleService = ServerCommands.TransferController.IsSingleService
    typealias IsSingleServiceResponse = IsSingleService.Response
    
    typealias GetMosParkingList = ServerCommands.DictionaryController.GetMosParkingList
    typealias MosParkingListData = GetMosParkingList.Response.MosParkingListData

    private let stubs: [Stub.Case: Stub]
    
    init(_ stubs: [Stub]) {
        
        self.stubs = stubs.reduce(
            into: [Stub.Case: Stub]()
        ) { dict, stub in
            
            switch stub {
            case .anywayTransfer:
                dict[.anywayTransfer] = stub
                
            case .getPhoneInfo:
                dict[.getPhoneInfo] = stub
                
            case .isSingleService:
                dict[.isSingleService] = stub
                
            case .mosParking:
                dict[.mosParking] = stub
            }
        }
    }
    
    func executeCommand<Command>(
        command: Command,
        completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
    ) where Command: ServerCommand {
        
        do {
            let `case` = try Stub.Case(command: command)
            
            guard let stub = stubs[`case`] else {
                
                let error = NSError(domain: "Missing stub for case \(`case`)", code: 0)
                completion(.failure(.curruptedData(error)))
                return
            }
            
            stub.complete(with: completion)
            
        } catch {
            completion(.failure(.curruptedData(error)))
            return
        }
    }
}

extension ServerAgentTestStub {
    
    enum Stub {
        
        typealias CreateAnywayTransferResult = Result<CreateAnywayTransfer, ServerAgentError>
        typealias GetPhoneInfoResult = Result<GetPhoneInfo, ServerAgentError>
        typealias IsSingleServiceResponseResult = Result<IsSingleService.Response, ServerAgentError>
        typealias MosParkingResult = Result<GetMosParkingList.Response, ServerAgentError>
        
        case anywayTransfer(CreateAnywayTransferResult)
        case getPhoneInfo(GetPhoneInfoResult)
        case isSingleService(IsSingleServiceResponseResult)
        case mosParking(MosParkingResult)
        
        enum Case {
            
            case anywayTransfer
            case getPhoneInfo
            case isSingleService
            case mosParking
        }
    }
}

extension ServerAgentTestStub.Stub.Case {
    
    init(command: any ServerCommand) throws {
        
        switch command {
        case _ as ServerAgentTestStub.CreateAnywayTransfer:
            self = .anywayTransfer
            
        case _ as ServerAgentTestStub.GetPhoneInfo:
            self = .getPhoneInfo
            
        case _ as ServerAgentTestStub.IsSingleService:
            self = .isSingleService
            
        case _ as ServerAgentTestStub.GetMosParkingList:
            self = .mosParking
            
        default:
            
            throw NSError(domain: "Unknown stub type.", code: 0)
        }
    }
}

extension ServerAgentTestStub.Stub {
    
    func complete<Response>(
        with completion: @escaping (Result<Response, ServerAgentError>) -> Void
    ) where Response: ServerResponse {
        
        switch self {
        case let .anywayTransfer(result):
            guard let response = try? result.get() as? Response
            else {
                let error = NSError(domain: "Bad data for anywayTransfer in \(result)", code: 0)
                completion(.failure(.curruptedData(error)))
                return
            }
            completion(.success(response))
            
        case let .getPhoneInfo(result):
            guard let response = try? result.get() as? Response
            else {
                let error = NSError(domain: "Bad data for getPhoneInfo in \(result)", code: 0)
                completion(.failure(.curruptedData(error)))
                return
            }
            completion(.success(response))
            
        case let .isSingleService(result):
            do {
                let response = try result.get()
                if let response = response as? Response {
                    completion(.success(response))
                } else {
                    let error = NSError(domain: "Bad data for isSingleService in \(result)", code: 0)
                    completion(.failure(.curruptedData(error)))
                }
            } catch {
                completion(.failure(.curruptedData(error)))
                return
            }
            
        case let .mosParking(result):
            do {
                let response = try result.get()
                if let response = response as? Response {
                    completion(.success(response))
                } else {
                    let error = NSError(domain: "Bad data for mosParking in \(result)", code: 0)
                    completion(.failure(.curruptedData(error)))
                }
            } catch {
                completion(.failure(.curruptedData(error)))
                return
            }
        }
    }
}

// MARK: - Unimplemented

extension ServerAgentTestStub {
    
    func executeDownloadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerDownloadCommand {
        
        let _: Command = unimplemented("executeDownloadCommand")
    }
    
    func executeUploadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerUploadCommand {
        
        let _: Command = unimplemented("executeUploadCommand")
    }
}

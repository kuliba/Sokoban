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
    
    typealias C2BPaymentList = ServerCommands.SBPPaymentController.CreateC2BPaymentCard
    typealias PaymentC2BResponseData = C2BPaymentList.Response.Payload

    typealias GetScenarioQRData = ServerCommands.SBPController.GetScenarioQRData
    typealias PaymentGetScenarioQRDataResponseData = GetScenarioQRData.Response.Payload
    
    typealias GetOperationDetail = ServerCommands.PaymentOperationDetailContoller.GetOperationDetail
    typealias GetOperationDetailPayload = GetOperationDetail.Response.Payload
    
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
                
            case .c2bPaymentCard:
                dict[.c2bPaymentCard] = stub
            
            case .getScenarioQRData:
                dict[.getScenarioQRData] = stub
                
            case .getOperationDetail:
                dict[.getOperationDetail] = stub
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
                completion(.failure(.corruptedData(error)))
                return
            }
            
            stub.complete(with: completion)
            
        } catch {
            completion(.failure(.corruptedData(error)))
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
        typealias C2BPaymentCard = Result<ServerCommands.SBPPaymentController.CreateC2BPaymentCard.Response, ServerAgentError>
        typealias GetScenarioQRData = Result<ServerCommands.SBPController.GetScenarioQRData.Response, ServerAgentError>
        typealias GetOperationDetail = Result<ServerCommands.PaymentOperationDetailContoller.GetOperationDetail.Response, ServerAgentError>
        
        case anywayTransfer(CreateAnywayTransferResult)
        case getPhoneInfo(GetPhoneInfoResult)
        case isSingleService(IsSingleServiceResponseResult)
        case mosParking(MosParkingResult)
        case c2bPaymentCard(C2BPaymentCard)
        case getScenarioQRData(GetScenarioQRData)
        case getOperationDetail(GetOperationDetail)
        
        enum Case {
            
            case anywayTransfer
            case getPhoneInfo
            case isSingleService
            case mosParking
            case c2bPaymentCard
            case getScenarioQRData
            case getOperationDetail
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
        
        case _ as ServerAgentTestStub.C2BPaymentList:
            self = .c2bPaymentCard
        
        case _ as ServerAgentTestStub.GetScenarioQRData:
            self = .getScenarioQRData
            
        case _ as ServerAgentTestStub.GetOperationDetail:
            self = .getOperationDetail
            
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
                completion(.failure(.corruptedData(error)))
                return
            }
            completion(.success(response))
            
        case let .getPhoneInfo(result):
            guard let response = try? result.get() as? Response
            else {
                let error = NSError(domain: "Bad data for getPhoneInfo in \(result)", code: 0)
                completion(.failure(.corruptedData(error)))
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
                    completion(.failure(.corruptedData(error)))
                }
            } catch {
                completion(.failure(.corruptedData(error)))
                return
            }
            
        case let .mosParking(result):
            do {
                let response = try result.get()
                if let response = response as? Response {
                    completion(.success(response))
                } else {
                    let error = NSError(domain: "Bad data for mosParking in \(result)", code: 0)
                    completion(.failure(.corruptedData(error)))
                }
            } catch {
                completion(.failure(.corruptedData(error)))
                return
            }
            
        case let .c2bPaymentCard(result):
            do {
                let response = try result.get()
                if let response = response as? Response {
                    completion(.success(response))
                } else {
                    let error = NSError(domain: "Bad data for c2bPaymentCard in \(result)", code: 0)
                    completion(.failure(.corruptedData(error)))
                }
            } catch {
                completion(.failure(.corruptedData(error)))
                return
            }
            
        case let .getScenarioQRData(result):
            do {
                let response = try result.get()
                if let response = response as? Response {
                    completion(.success(response))
                } else {
                    let error = NSError(domain: "Bad data for getScenarioQRData in \(result)", code: 0)
                    completion(.failure(.corruptedData(error)))
                }
            } catch {
                completion(.failure(.corruptedData(error)))
                return
            }
            
        case let .getOperationDetail(result):
            do {
                let response = try result.get()
                if let response = response as? Response {
                    completion(.success(response))
                } else {
                    let error = NSError(domain: "Bad data for getOperationDetail in \(result)", code: 0)
                    completion(.failure(.corruptedData(error)))
                }
            } catch {
                completion(.failure(.corruptedData(error)))
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

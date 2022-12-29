//
//  Model+Operation.swift
//  ForaBank
//
//  Created by Max Gribov on 13.10.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Operation {
        
        enum Detail {
            
            struct Request: Action {
                
                let type: Kind
                
                enum Kind {
                    
                    case documentId(Int)
                    case paymentOperationDetailId(Int)
                }
            }
            
            struct Response: Action {
                
                let result: Result<OperationDetailData, ModelError>
            }
        }
    }
    
    enum CheckBicAccount {
    
        struct Request: Action {
            
            let accountNumber: String
            let bic: String
        }
        
        struct Response: Action {
            
            let result: Result<BicAccountCheck,ModelError>
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleOperationDetailRequest(_ payload: ModelAction.Operation.Detail.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        switch payload.type {
        case let .documentId(documentId):
            handleOperationDetailRequestByDocumentId(token, documentId)
            
        case let .paymentOperationDetailId(paymentOperationDetailId):
            handleOperationDetailRequestByPaymentIdRequest(token, paymentOperationDetailId)
        }
    }
    
    func handleOperationDetailRequestByDocumentId(_ token: String, _ documentId: Int) {
        
        let documentIdString = String(documentId)
        let command = ServerCommands.PaymentOperationDetailContoller.GetOperationDetail(token: token, payload: .init(documentId: documentIdString))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let details = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Operation.Detail.Response(result: .failure(ModelError.emptyData(message: response.errorMessage))))
                        return
                    }
                    
                    self.action.send(ModelAction.Operation.Detail.Response(result: .success(details)))
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.Operation.Detail.Response(result: .failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage))))
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Operation.Detail.Response(result: .failure(ModelError.serverCommandError(error: error.localizedDescription))))
            }
        }
    }

    func handleOperationDetailRequestByPaymentIdRequest(_ token: String, _ paymentOperationDetailId: Int) {
        
        let command = ServerCommands.PaymentOperationDetailContoller.GetOperationDetailByPaymentId(token: token, payload: .init(paymentOperationDetailId: paymentOperationDetailId))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let details = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Operation.Detail.Response(result: .failure(ModelError.emptyData(message: response.errorMessage))))
                        return
                    }
                    
                    self.action.send(ModelAction.Operation.Detail.Response(result: .success(details)))
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.Operation.Detail.Response(result: .failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage))))
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Operation.Detail.Response(result: .failure(ModelError.serverCommandError(error: error.localizedDescription))))
            }
        }
    }
    
    func handleOperationCheckBicAccount(_ payload: ServerCommands.PaymentOperationDetailContoller.GetBicAccountCheck.Payload) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentOperationDetailContoller.GetBicAccountCheck(token: token, payload: .init(bic: payload.bic, account: payload.account))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let details = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.CheckBicAccount.Response(result: .failure(ModelError.emptyData(message: response.errorMessage))))
                        return
                    }
                    
                    self.action.send(ModelAction.CheckBicAccount.Response(result: .success(details)))
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.CheckBicAccount.Response(result: .failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage))))
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.CheckBicAccount.Response(result: .failure(ModelError.serverCommandError(error: error.localizedDescription))))
            }
        }
    }
}

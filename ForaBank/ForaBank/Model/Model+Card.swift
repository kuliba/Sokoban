//
//  Model+Card.swift
//  ForaBank
//
//  Created by Дмитрий on 22.04.2022.
//


import CloudKit
import Foundation
import ServerAgent

//MARK: - Action

extension ModelAction {
    
    enum Card {
        
        enum Unblock {
            
            struct Request: Action {
                
                let cardId: Int
                let cardNumber: String
            }
            
            struct Response: Action {
                
                let cardId: Int
                let result: Result
                
                enum Result {
                    
                    case success
                    case failure(message: String)
                }
            }
        }
        
        enum Block {
            
            struct Request: Action {
                
                let cardId: Int
                let cardNumber: String
            }
            
            struct Response: Action {
                
                let cardId: Int
                let result: Result
                
                enum Result {
                    
                    case success
                    case failure(message: String)
                }
            }
        }
    }
    
    enum BankClient {
        
        struct Request: Action, Equatable {
            
            let phone: String
        }
    }
}

//MARK: - Helpers

extension Model {
    
    func isBankClient(phone: String) -> Bool {
        
        let bankClientsPhones = bankClientsInfo.value.map{ $0.phone.digits }
        
        return bankClientsPhones.contains(phone.digits)
    }
}

//MARK: - Handlers

extension Model {
    
    func handleUnblockCardRequest(_ payload: ModelAction.Card.Unblock.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.CardController.UnblockCard(token: token, payload: .init(cardID: payload.cardId, cardNumber: payload.cardNumber))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard response.data != nil else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Card.Unblock.Response(cardId: payload.cardId, result: .failure(message: self.defaultErrorMessage)))
                        return
                    }
                    self.action.send(ModelAction.Card.Unblock.Response(cardId: payload.cardId, result: .success))
                    
                default:
                    if let errorMessage = response.errorMessage {
                        
                        self.action.send(ModelAction.Card.Unblock.Response(cardId: payload.cardId, result: .failure(message: errorMessage)))
                        
                    } else {
                        
                        self.action.send(ModelAction.Card.Unblock.Response(cardId: payload.cardId, result: .failure(message: self.defaultErrorMessage)))
                    }
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.action.send(ModelAction.Card.Unblock.Response(cardId: payload.cardId, result: .failure(message: self.defaultErrorMessage)))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleBlockCardRequest(_ payload: ModelAction.Card.Block.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.CardController.BlockCard(token: token, payload: .init(cardId: payload.cardId, cardNumber: payload.cardNumber))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard response.data != nil else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Card.Unblock.Response(cardId: payload.cardId, result: .failure(message: self.defaultErrorMessage)))
                        return
                    }
                    self.action.send(ModelAction.Card.Block.Response(cardId: payload.cardId, result: .success))
                    
                default:
                    if let error = response.errorMessage {
                        
                        self.action.send(ModelAction.Card.Block.Response(cardId: payload.cardId, result: .failure(message: error)))
                    } else {
                        self.action.send(ModelAction.Card.Block.Response(cardId: payload.cardId, result: .failure(message: self.defaultErrorMessage)))
                    }
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Card.Block.Response(cardId: payload.cardId, result: .failure(message: self.defaultErrorMessage)))
            }
        }
    }
    
    func handleBankClientRequest(_ payload: ModelAction.BankClient.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
            
            let command = ServerCommands.CardController.GetOwnerPhoneNumber(token: token, payload: .init(phoneNumber: payload.phone))
            
            do {
                
                let result = try await getBankClientWithCommand(command: command)
                
                if let result = result, result.phone != "" {
                    
                    self.bankClientsInfo.value.insert(result)
                    
                    do {
                        
                        try localAgent.store(self.bankClientsInfo.value, serial: nil)
                        
                    } catch(let error) {
                        
                        LoggerAgent.shared.log(category: .cache, message: "Chaching Error: \(error)")
                    }
                }
                
            } catch {
                
                self.handleServerCommandError(error: error, command: command)
            }
            
        }
    }
    
    func getBankClientWithCommand(command: ServerCommands.CardController.GetOwnerPhoneNumber) async throws -> BankClientInfo? {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let data = response.data else {
                            continuation.resume(with: .failure(ModelRatesError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        if data != "", let phone = command.payload?.phoneNumber {
                            continuation.resume(returning: BankClientInfo(name: data, phone: phone))

                        } else {
                            continuation.resume(returning: nil)
                        }
                        
                    default:
                        continuation.resume(with: .failure(ModelRatesError.statusError(status: response.statusCode, message: response.errorMessage)))
                        
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(ModelRatesError.serverCommandError(error: error.localizedDescription)))
                }
            }
        }
    }
}

//
//  Model+Card.swift
//  ForaBank
//
//  Created by Дмитрий on 22.04.2022.
//


import Foundation
import CloudKit

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
            
            enum Response: Action {
                
                case success
                case failure(message: String)
            }
        }
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
                        return
                    }
                    self.action.send(ModelAction.Card.Block.Response.success)
                    
                default:
                    if let error = response.errorMessage {
                        
                        self.action.send(ModelAction.Card.Block.Response.failure(message: error))
                    }
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                
            }
        }
    }
}

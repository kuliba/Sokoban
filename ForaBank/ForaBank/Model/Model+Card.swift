//
//  Model+Card.swift
//  ForaBank
//
//  Created by Дмитрий on 22.04.2022.
//


import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Card {
    
        enum Unblock {
            
            struct Request: Action {
                
                let cardId: Int
            }
        }
        
        enum Block {
            
            struct Request: Action {
                
                let cardId: Int
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleUnblockCardtRequest(_ payload: ModelAction.Card.Unblock.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.CardController.UnblockCard(token: token, payload: .init(cardID: payload.cardId, cardNumber: nil))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let unblockData = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleBlockCardtRequest(_ payload: ModelAction.Card.Block.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.CardController.BlockCard(token: token, payload: .init(cardId: payload.cardId, cardNumber: nil))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let blockData = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
}

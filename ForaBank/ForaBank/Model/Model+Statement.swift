//
//  Model+Statement.swift
//  ForaBank
//
//  Created by Дмитрий on 12.04.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Statement {
        
        enum List {
            
            struct Request: Action {
                let productId: ProductData.ID
                let productType: ProductType
            }
            
            struct Response: Action {
                
                let result: Result<[ProductStatementData], Error>
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleStatementRequest(_ payload: ModelAction.Statement.List.Request) {
        guard let token = token else {
            return
        }
        
        switch payload.productType {
        case .card:
            
            let command = ServerCommands.CardController.GetCardStatement(token: token, payload: .init(cardNumber: nil, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil))
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let statement = response.data else { return }
                        
                    default:
                        //TODO: handle not ok server status
                        return
                    }
                case .failure(let error):
                    self.action.send(ModelAction.Settings.GetClientInfo.Failed(error: error))
                }
            }
            
        case .account:
            
            let command = ServerCommands.AccountController.GetAccountStatement(token: token, accountNumber: nil, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil)
            
        case .deposit:
            
            let command = ServerCommands.DepositController.GetDepositStatement(token: token, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil)
        default:
            
            let command = ServerCommands.CardController.GetCardStatement(token: token, payload: .init(cardNumber: nil, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil))
        }
    }
}


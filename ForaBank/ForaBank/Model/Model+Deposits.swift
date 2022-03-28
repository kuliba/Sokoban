//
//  Model+Deposits.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Deposits {
    
        enum List {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<[DepositProductData], Error>
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleDepositsListRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.DepositController.GetDepositProductList(token: token)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let deposits = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    self.action.send(ModelAction.Deposits.List.Response(result: .success(deposits)))

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
            self.action.send(ModelAction.Deposits.List.Response(result: .failure(error)))
            }
        }
    }
}

//
//  Model+CurrencyWallet.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 06.07.2022.
//

import Foundation

extension ModelAction {
    
    enum CurrencyWallet {
        
        enum ExchangeOperations {
            
            enum Start {
                
                struct Request: Action {
                    
                    let amount: Double
                    let currency: String
                    let productFrom: ProductData.ID
                    let productTo: ProductData.ID
                }
                
                struct Response: Action {
                    
                    let result: Result<TransferResponseData,
                                       ModelError>
                }
            }
            
            enum Approve {
                
                struct Request: Action {}
                
                enum Response: Action {
                  
                    case successed(TransferResponseBaseData)
                    case failed(ModelError)
                }

            }
        }
    }
}

extension Model {
            
//MARK: Handlers
    
    func handlerCurrencyWalletExchangeOperationsStartRequest(_ payload:
            ModelAction.CurrencyWallet.ExchangeOperations.Start.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let products = products.value.values.flatMap { $0 }
        
        guard let productFrom = products.first(where: { $0.id == payload.productFrom }),
              let productTo = products.first(where: { $0.id == payload.productTo }),
              let payer = TransferGeneralData.Payer(productData: productFrom),
              let payeeInternal = TransferGeneralData.PayeeInternal(productData: productTo)
        else { return }
        
        let command = ServerCommands.TransferController.CreateTransfer
            .init(token: token,
                  payload: .init(amount: payload.amount,
                                 check: true,
                                 comment: nil,
                                 currencyAmount: payload.currency,
                                 payer: payer,
                                 payeeExternal: nil,
                                 payeeInternal: payeeInternal))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:
                    
                    guard let transferResponse = response.data
                    else {
                        self.action
                            .send(ModelAction.CurrencyWallet.ExchangeOperations.Start
                                    .Response(result: .failure(
                                        .emptyData(message: response.errorMessage))))
                        return
                    }
                    
                    self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Start
                        .Response(result: .success(transferResponse)))
                    
                default:
                    self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Start
                                        .Response(result: .failure(
                                            .statusError(status: response.statusCode,
                                                         message: response.errorMessage))))
                    
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            
            case let .failure(error):
                
                self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Start
                                    .Response(result: .failure(
                                        .serverCommandError(error: error.localizedDescription))))
            }
        }
    }
    
    func handlerCurrencyWalletExchangeOperationsApproveRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.TransferController.MakeTransfer
            .init(token: token,
                  payload: nil)
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response.failed(.statusError(status: response.statusCode, message: response.errorMessage)))
                        return
                    }
                    
                    self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response.successed(data))
                    
                default:
                    self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve
                                        .Response.failed(.statusError(status: response.statusCode,
                                                                      message: response.errorMessage)))
                    
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            
            case let .failure(error):
                
                self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response.failed(.serverCommandError(error: error.localizedDescription)))
            }
            
        }
    }
    
}

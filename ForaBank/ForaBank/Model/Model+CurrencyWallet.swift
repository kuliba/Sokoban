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
                    
                    let result: Result<CurrencyExchangeConfirmationData,
                                       ModelCurrencyWalletError>
                }
            }
            
            enum Approve {
                
                struct Request: Action {}
                
                enum Response: Action {
                  
                    case successed
                    case failed(ModelCurrencyWalletError)
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
                        .Response(result: .success(.init(debitAmount: transferResponse.debitAmount,
                                                         fee: transferResponse.fee,
                                                         creditAmount: transferResponse.creditAmount,
                                                         currencyRate: transferResponse.currencyRate,
                                                         currencyPayer: transferResponse.currencyPayer,
                                                         currencyPayee: transferResponse.currencyPayee))))
                    
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
                                        .serverCommandError(error: error))))
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
                    
                    self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve
                        .Response.successed)
                    
                default:
                    self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve
                                        .Response.failed(.statusError(status: response.statusCode,
                                                                      message: response.errorMessage)))
                    
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            
            case let .failure(error):
                
                self.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve
                                    .Response.failed(.serverCommandError(error: error)))
            }
            
        }
    }
    
}

//MARK: - Error

enum ModelCurrencyWalletError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: Error)
    case cacheError(Error)
}
                
   

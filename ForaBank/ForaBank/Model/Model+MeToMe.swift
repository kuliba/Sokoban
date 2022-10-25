//
//  Model+MeToMe.swift
//  ForaBank
//
//  Created by Max Gribov on 25.10.2022.
//

extension ModelAction.Payment {
    
    enum MeToMe {
        
        enum Start {
            
            struct Request: Action {
                
                let amount: Double
                let currency: String
                let productFrom: ProductData.ID
                let productTo: ProductData.ID
            }
            
            struct Response: Action {
                
                let result: Result<TransferResponseData, ModelError>
            }
        }
        
        enum Approve {
            
            struct Request: Action {
                
                let transferResponse: TransferResponseData
            }
            
            struct Response: Action {
              
                let transferResponse: TransferResponseData
                let result: Result<TransferResponseBaseData, ModelError>
            }
        }
    }
}

//MARK: - Handlers

extension Model {

    func handlerPaymentMeToMeStartRequest(_ payload: ModelAction.Payment.MeToMe.Start.Request) {
        
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
        
        let command = ServerCommands.TransferController.CreateTransfer(token: token, payload: .init(amount: payload.amount,check: true,comment: nil, currencyAmount: payload.currency, payer: payer, payeeExternal: nil, payeeInternal: payeeInternal))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:
                    
                    guard let transferResponse = response.data else {
                        
                        self.action.send(ModelAction.Payment.MeToMe.Start.Response(result: .failure(.emptyData(message: response.errorMessage))))
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.action.send(ModelAction.Payment.MeToMe.Start.Response(result: .success(transferResponse)))
                    
                default:
                    self.action.send(ModelAction.Payment.MeToMe.Start.Response(result: .failure(.statusError(status: response.statusCode, message: response.errorMessage))))
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            
            case let .failure(error):
                self.action.send(ModelAction.Payment.MeToMe.Start.Response(result: .failure(.serverCommandError(error: error.localizedDescription))))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handlerPaymentMeToMeApproveRequest(_ payload: ModelAction.Payment.MeToMe.Approve.Request) {
        
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
                        self.action.send(ModelAction.Payment.MeToMe.Approve.Response(transferResponse: payload.transferResponse, result: .failure(.emptyData(message: response.errorMessage))))
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.action.send(ModelAction.Payment.MeToMe.Approve.Response(transferResponse: payload.transferResponse, result: .success(data)))
                    
                default:
                    self.action.send(ModelAction.Payment.MeToMe.Approve.Response(transferResponse: payload.transferResponse, result: .failure(.statusError(status: response.statusCode, message: response.errorMessage))))
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            
            case let .failure(error):
                self.action.send(ModelAction.Payment.MeToMe.Approve.Response(transferResponse: payload.transferResponse, result: .failure(.serverCommandError(error: error.localizedDescription))))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
}

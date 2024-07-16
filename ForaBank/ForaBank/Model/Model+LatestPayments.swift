//
//  Model+LatestPayments.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 15.05.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum LatestPayments {
        
        enum List {
            
            struct Requested: Action {}
            
            struct Response: Action {
                let result: Result<[LatestPaymentData], Error>
            }
        
        }
        
        enum BanksList {
            
            struct Request: Action, Equatable {
                
                let prePayment: Bool
                let phone: String
            }
            
            struct Response: Action {
                
                let result: Result<[PaymentPhoneData], Error>
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleLatestPaymentsListRequest() {
        
        guard !latestPaymentsUpdating.value else { return }

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        latestPaymentsUpdating.value = true
        
        // TODO: change isServicePayments to true after fix
        let command = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetAllLatestPayments(token: token,
                                              isPhonePayments: true,
                                              isServicePayments: false,
                                              isMobilePayments: true,
                                              isInternetPayments: true,
                                              isTransportPayments: true,
                                              isTaxAndStateServicePayments: true,
                                              isOutsidePayments: true)
    
        serverAgent.executeCommand(command: command) { result in
           
            self.latestPaymentsUpdating.value = false
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    if let payments = response.data {
                     
                        self.latestPayments.value = payments
                        self.action.send(ModelAction
                                        .LatestPayments
                                        .List
                                        .Response(result: .success(payments)))
                    } else {
                        
                        self.latestPayments.value = []
                        self.action.send(ModelAction
                                        .LatestPayments
                                        .List
                                        .Response(result: .success([])))
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            case .failure(let error):
                
                self.action.send(ModelAction
                                .LatestPayments
                                .List
                                .Response(result: .failure(error)))
            }
            
        }
    }
    
    func handleLatestPaymentsBankListRequest(_ payload: ModelAction.LatestPayments.BanksList.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let unformattedPhone = payload.phone.digits
        
        guard paymentsByPhoneUpdating.value.contains(unformattedPhone) == false else {
            return
        }
        
        let command = ServerCommands.PaymentOperationDetailContoller.GetLatestPhonePayments(token: token, payload: .init(phoneNumber: unformattedPhone))
        
        paymentsByPhoneUpdating.value.insert(unformattedPhone)
        
        serverAgent.executeCommand(command: command) { result in
            
            self.paymentsByPhoneUpdating.value.remove(unformattedPhone)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        self.action.send(ModelAction.LatestPayments.BanksList.Response(result: .failure(ModelError.emptyData(message: response.errorMessage))))
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.paymentsByPhone.value[unformattedPhone] = data
                    
                    if !payload.prePayment {
                        
                        self.action.send(ModelAction.LatestPayments.BanksList.Response(result: .success(data)))
                    }
                    
                    do {
                        
                        try self.localAgent.store(self.paymentsByPhone.value, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    
                    self.action.send(ModelAction.LatestPayments.BanksList.Response(result: .failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage))))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.action.send(ModelAction.LatestPayments.BanksList.Response(result: .failure(error)))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
}

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
        
        let command = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetAllLatestPayments(token: token,
                                              isPhonePayments: true,
                                              isCountriesPayments: true,
                                              isServicePayments: true,
                                              isMobilePayments: true,
                                              isInternetPayments: true,
                                              isTransportPayments: true,
                                              isTaxAndStateServicePayments: true)
        
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
}

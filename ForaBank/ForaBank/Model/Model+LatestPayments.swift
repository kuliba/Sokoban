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
            
            //TODO: refacor action ala Products
//            struct Response: Action {
//
//                let productId: ProductData.ID
//                let productType: ProductType
//                let result: Result<ProductDynamicParamsData, Error>
//            }
            struct Complete: Action {
                let latestAllPayments: [LatestPaymentData]
            }
            
            struct Failed: Action {
                let error: Error
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleLatestPaymentsListRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
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
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    if let payments = response.data {
                     
                        self.latestPayments.value = payments
                        
                    } else {
                        
                        self.latestPayments.value = []
                    
                    }

                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            case .failure(let error):
                
                self.action.send(ModelAction.LatestPayments.List.Failed(error: error))
            }
        }
    }
}

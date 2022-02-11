//
//  ModelAction+Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension ModelAction {
    
    enum Payment {
        
        typealias Category = Payments.Category
        typealias Service = Payments.Service
        typealias Operator = Payments.Operator
        typealias Parameter = Payments.Parameter
        typealias Operation = Payments.Operation
        
        enum Services {
            
            struct Request: Action {
                
                let category: Category
            }
            
            struct Response: Action {
                
                let result: Result<[Parameter.Service], Error>
            }
        }
        
        // begin payment process
        enum Begin {
            
            struct Request: Action {
                
                let source: Source
                let currency: Currency
                
                enum Source {
                    
                    case service(Service)
                    case templateId(PaymentTemplateData.ID)
                }
            }

            struct Response: Action {
                
                let result: Result<Operation, Error>
            }
        }
        
        // continue payment process
        enum Continue {
     
            struct Request: Action {
                
                let operation: Operation
            }
            
            struct Response: Action {

                let result: Result
                
                enum Result {
                    
                    case step(Operation)
                    case confirm(Operation)
                    case fail(Error)
                }
            }
        }

        // complete payment
        enum Complete {
            
            struct Request: Action {
                
                let operation: Operation
            }
            
            struct Response: Action {
                
                let result: Result<SuccessData, Error>
                
                struct SuccessData {
                    
                    //TODO: success screen data
                }
            }
        }
    }
}

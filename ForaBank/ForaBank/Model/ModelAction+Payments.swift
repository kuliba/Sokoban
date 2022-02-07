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
        typealias Operator = Payments.Operator
        typealias Service = Payments.Service
        typealias Parameter = Payments.Parameter
        
        // list of operators
        enum Operators {
            
            struct Request: Action {
                
                let categoryId: Category.ID
            }
            
            struct Response {
                
                let categoryId: Category.ID
                let result: Result<[Operator], Error>
            }
        }
        
        // data for service selection
        enum Init {
            
            enum For {
            
                struct OperatorId: Action {
                    
                    let operatorId: Operator.ID
                }
                
                struct ServiceType: Action {
                    
                    let serviceType: Service.Kind
                }
            }

            struct Response {
                
                let serviceType: Service.Kind
                let result: Result<[Parameter], Error>
            }
        }
        
        // start payment process
        enum Start {
            
            enum With {
            
                struct ServiceValue: Action {
                    
                    let service: Service
                }
                
                struct TemplateId: Action {
                    
                    let templateId: PaymentTemplateData.ID
                }
            }

            struct Response {
                
                let service: Service
                let step: Int
                let result: Result<[Parameter], Error>
            }
        }
        
        // continue payment process
        enum Continue {
     
            struct Request: Action {
                
                let service: Service
                let step: Int
                let values: [Parameter.Value]
            }
            
            struct Response: Action {
                
                let service: Service
                let result: Result
                
                enum Result {
                    
                    case step(step: Int, parameters: [Parameter])
                    case check(parameters: [Parameter])
                    case fail(Error)
                }
            }
        }

        // complete payment
        enum Complete {
            
            struct Request: Action {
                
                let service: Service
                let values: [Parameter.Value]
            }
            
            struct Response: Action {
                
                let service: Service
                
                enum Result {
                    
                    case success //Success screen data
                    case fail(Error)
                }
            }
        }
    }
}

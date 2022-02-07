//
//  PaymentsDataModel.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

enum Payments {

    struct Category: Identifiable {
       
        let id: String
        let name: String
        let icon: ImageData
    }
    
    struct Operator : Identifiable {
        
        let id: String
        let name: String
        let description: String
        let icon: ImageData
    }
    
    struct Service: Identifiable {
        
        let id: String
        let name: String
        let type: Kind
    }
    
    enum Parameter {
        
        typealias Identifier = String
        
        struct Value {
            
            let id: Payments.Parameter.Identifier
            let value: String
        }
        
        struct Select: PaymentsParameter {
        
            typealias Value = [Option]
            
            let id: Identifier
            let name: String
            let icon: Data
            let value: Value
            let state: State
            let style: Style
            let type: DataType
            
            struct Option: Identifiable {
                
                let id: String
                let name: String
                let description: String
                let icon: Data
            }
            
            enum State {
                
                case empty
                case selected(Option.ID)
            }
            
            enum Style {
                
                case selector
                case list
            }
            
            enum DataType {
                
                case parameter
                case serviceType
                case serviceId
            }
        }
        
        struct Input: PaymentsParameterValidatable {
            
            typealias Value = String
            
            let id: Identifier
            let name: String
            let icon: Data
            let value: Value
            let validator: Validator
            
            struct Validator: ValidatorProtocol {
                
                let minLength: Int
                let maxLength: Int?
                let regEx: String?
                
                func isValid(value: Value) -> Bool {
                    
                    guard value.count >= minLength else {
                        return false
                    }
                    
                    if let maxLength = maxLength {
                        
                        guard value.count < maxLength else {
                            return false
                        }
                    }
                    
                    //TODO: validate with regex if present
                    
                    return true
                }
            }
        }
        
        struct Info: PaymentsParameter {
            
            let id: Identifier
            let name: String
            let icon: Data
            let value: String
        }
        
        struct Card: PaymentsParameter {
            
            let id: Identifier
            let name: String
            let icon: Data
            let value: Value
            
            struct Value: Identifiable {
                
                let id: String
                let icon: Data
                let paymentSystemIcon: Data
                let name: String
                let lastDigits: String
                let categoryName: String
                let balance: Double
                let currency: Currency
            }
        }
        
        struct Amount: PaymentsParameterValidatable {
            
            let id: Identifier
            let name: String
            let icon: Data
            let value: Value
            let validator: Validator
            
            struct Value {
                
                let amount: Double
                let currency: Currency
                let description: String
            }
            
            struct Validator: ValidatorProtocol {
                
                let minAmount: Double
                
                func isValid(value: Value) -> Bool {
                    
                    guard value.amount >= minAmount else {
                        return false
                    }
                    
                    return true
                }
            }
        }
    }
}

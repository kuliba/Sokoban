//
//  ModelAction+Auth.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation

extension ModelAction {
    
    enum Auth {
        
        enum Register {
            
            struct Request: Action {
                
                let cardNumber: String
            }
            
            struct Response: Action {
                
                let result: Result<Data, Error>
                
                struct Data {
                    
                    let codeLength: Int
                    let phone: String
                    let repeatTimeout: TimeInterval
                }
            }
        }
        
        enum Confirm {
        
            struct Request: Action {
                
                let code: String
            }
            
            enum Response: Action {
                
                case success
                case fail
                case error(Error)
            }
        }
        
        enum RepeatCode {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<Data, Error>
                
                struct Data {
                    
                    let remainRepeatsCount: Int
                }
            }
        }
        
        enum Pincode {
            
            enum Set {
                
                struct Request: Action {
                    
                    let pincode: String
                }
                
                enum Response: Action {
                    
                    case success
                    case error(Error)
                }
            }
            
            enum Check {
                
                struct Request: Action {
                    
                    let pincode: String
                }
                
                enum Response: Action {
                    
                    case success
                    case fail(remainAttempts: Int)
                    case error(Error)
                }
            }
        }
        
        enum Sensor {
            
            struct Use: Action {}
            
            struct Skip: Action {}
        }
        
        enum Login {
            
        }
    }
}

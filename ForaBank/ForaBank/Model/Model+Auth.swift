//
//  Model+Auth.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation

extension Model {
    
    var pincodeLength: Int { 4 }
    var unlockAttemptsAvailable: Int { 3 }
    var availableBiometricSensorType: BiometricSensorType? { .face }
    var isBiometricSensorEnabled: Bool { true }
    //TODO: real products data type
    var promoProducts: [String] { [] }
}

//MARK: - Handlers

internal extension Model {
        
    func handleAuthRegisterRequest(payload: ModelAction.Auth.Register.Request) {
        
        //TODO: real implementation required
        action.send(ModelAction.Auth.Register.Response(result: .success(.init(codeLength: 6, phone: "+79255557799", repeatTimeout: 30))))
    }
    
    func handleAuthVerificationCodeConfirmRequest(payload: ModelAction.Auth.VerificationCode.Confirm.Request) {
        
        //TODO: real implementation required
        if payload.code == "111111" {
            
            action.send(ModelAction.Auth.VerificationCode.Confirm.Response.correct)
            
        } else {
            
            action.send(ModelAction.Auth.VerificationCode.Confirm.Response.incorrect)
        }
    }
    
    func handleAuthVerificationCodeResendRequest() {
        
        //TODO: real implementation required
        action.send(ModelAction.Auth.VerificationCode.Resend.Response(result: .success(.init(remainRepeatsCount: 1))))
    }
    
    func handleAuthPincodeSetRequest(payload: ModelAction.Auth.Pincode.Set.Request) {
        
        //TODO: real implementation required
        action.send(ModelAction.Auth.Pincode.Set.Response.success)
    }
    
    func handleAuthPincodeCheckRequest(payload: ModelAction.Auth.Pincode.Check.Request) {
        
        //TODO: real implementation required
        if payload.pincode == "1111" {
            
            action.send(ModelAction.Auth.Pincode.Check.Response.correct)
            
        } else {
            
            let remainAttempts = max(unlockAttemptsAvailable - payload.attempt, 0)
            if remainAttempts > 0 {
                
                action.send(ModelAction.Auth.Pincode.Check.Response.incorrect(remainAttempts: remainAttempts))
            } else {
                
                action.send(ModelAction.Auth.Pincode.Check.Response.restricted)
            }
        }
    }
    
    func handleAuthSensorSettings(payload: ModelAction.Auth.Sensor.Settings) {
        
        //TODO: real implementation required
        // nothing implement for mock
    }
    
    func handleAuthSensorEvaluateRequest(payload: ModelAction.Auth.Sensor.Evaluate.Request) {
        
        action.send(ModelAction.Auth.Sensor.Evaluate.Response(result: .success(true)))
    }
    
    func handleAuthLoginRequest() {
        
        //TODO: real implementation required
        action.send(ModelAction.Auth.Login.Response.success)
    }
}

//MARK: - Actions

extension ModelAction {
    
    enum Auth {
        
        struct ProductsReady: Action {}
 
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
        
        enum VerificationCode {
            
            enum Confirm {
            
                struct Request: Action {
                    
                    let code: String
                }
                
                enum Response: Action {
                    
                    case correct
                    case incorrect
                    case error(Error)
                }
            }
            
            enum Resend {
                
                struct Request: Action {}
                
                struct Response: Action {
                    
                    let result: Result<Data, Error>
                    
                    struct Data {
                        
                        let remainRepeatsCount: Int
                    }
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
                    let attempt: Int
                }
                
                enum Response: Action {
                    
                    case correct
                    case incorrect(remainAttempts: Int)
                    case restricted
                    case error(Error)
                }
            }
        }
        
        enum Sensor {
            
            enum Settings: Action {
                
                case allow
                case desideLater
            }
            
            enum Evaluate {
            
                struct Request: Action {
                    
                    let sensor: BiometricSensorType
                }
                
                struct Response: Action {
                    
                    let result: Result<Bool, Error>
                }
            }
        }
        
        enum Login {
            
            struct Request: Action {}
            
            enum Response: Action {
                
                case success
                case error(Error)
            }
        }
    }
}

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
        if payload.cardNumber == "1111111111111111" {
           
            action.send(ModelAction.Auth.Register.Response.correct(codeLength: 6, phone: "+79255557799", resendCodeDelay: 5))
        } else {
            
            action.send(ModelAction.Auth.Register.Response.incorrect(message: "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."))
        }
    }
    
    func handleAuthVerificationCodeConfirmRequest(payload: ModelAction.Auth.VerificationCode.Confirm.Request) {
        
        //TODO: real implementation required
        if payload.code == "111111" {
            
            action.send(ModelAction.Auth.VerificationCode.Confirm.Response.correct)
            
        } else {
            
            let totalAttempts = 3
            let remain = totalAttempts - payload.attempt
            
            action.send(ModelAction.Auth.VerificationCode.Confirm.Response.incorrect(remain: remain))
        }
    }
    
    func handleAuthVerificationCodeResendRequest(payload: ModelAction.Auth.VerificationCode.Resend.Request) {
        
        //TODO: real implementation required
        let totalAttempts = 3
        let remain = totalAttempts - payload.attempt
        
        action.send(ModelAction.Auth.VerificationCode.Resend.Response(result: .success(remain)))
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
            
            enum Response: Action {
                
                case correct(codeLength: Int, phone: String, resendCodeDelay: TimeInterval)
                case incorrect(message: String)
                case error(Error)
            }
        }
        
        enum VerificationCode {
            
            enum Confirm {
            
                struct Request: Action {
                    
                    let code: String
                    let attempt: Int
                }
                
                enum Response: Action {
                    
                    case correct
                    case incorrect(remain: Int)
                    case error(Error)
                }
            }
            
            enum Resend {
                
                struct Request: Action {
                    
                    let attempt: Int
                }
                
                struct Response: Action {
                    
                    // remain code resends count
                    let result: Result<Int, Error>
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

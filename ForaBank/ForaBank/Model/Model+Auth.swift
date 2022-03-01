//
//  Model+Auth.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation

extension Model {
    
    var authPincodeLength: Int { 4 }
    var authUnlockAttemptsAvailable: Int { 3 }
    var authAvailableBiometricSensorType: BiometricSensorType? { biometricAgent.availableSensor }
    var authIsBiometricSensorEnabled: Bool {
        
        guard let isSensorEnabled: Bool = try? settingsAgent.load(type: .security(.sensor)) else {
            return false
        }
        
        return isSensorEnabled
    }
}

//MARK: - Actions

extension ModelAction {
    
    enum Auth {
        
        enum ProductImage {
            
            struct Request: Action {
                
                let endpoint: String
            }
            
            struct Response: Action {
                
                let endpoint: String
                let result: Result<Data, Error>
            }
        }
        
        enum Register {
            
            struct Request: Action {
                
                let number: String
            }
            
            enum Response: Action {
                
                case success(codeLength: Int, phone: String, resendCodeDelay: TimeInterval)
                case fail(message: String)
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
                    case failure(message: String)
                }
            }
            
            enum Resend {
                
                struct Request: Action {
                    
                    let attempt: Int
                }
                
                enum Response: Action {
                    
                    case success(remain: Int)
                    case failure(message: String)

                }
            }
            
            struct PushRecieved: Action {
                
                let code: String
            }
        }

        enum Pincode {
            
            enum Set {
                
                struct Request: Action {
                    
                    let pincode: String
                }
                
                enum Response: Action {
                    
                    case success
                    case failure(message: String)
                }
            }
            
            enum Check {
                
                struct Request: Action {
                    
                    let pincode: String
                    let attempt: Int
                }
                
                enum Response: Action {
                    
                    case correct
                    case incorrect(remain: Int)
                    case restricted
                    case failure(message: String)
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
                
                enum Response: Action {
                    
                    case success
                    case failure(message: String)
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
        
        struct Logout: Action {}
    }
}

//MARK: - Handlers

internal extension Model {
    
    func handleAuthProductImageRequest(_ payload: ModelAction.Auth.ProductImage.Request) {
        
        let command = ServerCommands.DictionaryController.GetProductCatalogImage(endpoint: payload.endpoint)
        serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                action.send(ModelAction.Auth.ProductImage.Response(endpoint: payload.endpoint, result: .success(data)))
                
            case .failure(let error):
                action.send(ModelAction.Auth.ProductImage.Response(endpoint: payload.endpoint, result: .failure(error)))
            }
        }
    }
        
    func handleAuthRegisterRequest(payload: ModelAction.Auth.Register.Request) {
        
        //TODO: real implementation required
        if payload.number == "1111111111111111" {
           
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) {
                
                self.action.send(ModelAction.Auth.Register.Response.success(codeLength: 6, phone: "+79255557799", resendCodeDelay: 5))
            }
            
        } else {
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) {
                
                self.action.send(ModelAction.Auth.Register.Response.fail(message: "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."))
            }
        }
    }
    
    func handleAuthVerificationCodeConfirmRequest(payload: ModelAction.Auth.VerificationCode.Confirm.Request) {
        
        //TODO: real implementation required
        if payload.code == "111111" {
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) {
                
                self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.correct)
            }
            
        } else {
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) {
                
                let totalAttempts = 3
                let remain = totalAttempts - payload.attempt
                
                self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.incorrect(remain: remain))
            }
        }
    }
    
    func handleAuthVerificationCodeResendRequest(payload: ModelAction.Auth.VerificationCode.Resend.Request) {
        
        //TODO: real implementation required
        let totalAttempts = 3
        let remain = totalAttempts - payload.attempt
        
        action.send(ModelAction.Auth.VerificationCode.Resend.Response.success(remain: remain))
    }
    
    func handleAuthPincodeSetRequest(payload: ModelAction.Auth.Pincode.Set.Request) {
        
        do {
            
            try keychainAgent.store(payload.pincode, type: .pincode)
            action.send(ModelAction.Auth.Pincode.Set.Response.success)
            
        } catch {
            
            //TODO: log error
            print("Model: handleAuthPincodeSetRequest: error \(error.localizedDescription)")
            
            action.send(ModelAction.Auth.Pincode.Set.Response.failure(message: "Невозможно сохранит пин-код в крипто-хранилище. Попробуйте переустановить приложение. В случае, если ошибка повториться, обратитесь в службу поддержки."))
        }
    }
    
    func handleAuthPincodeCheckRequest(payload: ModelAction.Auth.Pincode.Check.Request) {
        
        do {
            
            let storedPincode: String = try keychainAgent.load(type: .pincode)

            if payload.pincode == storedPincode {
                
                action.send(ModelAction.Auth.Pincode.Check.Response.correct)
                
            } else {
                
                let remainAttempts = authUnlockAttemptsAvailable - payload.attempt
                if remainAttempts > 0 {
                    
                    action.send(ModelAction.Auth.Pincode.Check.Response.incorrect(remain: remainAttempts))
                    
                } else {
                    
                    action.send(ModelAction.Auth.Pincode.Check.Response.restricted)
                }
            }
            
        } catch {
            
            //TODO: log error
            print("Model: handleAuthPincodeCheckRequest: error \(error.localizedDescription)")
            
            action.send(ModelAction.Auth.Pincode.Check.Response.failure(message: "Невозможно прочитать данные пинкода из крипто-хранилища. Необходимо выйти из аккаунта и заново пройти процедуру авторизации."))
        }
    }
    
    func handleAuthSensorSettings(payload: ModelAction.Auth.Sensor.Settings) {
        
        do {
            switch payload {
            case .allow:
                try settingsAgent.store(true, type: .security(.sensor))
            
            case .desideLater:
                try settingsAgent.store(false, type: .security(.sensor))
            }
            
        } catch {
            
            //TODO: log error
            print("Model: handleAuthSensorSettings: error \(error.localizedDescription)")
        }
    }
    
    func handleAuthSensorEvaluateRequest(payload: ModelAction.Auth.Sensor.Evaluate.Request) {
        
        biometricAgent.unlock(with: payload.sensor) { result in
            
            switch result {
            case .success(let isUnlocked):
                if isUnlocked == true {
                    
                    self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.success)
                    
                } else {
                    
                    self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Произошел сбой при попытке разблокировки приложения при помощи сенсора. Попробуйте полностью выгрузить приложение и повторить заново. Если ошибка повториться, обратитесь в службу поддержки."))
                }
                
            case .failure(let error):
  
                self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: error.localizedDescription))
            }
        }
    }
    
    func handleAuthLoginRequest() {
        
        //TODO: real implementation required
        action.send(ModelAction.Auth.Login.Response.success)
    }
    
    func handleAuthLogoutRequest() {
        
        //TODO: real implementation required
    }
}



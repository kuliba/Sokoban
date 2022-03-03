//
//  Model+Auth.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import UIKit
import FirebaseMessaging

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
    var authDefaultErrorMessage: String { "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения." }
}

enum ModelAuthError: Error {
    
    case emptyCSRFData(status: ServerStatusCode, message: String?)
    case identifierForVendorObtainFailed
    case fcmTokenObtainFailed
    case installPushDeviceFailed(status: ServerStatusCode, message: String?)
    case keyExchangeFailed(status: ServerStatusCode, message: String?)
    case checkClientFailed(status: ServerStatusCode, message: String?)
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
                case failure(message: String)
            }
        }
        
        enum VerificationCode {
            
            enum Confirm {
                
                struct Request: Action {
                    
                    let code: String
                }
                
                enum Response: Action {
                    
                    case correct
                    case incorrect(message: String)
                    case restricted(message: String)
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
        
        enum Push {
            
            enum Register {
                
                struct Request: Action {}
                
                enum Response: Action {
                    
                    case success
                    case failure(Error)
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
    
    func handleAuthCSRF(completion: @escaping (Result<CSRFCredentials, CSRFError>) -> Void) {
        
        let command = ServerCommands.UtilityController.Csrf()
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                if let data = response.data {
                    
                    do {
                        
                        let csrfAgent = try CSRFAgent<AESEncryptionAgent>(ECKeysProvider(), data.cert, data.pk)
                        let token = data.token
                        
                        let keyExchangeCommand = ServerCommands.UtilityController.KeyExchange(token: token, payload: .init(data: csrfAgent.publicKeyData, token: token, type: ""))
                        self.serverAgent.executeCommand(command: keyExchangeCommand) { result in
                            
                            switch result {
                            case .success(let response):
                                switch response.statusCode {
                                case .ok:
                                    completion(.success(.init(token: token, csrfAgent: csrfAgent)))
                                    
                                default:
                                    completion(.failure(CSRFError.unexpected(status: response.statusCode, errorMessage: response.errorMessage)))
                                }
                                
                            case .failure(let error):
                                completion(.failure(.serverError(error)))
                            }
                        }
                        
                    } catch {
                        
                        completion(.failure(.csrfAgentInitError(error)))
                    }
                    
                } else {
                    completion(.failure(.unexpected(status: response.statusCode, errorMessage: response.errorMessage)))
                }
                
            case .failure(let error):
                completion(.failure(.serverError(error)))
            }
        }
    }
    
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
        
        handleAuthCSRF { result in
            
            switch result {
            case .success(let credentials):
                self.auth.value = .authorized(credentials: credentials)
                do {
                    
                    let encryptedNumber = try credentials.csrfAgent.encrypt(payload.number)
                    let cryptoVersion = "1.0"
                    
                    let command = ServerCommands.RegistrationContoller.CheckClient(token: credentials.token, payload: .init(cardNumber: encryptedNumber, cryptoVersion: cryptoVersion))
                    self.serverAgent.executeCommand(command: command) { result in
                        
                        switch result {
                        case .success(let response):
                            if let data = response.data {
                                
                                do {
                                    
                                    let decryptedPhone = try credentials.csrfAgent.decrypt(data.phone)
                                    self.action.send(ModelAction.Auth.Register.Response.success(codeLength: 6, phone: decryptedPhone, resendCodeDelay: 30))
                                    
                                } catch {
                                    
                                    //TODO: log error
                                    print("Model: handleAuthRegisterRequest: decrypt phone error \(error.localizedDescription)")
                                    
                                    self.action.send(ModelAction.Auth.Register.Response.failure(message: self.authDefaultErrorMessage))
                                }
                                
                            } else {
                                
                                //TODO: log error
                                print("Model: handleAuthRegisterRequest: empty data status \(response.statusCode), message: \(String(describing: response.errorMessage))")
                                
                                let message = response.errorMessage ?? self.authDefaultErrorMessage
                                self.action.send(ModelAction.Auth.Register.Response.failure(message: message))
                            }
                            
                        case .failure(let error):
                            //TODO: log error
                            print("Model: handleAuthRegisterRequest: error \(error.localizedDescription)")
                            
                            self.action.send(ModelAction.Auth.Register.Response.failure(message: self.authDefaultErrorMessage))
                        }
                    }
                    
                } catch {
                    
                    //TODO: log error
                    print("Model: handleAuthRegisterRequest: encryption number error \(error.localizedDescription)")
                    
                    self.action.send(ModelAction.Auth.Register.Response.failure(message: self.authDefaultErrorMessage))
                }
                
            case .failure(let error):
                //TODO: log error
                print("Model: handleAuthRegisterRequest: CSRF error \(error.localizedDescription)")
                
                self.action.send(ModelAction.Auth.Register.Response.failure(message: self.authDefaultErrorMessage))
            }
        }
    }
    
    func handleAuthVerificationCodeConfirmRequest(payload: ModelAction.Auth.VerificationCode.Confirm.Request) {
        
        guard case .authorized(let credentials) = auth.value else {
            
            //TODO: log error
            print("Model: handleAuthVerificationCodeConfirmRequest: not authorized.")
            
            self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.authDefaultErrorMessage))
            
            return
        }
        
        do {
            
            let verificationCode = try credentials.csrfAgent.encrypt(payload.code)
            let cryptoVersion = "1.0"
            
            let command = ServerCommands.RegistrationContoller.VerifyCode(token: credentials.token, payload: .init(cryptoVersion: cryptoVersion, verificationCode: verificationCode))
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.correct)
                        
                    case .serverError:
                        let message = response.errorMessage ?? "Введен некорректный код. Попробуйте еще раз."
                        self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.incorrect(message: message))
                        
                    case .userNotAuthorized:
                        self.auth.value = .notAuthorized
                        let message = response.errorMessage ?? "Вы исчерпали все попытки. Войдите в приложение заново"
                        self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.restricted(message: message))
                        
                    default:
                        
                        //TODO: log error
                        print("Model: handleAuthVerificationCodeConfirmRequest: data status \(response.statusCode), message: \(String(describing: response.errorMessage))")
                        
                        let message = response.errorMessage ?? self.authDefaultErrorMessage
                        self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: message))
                    }
                    
                case .failure(let error):
                    
                    //TODO: log error
                    print("Model: handleAuthVerificationCodeConfirmRequest: error \(error.localizedDescription)")
                    
                    self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.authDefaultErrorMessage))
                }
            }
            
        } catch {
            
            //TODO: log error
            print("Model: handleAuthVerificationCodeConfirmRequest: encryption code error \(error.localizedDescription)")
            
            self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.authDefaultErrorMessage))
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
            
            action.send(ModelAction.Auth.Pincode.Set.Response.failure(message: "Невозможно сохранить пин-код в крипто-хранилище. Попробуйте переустановить приложение. В случае, если ошибка повториться, обратитесь в службу поддержки."))
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
    
    func handleAuthPushRegisterRequest() {
        
        /*
         guard let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString else {
         
         //TODO: log error
         print("Model: handleAuthRegisterRequest: identifierForVendor obtain failed")
         self.action.send(ModelAction.Auth.ExchangeKeys.Response.failure(ModelAuthError.identifierForVendorObtainFailed))
         
         return
         }
         
         guard let fcmToken = Messaging.messaging().fcmToken else {
         
         //TODO: log error
         print("Model: handleAuthRegisterRequest: fcmToken obtain failed")
         self.action.send(ModelAction.Auth.ExchangeKeys.Response.failure(ModelAuthError.fcmTokenObtainFailed))
         return
         }
         
         let model = UIDevice.current.model
         
         let installPushDeviceCommand = ServerCommands.PushDeviceController.InstallPushDevice(token: token, payload: .init(cryptoVersion: "1.0", model: model, pushDeviceId: identifierForVendor, pushFcmToken: fcmToken))
         self.serverAgent.executeCommand(command: installPushDeviceCommand) { result in
         
         switch result {
         case .success(let response):
         switch response.statusCode {
         case .ok:
         
         let keyExchangeCommand = ServerCommands.UtilityController.KeyExchange(token: token, payload: .init(data: csrfAgent.publicKeyData, token: token, type: ""))
         self.serverAgent.executeCommand(command: keyExchangeCommand) { result in
         
         switch result {
         case .success(let response):
         switch response.statusCode {
         case .ok:
         self.auth.value = .authorized(token: token, csrfAgent: csrfAgent)
         
         default:
         //TODO: log error
         print("Model: handleAuthRegisterRequest: key exchange failed status \(response.statusCode), message: \(String(describing: response.errorMessage))")
         self.action.send(ModelAction.Auth.ExchangeKeys.Response.failure(ModelAuthError.keyExchangeFailed(status: response.statusCode, message: response.errorMessage)))
         }
         
         case .failure(let error):
         //TODO: log error
         print("Model: handleAuthRegisterRequest: key exchange failed error \(error.localizedDescription)")
         self.action.send(ModelAction.Auth.ExchangeKeys.Response.failure(error))
         }
         }
         
         default:
         //TODO: log error
         print("Model: handleAuthRegisterRequest: install push device failed status \(response.statusCode), message: \(String(describing: response.errorMessage))")
         self.action.send(ModelAction.Auth.ExchangeKeys.Response.failure(ModelAuthError.installPushDeviceFailed(status: response.statusCode, message: response.errorMessage)))
         }
         
         case .failure(let error):
         //TODO: log error
         print("Model: handleAuthRegisterRequest: install push device failed error \(error.localizedDescription)")
         self.action.send(ModelAction.Auth.ExchangeKeys.Response.failure(error))
         }
         }
         
         */
    }
    
    func handleAuthLoginRequest() {
        
        //TODO: real implementation required
        action.send(ModelAction.Auth.Login.Response.success)
    }
    
    func handleAuthLogoutRequest() {
        
        //TODO: real implementation required
    }
}



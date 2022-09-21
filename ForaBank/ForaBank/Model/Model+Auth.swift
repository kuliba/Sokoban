//
//  Model+Auth.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import UIKit
import FirebaseMessaging

//MARK: - Actions

extension ModelAction {
    
    enum Auth {
        
        enum Session {
        
            struct Start {
                
                struct Request: Action {}
                
                struct Response: Action {
                    
                    let result: Result<SessionCredentials, Error>
                }
            }
            
            struct Extend {
                
                struct Request: Action {}
                
                struct Response: Action {
                    
                    let result: Result<TimeInterval, Error>
                }
            }
            
            struct Terminate: Action {}
        }
        
        enum CheckClient {
            
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
                    
                    case success
                    case restricted(message: String)
                    case failure(message: String)
                    
                }
            }
            
            struct PushRecieved: Action {
                
                let code: String
            }
        }
        
        enum Register {
        
            struct Request: Action {}
            
            enum Response: Action {
                
                case success(serverDeviceGUID: String)
                case failure(message: String)
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
                    
                    case success(BiometricSensorType)
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
        
        enum SetDeviceSettings {
            
            struct Request: Action {
                
                let sensorType: BiometricSensorType?
            }
            
            enum Response: Action {
                
                case success
                case failure(Error)
            }
        }
        
        enum Login {
            
            struct Request: Action {
                
                let type: Kind
                let restartSession: Bool
                
                enum Kind: String {
                    
                    case pin
                    case touchId
                    case faceId
                }
            }
            
            enum Response: Action {
                
                case success
                case failure(message: String)
            }
        }
        
        struct Logout: Action {}
    }
}

//MARK: - Data Helpers

extension Model {
    
    var authPincodeLength: Int { 4 }
    var authVerificationCodeLength: Int { 6 }
    var authVerificationCodeResendDelay: TimeInterval { 30 }
    var authUnlockAttemptsAvailable: Int { 3 }
    var authAvailableBiometricSensorType: BiometricSensorType? { biometricAgent.availableSensor }
    var authIsBiometricSensorEnabled: Bool {
        
        guard let isSensorEnabled: Bool = try? settingsAgent.load(type: .security(.sensor)) else {
            return false
        }
        
        return isSensorEnabled
    }
    
    var authIsBiometricSensorSettingsSet: Bool {
        
        let isSensorEnabled: Bool? = try? settingsAgent.load(type: .security(.sensor))
        
        return isSensorEnabled != nil
    }
  
    func authStoredPincode() throws -> String {
        
        try keychainAgent.load(type: .pincode)
    }
    
    func authServerDeviceGUID() throws -> String {
        
       try keychainAgent.load(type: .serverDeviceGUID)
    }
    
    var authIsCredentialsStored: Bool {
        
        keychainAgent.isStoredString(values: [.pincode, .serverDeviceGUID])
    }
}

//MARK: - Handlers

internal extension Model {
    
    func handleAuthSessionStartRequest() {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthSessionStartRequest")
        
        Task {
            
            do {
                
                let credentials = try await authCSRF()
                
                LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Session.Start.Response, success, credentials ")
                self.action.send(ModelAction.Auth.Session.Start.Response(result: .success(credentials)))
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Session.Start.Response, failure, error: \(error.localizedDescription)")
                self.action.send(ModelAction.Auth.Session.Start.Response(result: .failure(error)))
            }
        }
    }
    
    func handleAuthSessionExtendRequest() {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthSessionExtendRequest")
        
        guard let token = token else {
            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Session.Extend.Response, failure")
            self.action.send(ModelAction.Auth.Session.Extend.Response(result: .failure(ModelError.unauthorizedCommandAttempt)))
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.UtilityController.GetSessionTimeout(token: token)
        LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    if let duration = response.data  {
                        
                        LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Session.Extend.Response, success, duration: \(duration)")
                        self.action.send(ModelAction.Auth.Session.Extend.Response(result: .success(TimeInterval(duration))))
                        
                    } else {
                        
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Session.Extend.Response, failure")
                        self.action.send(ModelAction.Auth.Session.Extend.Response(result: .failure(ModelError.emptyData(message: response.errorMessage))))
                        self.handleServerCommandEmptyData(command: command)
                    }

                default:
                    LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Session.Extend.Response, failure")
                    self.action.send(ModelAction.Auth.Session.Extend.Response(result: .failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage))))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: String(describing: response.errorMessage))
                }

            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Session.Extend.Response, failure")
                self.action.send(ModelAction.Auth.Session.Extend.Response(result: .failure(error)))
            }
        }
    }
    
    func handleAuthCheckClientRequest(payload: ModelAction.Auth.CheckClient.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthCheckClientRequest")
        
        Task {
            
            do {
                
                let credentials = try await authSessionCredentials()
                try await authPushRegister(token: credentials.token)
                let encryptedNumber = try credentials.csrfAgent.encrypt(payload.number)
                let cryptoVersion = "1.0"
                
                let command = ServerCommands.RegistrationContoller.CheckClient(token: credentials.token, payload: .init(cardNumber: encryptedNumber, cryptoVersion: cryptoVersion))
                LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
                self.serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        if let data = response.data {
                            
                            do {
                                
                                let decryptedPhone = try credentials.csrfAgent.decrypt(data.phone)
                                LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.CheckClient.Response, success")
                                self.action.send(ModelAction.Auth.CheckClient.Response.success(codeLength: self.authVerificationCodeLength, phone: decryptedPhone, resendCodeDelay: self.authVerificationCodeResendDelay))
                                
                            } catch {
                                
                                self.handleServerCommandError(error: error, command: command)
                                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.CheckClient.Response, failure")
                                self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: self.defaultErrorMessage))
                            }
                            
                        } else {
                            
                            self.handleServerCommandEmptyData(command: command)
                            
                            let message = response.errorMessage ?? self.defaultErrorMessage
                            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.CheckClient.Response, failure")
                            self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        self.handleServerCommandError(error: error, command: command)
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.CheckClient.Response, failure")
                        self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: self.defaultErrorMessage))
                    }
                }

            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth CheckClient Task Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.CheckClient.Response, failure")
                self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleAuthVerificationCodeConfirmRequest(payload: ModelAction.Auth.VerificationCode.Confirm.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthVerificationCodeConfirmRequest")
        
        Task {
            
            do {
                
                let credentials = try await authSessionCredentials()
                let verificationCode = try credentials.csrfAgent.encrypt(payload.code)
                let cryptoVersion = "1.0"
                
                let command = ServerCommands.RegistrationContoller.VerifyCode(token: credentials.token, payload: .init(cryptoVersion: cryptoVersion, verificationCode: verificationCode))
                LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.VerificationCode.Confirm.Response, correct")
                            self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.correct)
                            
                        case .serverError:
                            let message = response.errorMessage ?? "Введен некорректный код. Попробуйте еще раз."
                            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.VerificationCode.Confirm.Response, incorrect")
                            self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.incorrect(message: message))
                            
                        case .userNotAuthorized:
                            self.auth.value = .registerRequired
                            let message = response.errorMessage ?? "Вы исчерпали все попытки. Войдите в приложение заново"
                            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.VerificationCode.Confirm.Response, restricted")
                            self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.restricted(message: message))
                            
                        default:
                            
                            if let errorMessage = response.errorMessage {
                             
                                self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                            } else {
                                
                                self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: nil)
                            }
                            
                            let message = response.errorMessage ?? self.defaultErrorMessage
                            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.VerificationCode.Confirm.Response, failure")
                            self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        self.handleServerCommandError(error: error, command: command)
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.VerificationCode.Confirm.Response, failure")
                        self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.defaultErrorMessage))
                    }
                }
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Verification Code Confirm Request Task Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.VerificationCode.Confirm.Response, failure")
                self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleAuthVerificationCodeResendRequest(payload: ModelAction.Auth.VerificationCode.Resend.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthVerificationCodeResendRequest")
        
        Task {
            
            do {
                
                let credentials = try await authSessionCredentials()
                let command = ServerCommands.RegistrationContoller.GetCode(token: credentials.token)
                LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.VerificationCode.Resend.Response, success")
                            self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.success)
                            
                        case .serverError:
                            let message = response.errorMessage ?? "Вы исчерпали все попытки :("
                            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.VerificationCode.Resend.Response, restricted")
                            self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.restricted(message: message))
                            
                        default:
                            
                            if let errorMessage = response.errorMessage {
                             
                                self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                            } else {
                                
                                self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: nil)
                            }
                            
                            let message = response.errorMessage ?? self.defaultErrorMessage
                            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.VerificationCode.Resend.Respons, failure")
                            self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        self.handleServerCommandError(error: error, command: command)
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.VerificationCode.Resend.Respons, failure")
                        self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.failure(message: self.defaultErrorMessage))
                    }
                }
                
            } catch {
               
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Verification Code Resend Request Task Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.VerificationCode.Resend.Respons, failure")
                self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleAuthRegisterRequest() {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthRegisterRequest")
        
        Task {
            
            do {
                
                let credentials = try await authSessionCredentials()
                
                let pushDeviceId = try await authPushDeviceId()
                let pushFcmToken = try await authPushFcmToken()
                let deviceModel = await authDeviceModel()
                let operationSystem = authOperationSystem
                let operationSystemVersion = await authOperationSystemVersion()
                let appVersion = authAppVersion
                
                let cryptoVersion = "1.0"
                let pushDeviceIdEncrypted = try credentials.csrfAgent.encrypt(pushDeviceId)
                let pushFcmTokenEncrypted = try credentials.csrfAgent.encrypt(pushFcmToken)
                let deviceModelEnrypted = try credentials.csrfAgent.encrypt(deviceModel)
                let operationSystemEncrypted = try credentials.csrfAgent.encrypt(operationSystem)
                let operationSystemVersionEncrypted = try credentials.csrfAgent.encrypt(operationSystemVersion)
                let appVersionEncrypted: String? = appVersion != nil ? try credentials.csrfAgent.encrypt(appVersion!) : nil
                
                let command = ServerCommands.RegistrationContoller.DoRegistration(token: credentials.token, payload: .init(cryptoVersion: cryptoVersion, pushDeviceId: pushDeviceIdEncrypted, pushFcmToken: pushFcmTokenEncrypted, model: deviceModelEnrypted, operationSystem: operationSystemEncrypted, operationSystemVersion: operationSystemVersionEncrypted, appVersion: appVersionEncrypted))
                LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            if let encryptedData = response.data {
                                
                                do {
                                    
                                    let serverDeviceGUID = try credentials.csrfAgent.decrypt(encryptedData)
                                    try self.keychainAgent.store(serverDeviceGUID, type: .serverDeviceGUID)
                                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Register.Response, success")
                                    self.action.send(ModelAction.Auth.Register.Response.success(serverDeviceGUID: serverDeviceGUID))
                                    
                                } catch {
                                    
                                    self.handleServerCommandError(error: error, command: command)
                                    LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Register.Response, failure")
                                    self.action.send(ModelAction.Auth.Register.Response.failure(message: self.defaultErrorMessage))
                                }
                                
                            } else {
                                
                                self.handleServerCommandEmptyData(command: command)
                                let message = response.errorMessage ?? self.defaultErrorMessage
                                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Register.Response, failure")
                                self.action.send(ModelAction.Auth.Register.Response.failure(message: message))
                            }
                            
                        default:
                            
                            if let errorMessage = response.errorMessage {
                             
                                self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                            } else {
                                
                                self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: nil)
                            }
                            
                            let message = response.errorMessage ?? self.defaultErrorMessage
                            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Register.Response, failure")
                            self.action.send(ModelAction.Auth.Register.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        self.handleServerCommandError(error: error, command: command)
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Register.Response, failure")
                        self.action.send(ModelAction.Auth.Register.Response.failure(message: self.defaultErrorMessage))
                    }
                }
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Register Request Task Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Register.Response, failure")
                self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleAuthPincodeSetRequest(payload: ModelAction.Auth.Pincode.Set.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthPincodeSetRequest")
        
        do {
            
            try keychainAgent.store(payload.pincode, type: .pincode)
            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Pincode.Set.Response, success")
            action.send(ModelAction.Auth.Pincode.Set.Response.success)
            
        } catch {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Pincode Set Request error: \(error.localizedDescription)")
            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Pincode.Set.Response, failure")
            action.send(ModelAction.Auth.Pincode.Set.Response.failure(message: "Невозможно сохранить пин-код в крипто-хранилище. Попробуйте переустановить приложение. В случае, если ошибка повториться, обратитесь в службу поддержки."))
        }
    }
    
    func handleAuthPincodeCheckRequest(payload: ModelAction.Auth.Pincode.Check.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthPincodeCheckRequest")
        
        do {
            
            let storedPincode: String = try keychainAgent.load(type: .pincode)
            
            if payload.pincode == storedPincode {
                
                LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Pincode.Check.Response, correct")
                action.send(ModelAction.Auth.Pincode.Check.Response.correct)
                
            } else {
                
                let remainAttempts = authUnlockAttemptsAvailable - payload.attempt
                if remainAttempts > 0 {
                    
                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Pincode.Check.Response, incorrect, remain attempts: \(remainAttempts)")
                    action.send(ModelAction.Auth.Pincode.Check.Response.incorrect(remain: remainAttempts))
                    
                } else {
                    
                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Pincode.Check.Response, restricted")
                    action.send(ModelAction.Auth.Pincode.Check.Response.restricted)
                }
            }
            
        } catch {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Pincode Check Request Error: \(error.localizedDescription)")
            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Pincode.Check.Response, failure")
            action.send(ModelAction.Auth.Pincode.Check.Response.failure(message: "Невозможно прочитать данные пинкода из крипто-хранилища. Необходимо выйти из аккаунта и заново пройти процедуру авторизации."))
        }
    }
    
    func handleAuthSensorSettings(payload: ModelAction.Auth.Sensor.Settings) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthSensorSettings")
        
        do {
            switch payload {
            case .allow:
                try settingsAgent.store(true, type: .security(.sensor))
                
            case .desideLater:
                try settingsAgent.store(false, type: .security(.sensor))
            }
            
        } catch {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Sensonr Settings Error: \(error.localizedDescription)")

        }
    }
    
    func handleAuthSensorEvaluateRequest(payload: ModelAction.Auth.Sensor.Evaluate.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthSensorEvaluateRequest")
        
        biometricAgent.unlock(with: payload.sensor) { result in
            
            switch result {
            case .success(let isUnlocked):
                if isUnlocked == true {
                    
                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Sensor.Evaluate.Response, success, sensor: \(payload.sensor)")
                    self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.success(payload.sensor))
                    
                } else {
                    
                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Sensor.Evaluate.Response, failure")
                    self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Произошел сбой при попытке разблокировки приложения при помощи сенсора. Попробуйте полностью выгрузить приложение и повторить заново. Если ошибка повториться, обратитесь в службу поддержки."))
                }
                
            case .failure(let error):
                
                switch error {
                case .unableUsePolicy(let error):
                    if let error = error {
                        
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Sensor.Evaluate.Response, failure, error: \(error.localizedDescription)")
                        self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Невозможно ипользовать политику .deviceOwnerAuthenticationWithBiometrics ошибка: \(error.localizedDescription)"))
                        
                    } else {
                        
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Sensor.Evaluate.Response, failure")
                        self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Невозможно ипользовать политику .deviceOwnerAuthenticationWithBiometrics"))
                    }
                    
                case .failedEvaluatePolicyWithError(let error):
                    LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Sensor Evaluate Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleAuthPushRegisterRequest() {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthSensorEvaluateRequest")
        
        Task {
            
            do {
                
                guard let token = token else {
                    handledUnauthorizedCommandAttempt()
                    LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Push.Register.Response, failure")
                    action.send(ModelAction.Auth.Push.Register.Response.failure(ModelAuthError.unauthorizedCommandAttempt))
                    return
                }
               
                try await authPushRegister(token: token)
                LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Push.Register.Response, success")
                action.send(ModelAction.Auth.Push.Register.Response.success)
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Register Request Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Push.Register.Response, failure")
                action.send(ModelAction.Auth.Push.Register.Response.failure(error))
            }
        }
    }
    
    func handleAuthSetDeviceSettings(payload: ModelAction.Auth.SetDeviceSettings.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthSetDeviceSettings")
        
        Task {
            
            do {
                
                guard let credentials = activeCredentials else {
                    handledUnauthorizedCommandAttempt()
                    LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.SetDeviceSettings.Response, failure")
                    action.send(ModelAction.Auth.SetDeviceSettings.Response.failure(ModelAuthError.unauthorizedCommandAttempt))
                    return
                }
               
                try await authSetDeviceSettings(credentials: credentials, sensorType: payload.sensorType)
                LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.SetDeviceSettings.Response, success")
                action.send(ModelAction.Auth.SetDeviceSettings.Response.success)
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Set Device Settings Request Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.SetDeviceSettings.Response, failure, error: \(error.localizedDescription)")
                action.send(ModelAction.Auth.SetDeviceSettings.Response.failure(error))
            }
        }
    }
    
    func handleAuthLoginRequest(payload: ModelAction.Auth.Login.Request) {
        
        LoggerAgent.shared.log(category: .model, message: "handleAuthLoginRequest")
        
        Task {
            
            do {
               
                let credentials = try await authSessionCredentials(restartSession: payload.restartSession)

                let appId = authOperationSystem
                let pushDeviceId = try await authPushDeviceId()
                let pushFcmToken = try await authPushFcmToken()
                let serverDeviceGUID = try authServerDeviceGUID()
                let pincode = try authStoredPincode()
                let loginValue = try pincode.sha256Base64String()
                let type = payload.type.rawValue
                let operationSystemVersion = await authOperationSystemVersion()
                let appVersion = authAppVersion
                
                let cryptoVersion = "1.0"
                let appIdEncrypted = try credentials.csrfAgent.encrypt(appId)
                let pushDeviceIdEncrypted = try credentials.csrfAgent.encrypt(pushDeviceId)
                let pushFcmTokenEncrypted = try credentials.csrfAgent.encrypt(pushFcmToken)
                let serverDeviceGUIDEncrypted = try credentials.csrfAgent.encrypt(serverDeviceGUID)
                let loginValueEncrypted = try credentials.csrfAgent.encrypt(loginValue)
                let typeEncrypted = try credentials.csrfAgent.encrypt(type)
                let operationSystemVersionEncrypted = try credentials.csrfAgent.encrypt(operationSystemVersion)
                let appVersionEncrypted: String? = appVersion != nil ? try credentials.csrfAgent.encrypt(appVersion!) : nil
               
                let command = ServerCommands.Default.Login(token: credentials.token, payload: .init(cryptoVersion: cryptoVersion, appId: appIdEncrypted, pushDeviceId: pushDeviceIdEncrypted, pushFcmToken: pushFcmTokenEncrypted, serverDeviceGUID: serverDeviceGUIDEncrypted, loginValue: loginValueEncrypted, type: typeEncrypted, operationSystemVersion: operationSystemVersionEncrypted, appVersion: appVersionEncrypted))
                LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Login.Response, success")
                            self.action.send(ModelAction.Auth.Login.Response.success)

                        default:
                            
                            self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                            
                            let message = response.errorMessage ?? self.defaultErrorMessage
                            LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Login.Response, failure")
                            self.action.send(ModelAction.Auth.Login.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        
                        self.handleServerCommandError(error: error, command: command)
                        LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Login.Response, failure")
                        self.action.send(ModelAction.Auth.Login.Response.failure(message: self.defaultErrorMessage))
                    }
                }
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Auth Login Request Task Error: \(error.localizedDescription)")
                LoggerAgent.shared.log(level: .error, category: .model, message: "sent ModelAction.Auth.Login.Response, failure")
                self.action.send(ModelAction.Auth.Login.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
}

//MARK: - Helpers

extension Model {
    
    func authCSRF() async throws -> SessionCredentials {
        
        LoggerAgent.shared.log(category: .model, message: "authCSRF")
        
        let command = ServerCommands.UtilityController.Csrf()
        LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
        return try await withCheckedThrowingContinuation({ continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    if let data = response.data {
                        
                        do {
                            
                            let csrfAgent = try CSRFAgent<AESEncryptionAgent>(ECKeysProvider(), data.cert, data.pk)
                            let token = data.token
                            
                            let keyExchangeCommand = ServerCommands.UtilityController.KeyExchange(token: token, payload: .init(data: csrfAgent.publicKeyData, token: token, type: ""))
                            LoggerAgent.shared.log(category: .model, message: "execute command: \(keyExchangeCommand)")
                            self.serverAgent.executeCommand(command: keyExchangeCommand) { result in
                                
                                switch result {
                                case .success(let response):
                                    switch response.statusCode {
                                    case .ok:
                                        let credentials = SessionCredentials(token: token, csrfAgent: csrfAgent)
                                        continuation.resume(with: .success(credentials))
                                        
                                    default:
                                        continuation.resume(with: .failure(CSRFError.unexpected(status: response.statusCode, errorMessage: response.errorMessage)))
                                    }
                                    
                                case .failure(let error):
                                    continuation.resume(with: .failure(CSRFError.serverError(error)))
                                }
                            }
                            
                        } catch {
                            
                            continuation.resume(with: .failure(CSRFError.csrfAgentInitError(error)))
                        }
                        
                    } else {
                        
                        continuation.resume(with: .failure(CSRFError.unexpected(status: response.statusCode, errorMessage: response.errorMessage)))
                    }
                    
                case .failure(let error):
                    continuation.resume(with: .failure((CSRFError.serverError(error))))
                }
            }
        })
    }
    
    func authSessionCredentials(restartSession: Bool = false) async throws -> SessionCredentials {
        
        LoggerAgent.shared.log(category: .model, message: "authSessionCredentials, restartSession: \(restartSession)")
        
        if restartSession == true {
            
            let credentials = try await authCSRF()
            LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Session.Start, success, credentials")
            action.send(ModelAction.Auth.Session.Start.Response(result: .success(credentials)))
            
            return credentials
            
        } else {
           
            if let activeCredentials = activeCredentials {
                
                return activeCredentials
                
            } else {
                
                let credentials = try await authCSRF()
                LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Session.Start, success, credentials")
                action.send(ModelAction.Auth.Session.Start.Response(result: .success(credentials)))
                
                return credentials
            }
        }
    }

    func authPushRegister(token: String) async throws {
        
        LoggerAgent.shared.log(category: .model, message: "authPushRegister")
        
        let pushDeviceId = try await authPushDeviceId()
        let pushFcmToken = try await authPushFcmToken()
        let deviceModel = await authDeviceModel()
        let operationSystemVersion = await authOperationSystemVersion()
        let appVersion = authAppVersion
        
        let command = ServerCommands.PushDeviceController.InstallPushDevice(token: token, payload: .init(cryptoVersion: nil, model: deviceModel, pushDeviceId: pushDeviceId, pushFcmToken: pushFcmToken, operationSystemVersion: operationSystemVersion, appVersion: appVersion))
        
        LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            self.serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        continuation.resume()
                        
                    default:
                        continuation.resume(throwing: ModelAuthError.installPushDeviceFailed(status: response.statusCode, message: response.errorMessage))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    func authSetDeviceSettings(credentials: SessionCredentials, sensorType: BiometricSensorType?) async throws {
        
        LoggerAgent.shared.log(category: .model, message: "authSetDeviceSettings")
        
        let pushDeviceId = try await authPushDeviceId()
        let pushFcmToken = try await authPushFcmToken()
        let serverDeviceGUID = try authServerDeviceGUID()
        let pincode = try authStoredPincode()
        let loginValue = try pincode.sha256Base64String()
        
        let command = try ServerCommands.RegistrationContoller.SetDeviceSettings(credentials: credentials, pushDeviceId: pushDeviceId, pushFcmToken: pushFcmToken, serverDeviceGUID: serverDeviceGUID, loginValue: loginValue, availableSensorType: sensorType, isSensorEnabled: authIsBiometricSensorEnabled)
        
        LoggerAgent.shared.log(category: .model, message: "execute command: \(command)")
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            self.serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        continuation.resume()
                        
                    default:
                        continuation.resume(throwing: ModelAuthError.setDeviceSettingsFailed(status: response.statusCode, message: response.errorMessage))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
}

extension Model {
    
    func authPushDeviceId() async throws -> String {
        
        guard let identifierForVendor = await UIDevice.current.identifierForVendor?.uuidString else {
            throw ModelAuthError.identifierForVendorObtainFailed
        }
        
        return identifierForVendor
    }
    
    func authPushFcmToken() async throws -> String {
        
        guard let fcmToken = Messaging.messaging().fcmToken else {
           throw ModelAuthError.fcmTokenObtainFailed
        }
        
        return fcmToken
    }
    
    func authDeviceModel() async -> String {
        
        return await UIDevice.current.model
    }
    
    func authOperationSystemVersion() async -> String {
        
        return await UIDevice.current.systemVersion
    }
    
    var authAppVersion: String? { Bundle.main.releaseVersionNumber }
    var authOperationSystem: String { "IOS" }
}

//MARK: - Errors

enum ModelAuthError: Error {
    
    case unauthorizedCommandAttempt
    case emptyCSRFData(status: ServerStatusCode, message: String?)
    case identifierForVendorObtainFailed
    case fcmTokenObtainFailed
    case installPushDeviceFailed(status: ServerStatusCode, message: String?)
    case keyExchangeFailed(status: ServerStatusCode, message: String?)
    case checkClientFailed(status: ServerStatusCode, message: String?)
    case setDeviceSettingsFailed(status: ServerStatusCode, message: String?)
}


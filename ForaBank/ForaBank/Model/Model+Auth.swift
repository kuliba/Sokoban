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
                let isFreshSessionRequired: Bool
                
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
    
    var authDefaultErrorMessage: String { "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения." }
        
    func authStoredPincode() throws -> String {
        
        try keychainAgent.load(type: .pincode)
    }
    
    func authServerDeviceGUID() throws -> String {
        
       try keychainAgent.load(type: .serverDeviceGUID)
    }
    
    var authIsCredentialsStored: Bool {
        
        do {
            
            let _ = try authStoredPincode()
            let _ = try authServerDeviceGUID()
            
            return true
            
        } catch {
            
            return false
        }
    }
}

//MARK: - Handlers

internal extension Model {
    
    func handleAuthSessionStartRequest() {
        
        Task {
            
            do {
                
                let credentials = try await authCSRF()
                self.action.send(ModelAction.Auth.Session.Start.Response(result: .success(credentials)))
                
            } catch {
                
                self.action.send(ModelAction.Auth.Session.Start.Response(result: .failure(error)))
            }
        }
    }
    
    func handleAuthSessionExtendRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.UtilityController.GetSessionTimeout(token: token)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let duration = response.data else {
                        
                        //TODO: handle error
                        return
                    }
                    self.action.send(ModelAction.Auth.Session.Extend.Response(result: .success(TimeInterval(duration))))
                    
                default:
                    break
                    //TODO: handle error
                }

            case .failure(let error):
                self.action.send(ModelAction.Auth.Session.Extend.Response(result: .failure(error)))
            }
        }
    }
    
    func handleAuthCheckClientRequest(payload: ModelAction.Auth.CheckClient.Request) {
        
        print("SessionAgent: CHECK REQUESTED")
        
        Task {
            
            do {
                
                let credentials = try await authGetOrStartSession()
                try await authPushRegister(token: credentials.token)
                let encryptedNumber = try credentials.csrfAgent.encrypt(payload.number)
                let cryptoVersion = "1.0"
                
                let command = ServerCommands.RegistrationContoller.CheckClient(token: credentials.token, payload: .init(cardNumber: encryptedNumber, cryptoVersion: cryptoVersion))
                self.serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        if let data = response.data {
                            
                            do {
                                
                                let decryptedPhone = try credentials.csrfAgent.decrypt(data.phone)
                                self.action.send(ModelAction.Auth.CheckClient.Response.success(codeLength: self.authVerificationCodeLength, phone: decryptedPhone, resendCodeDelay: self.authVerificationCodeResendDelay))
                                print("SessionAgent: CHECK REQUEST COMPLETE")
                                
                            } catch {
                                
                                //TODO: log error
                                print("Model: handleAuthCheckClientRequest: decrypt phone error \(error.localizedDescription)")
                                
                                self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: self.authDefaultErrorMessage))
                            }
                            
                        } else {
                            
                            //TODO: log error
                            print("Model: handleAuthCheckClientRequest: empty data status \(response.statusCode), message: \(String(describing: response.errorMessage))")
                            
                            let message = response.errorMessage ?? self.authDefaultErrorMessage
                            self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        //TODO: log error
                        print("Model: handleAuthCheckClientRequest: error \(error.localizedDescription)")
                        
                        self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: self.authDefaultErrorMessage))
                    }
                }

            } catch {
                
                //TODO: log error
                print("Model: handleAuthCheckClientRequest: error: \(error.localizedDescription)")
                
                self.action.send(ModelAction.Auth.CheckClient.Response.failure(message: self.authDefaultErrorMessage))
            }
        }
    }
    
    func handleAuthVerificationCodeConfirmRequest(payload: ModelAction.Auth.VerificationCode.Confirm.Request) {
        
        Task {
            
            do {
                
                let credentials = try await authGetOrStartSession()
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
                            self.auth.value = .registerRequired
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
                print("Model: handleAuthVerificationCodeConfirmRequest: error \(error.localizedDescription)")
                
                self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.authDefaultErrorMessage))
            }
        }
    }
    
    func handleAuthVerificationCodeResendRequest(payload: ModelAction.Auth.VerificationCode.Resend.Request) {
        
        Task {
            
            do {
                
                let credentials = try await authGetOrStartSession()
                let command = ServerCommands.RegistrationContoller.GetCode(token: credentials.token)
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.success)
                            
                        case .serverError:
                            let message = response.errorMessage ?? "Вы исчерпали все попытки :("
                            self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.restricted(message: message))
                            
                        default:
                            
                            //TODO: log error
                            print("Model: handleAuthVerificationCodeResendRequest: data status \(response.statusCode), message: \(String(describing: response.errorMessage))")
                            
                            let message = response.errorMessage ?? self.authDefaultErrorMessage
                            self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        
                        //TODO: log error
                        print("Model: handleAuthVerificationCodeResendRequest: error \(error.localizedDescription)")
                        
                        self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.failure(message: self.authDefaultErrorMessage))
                    }
                }
                
            } catch {
               
                //TODO: log error
                print("Model: handleAuthVerificationCodeResendRequest: error \(error.localizedDescription)")
                
                self.action.send(ModelAction.Auth.VerificationCode.Resend.Response.failure(message: self.authDefaultErrorMessage))
            }
        }
    }
    
    func handleAuthRegisterRequest() {
        
        print("log: model: REGISTER REQUESTED")
        
        Task {
            
            do {
                
                let credentials = try await authGetOrStartSession()
                
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
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            if let encryptedData = response.data {
                                
                                do {
                                    
                                    let serverDeviceGUID = try credentials.csrfAgent.decrypt(encryptedData)
                                    try self.keychainAgent.store(serverDeviceGUID, type: .serverDeviceGUID)
                                    self.action.send(ModelAction.Auth.Register.Response.success(serverDeviceGUID: serverDeviceGUID))
                                    
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
                            
                        default:
                            
                            //TODO: log error
                            print("Model: handleAuthRegisterRequest: data status \(response.statusCode), message: \(String(describing: response.errorMessage))")
                            
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
                print("Model: handleAuthRegisterRequest: error \(error.localizedDescription)")
                
                self.action.send(ModelAction.Auth.VerificationCode.Confirm.Response.failure(message: self.authDefaultErrorMessage))
            }
        }
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
                    
                    self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.success(payload.sensor))
                    
                } else {
                    
                    self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Произошел сбой при попытке разблокировки приложения при помощи сенсора. Попробуйте полностью выгрузить приложение и повторить заново. Если ошибка повториться, обратитесь в службу поддержки."))
                }
                
            case .failure(let error):
                
                switch error {
                case .unableUsePolicy(let error):
                    if let error = error {
                        
                        self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Невозможно ипользовать политику .deviceOwnerAuthenticationWithBiometrics ошибка: \(error.localizedDescription)"))
                        
                    } else {
                        
                        self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "Невозможно ипользовать политику .deviceOwnerAuthenticationWithBiometrics"))
                    }
                    
                case .failedEvaluatePolicyWithError(let error):
  
                    //MARK: remove error from cancel biometric auth
                    
                    //self.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: "При попытке авторизации через сенсор возникла ошибка: \(error.localizedDescription)"))
                    print("Model: failedEvaluatePolicyWithError: error \(error.localizedDescription)")

                }
            }
        }
    }
    
    func handleAuthPushRegisterRequest() {
        
        Task {
            
            do {
                
                guard let token = token else {
                    handledUnauthorizedCommandAttempt()
                    action.send(ModelAction.Auth.Push.Register.Response.failure(ModelAuthError.unauthorizedCommandAttempt))
                    return
                }
               
                try await authPushRegister(token: token)
                action.send(ModelAction.Auth.Push.Register.Response.success)
                
            } catch {
                
                action.send(ModelAction.Auth.Push.Register.Response.failure(error))
            }
        }
    }
    
    func handleAuthSetDeviceSettings(payload: ModelAction.Auth.SetDeviceSettings.Request) {
        
        Task {
            
            do {
                
                guard let credentials = credentials else {
                    handledUnauthorizedCommandAttempt()
                    action.send(ModelAction.Auth.SetDeviceSettings.Response.failure(ModelAuthError.unauthorizedCommandAttempt))
                    return
                }
               
                try await authSetDeviceSettings(credentials: credentials, sensorType: payload.sensorType)
                action.send(ModelAction.Auth.SetDeviceSettings.Response.success)
                
            } catch {
                
                action.send(ModelAction.Auth.SetDeviceSettings.Response.failure(error))
            }
        }
    }
    
    func handleAuthLoginRequest(payload: ModelAction.Auth.Login.Request) {
        
        print("log: model: LOGIN REQUESTED")
        
        Task {
            
            do {
               
                let credentials = try await authGetOrStartSession(isFreshSessionRequired: payload.isFreshSessionRequired)

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
                serverAgent.executeCommand(command: command) { result in
                    
                    switch result {
                    case .success(let response):
                        switch response.statusCode {
                        case .ok:
                            self.action.send(ModelAction.Auth.Login.Response.success)

                        default:
                            
                            //TODO: log error
                            print("Model: handleAuthLoginRequest: data status \(response.statusCode), message: \(String(describing: response.errorMessage))")
                            
                            let message = response.errorMessage ?? self.authDefaultErrorMessage
                            self.action.send(ModelAction.Auth.Login.Response.failure(message: message))
                        }
                        
                    case .failure(let error):
                        
                        //TODO: log error
                        print("Model: handleAuthLoginRequest: error \(error.localizedDescription)")
                        
                        self.action.send(ModelAction.Auth.Login.Response.failure(message: self.authDefaultErrorMessage))
                    }
                }
                
            } catch {
                
                //TODO: log error
                print("Model: handleAuthRegisterRequest: error \(error.localizedDescription)")
                
                self.action.send(ModelAction.Auth.Login.Response.failure(message: self.authDefaultErrorMessage))
            }
        }
    }
}

//MARK: - Helpers

extension Model {
    
    func authCSRF() async throws -> SessionCredentials {
        
        let command = ServerCommands.UtilityController.Csrf()
        return try await withCheckedThrowingContinuation({ continuation in
            
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
    
    func authGetOrStartSession(isFreshSessionRequired: Bool = false) async throws -> SessionCredentials {
        
        if isFreshSessionRequired == true {
            
            let credentials = try await authCSRF()
            action.send(ModelAction.Auth.Session.Start.Response(result: .success(credentials)))
            
            return credentials
            
        } else {
           
            if let credentials = credentials {
                
                return credentials
                
            } else {
                
                let credentials = try await authCSRF()
                action.send(ModelAction.Auth.Session.Start.Response(result: .success(credentials)))
                
                return credentials
            }
        }
    }

    func authPushRegister(token: String) async throws {
        
        let pushDeviceId = try await authPushDeviceId()
        let pushFcmToken = try await authPushFcmToken()
        let deviceModel = await authDeviceModel()
        let operationSystemVersion = await authOperationSystemVersion()
        let appVersion = authAppVersion
        
        let command = ServerCommands.PushDeviceController.InstallPushDevice(token: token, payload: .init(cryptoVersion: nil, model: deviceModel, pushDeviceId: pushDeviceId, pushFcmToken: pushFcmToken, operationSystemVersion: operationSystemVersion, appVersion: appVersion))
        
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
    
    func authSetDeviceSettings(credentials: SessionCredentials) async throws {
        
        print("SessionAgent: SET DEVICE SETTINGS: REQUESTED")
        
        let pushDeviceId = try await authPushDeviceId()
        let pushFcmToken = try await authPushFcmToken()
        let serverDeviceGUID = try authServerDeviceGUID()
        let pincode = try authStoredPincode()
        let loginValue = try pincode.sha256Base64String()
        
        let command = try ServerCommands.RegistrationContoller.SetDeviceSettings(credentials: credentials, pushDeviceId: pushDeviceId, pushFcmToken: pushFcmToken, serverDeviceGUID: serverDeviceGUID, loginValue: loginValue, availableSensorType: authAvailableBiometricSensorType, isSensorEnabled: authIsBiometricSensorEnabled)
        
        print("SessionAgent: SET DEVICE SETTINGS: COMMAND OK")
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            self.serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        continuation.resume()
                        print("SessionAgent: SET DEVICE SETTINGS: OK")
                        
                    default:
                        continuation.resume(throwing: ModelAuthError.setDeviceSettingsFailed(status: response.statusCode, message: response.errorMessage))
                        print("SessionAgent: SET DEVICE SETTINGS: FAIL \(response.statusCode), \(response.errorMessage)")
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("SessionAgent: SET DEVICE SETTINGS: FAIL \(error.localizedDescription)")
                }
            }
        })
    }
    
    func authSetDeviceSettings(credentials: SessionCredentials, sensorType: BiometricSensorType?) async throws {
        
        print("SessionAgent: SET DEVICE SETTINGS: REQUESTED")
        
        let pushDeviceId = try await authPushDeviceId()
        let pushFcmToken = try await authPushFcmToken()
        let serverDeviceGUID = try authServerDeviceGUID()
        let pincode = try authStoredPincode()
        let loginValue = try pincode.sha256Base64String()
        let command = try ServerCommands.RegistrationContoller.SetDeviceSettings(credentials: credentials, pushDeviceId: pushDeviceId, pushFcmToken: pushFcmToken, serverDeviceGUID: serverDeviceGUID, loginValue: loginValue, availableSensorType: sensorType, isSensorEnabled: authIsBiometricSensorEnabled)
        
        print("SessionAgent: SET DEVICE SETTINGS: COMMAND OK")
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            self.serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        continuation.resume()
                        print("SessionAgent: SET DEVICE SETTINGS: OK")
                        
                    default:
                        continuation.resume(throwing: ModelAuthError.setDeviceSettingsFailed(status: response.statusCode, message: response.errorMessage))
                        print("SessionAgent: SET DEVICE SETTINGS: FAIL \(response.statusCode), \(response.errorMessage)")
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("SessionAgent: SET DEVICE SETTINGS: FAIL \(error.localizedDescription)")
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


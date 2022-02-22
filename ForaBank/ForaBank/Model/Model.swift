//
//  Model.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation
import Combine
import os

class Model {
    
    //MARK: Templates
    let action: PassthroughSubject<Action, Never>
    let auth: CurrentValueSubject<AuthorizationState, Never>
    
    //MARK: Dictionaries

    
    //MARK: Templates
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    //TODO: store in cache 
    let paymentTemplatesViewSettings: CurrentValueSubject<TemplatesListViewModel.Settings, Never>
    
    //TODO: remove when all templates will be implemented
    let paymentTemplatesAllowed: [ProductStatementData.Kind] = [.sfp, .insideBank, .betweenTheir, .direct, .contactAddressless]
    let paymentTemplatesDisplayed: [PaymentTemplateData.Kind] = [.sfp, .byPhone, .insideBank, .betweenTheir, .direct, .contactAdressless]
    
    // services
    private let serverAgent: ServerAgentProtocol
    private let localAgent: LocalAgentProtocol
    
    // private
    private var bindings: Set<AnyCancellable>
    private let queue = DispatchQueue(label: "ru.forabank.sense.model", qos: .userInitiated, attributes: .concurrent)
    private var token: String? {
        
        guard case .authorized(let token) = auth.value else {
            return nil
        }
        
        return token
    }
    
    init(serverAgent: ServerAgentProtocol, localAgent: LocalAgentProtocol) {
        
        self.action = .init()
        self.auth = .init(.notAuthorized)
        self.paymentTemplates = .init([])
        self.paymentTemplatesViewSettings = .init(.initial)
        self.serverAgent = serverAgent
        self.localAgent = localAgent
        self.bindings = []
        
        loadCachedData()
        bind()
    }
    
    //FIXME: remove after refactoring
    static var shared: Model = {
       
        // server agent
        #if DEBUG
        let serverContext = ServerAgent.Context(for: .test)
        #else
        let serverContext = ServerAgent.Context(for: .prod)
        #endif
        
        let serverAgent = ServerAgent(context: serverContext)
        
        // local agent
        let localContext = LocalAgent.Context(cacheFolderName: "cache", encoder: .serverDate, decoder: .serverDate, fileManager: FileManager.default)
        let localAgent = LocalAgent(context: localContext)
        
        return Model(serverAgent: serverAgent, localAgent: localAgent)
    }()
    
    private func bind() {
        
        //FIXME: remove after refactoring
        CSRFToken.tokenPublisher
            .receive(on: queue)
            .sink {[unowned self] token in
                
                if let token = token {
                    
                    auth.value = .authorized(token: token)
                    
                } else {
                    
                    auth.value = .notAuthorized
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: queue)
            .sink {[unowned self] action in
                
                switch action {
                
                //MARK: - Auth Actions
                
                //FIXME: - remove after refactoring login screens
                case _ as ModelAction.LoggedIn:
                    loadCachedData()
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                
                //FIXME: - remove after refactoring login screens
                case _ as ModelAction.LoggedOut:
                    clearCachedData()
                    paymentTemplates.value = []
                    
                case let payload as ModelAction.Auth.Register.Request:
                    handleAuthRegisterRequest(payload: payload)
                
                case let payload as ModelAction.Auth.VerificationCode.Confirm.Request:
                    handleAuthVerificationCodeConfirmRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.VerificationCode.Resend.Request:
                    handleAuthVerificationCodeResendRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.Pincode.Set.Request:
                    handleAuthPincodeSetRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.Pincode.Check.Request:
                    handleAuthPincodeCheckRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.Sensor.Settings:
                    handleAuthSensorSettings(payload: payload)
                    
                case let payload as ModelAction.Auth.Sensor.Evaluate.Request:
                    handleAuthSensorEvaluateRequest(payload: payload)
                    
                case _ as ModelAction.Auth.Login.Request:
                    handleAuthLoginRequest()

                //MARK: - Templates Actions
                    
                case let payload as ModelAction.PaymentTemplate.Save.Requested:
                    guard let token = token else {
                        //TODO: handle not authoried server request attempt
                        return
                    }
                    let command = ServerCommands.PaymentTemplateController.SavePaymentTemplate(token: token, payload: .init(name: payload.name, paymentOperationDetailId: payload.paymentOperationDetailId))
                    serverAgent.executeCommand(command: command) { result in
                        
                        switch result {
                        case .success(let response):
                            switch response.statusCode {
                            case .ok:
                                // confirm template saved
                                self.action.send(ModelAction.PaymentTemplate.Save.Complete(paymentTemplateId: response.data.paymentTemplateId))
                                // request all templates from server
                                self.action.send(ModelAction.PaymentTemplate.List.Requested())
                                
                            default:
                                //TODO: handle not ok server status
                                return
                            }
                        case .failure(let error):
                            self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
                        }
                    }
                    
                case let payload as ModelAction.PaymentTemplate.Update.Requested:
                    guard let token = token else {
                        //TODO: handle not authoried server request attempt
                        return
                    }
                    let command = ServerCommands.PaymentTemplateController.UpdatePaymentTemplate(token: token, payload: .init(name: payload.name, parameterList: payload.parameterList, paymentTemplateId: payload.paymentTemplateId))
                    serverAgent.executeCommand(command: command) { result in
                        
                        switch result {
                        case .success(let response):
                            switch response.statusCode {
                            case .ok:
                                // confirm template updated
                                self.action.send(ModelAction.PaymentTemplate.Update.Complete())
                                // request all templates from server
                                self.action.send(ModelAction.PaymentTemplate.List.Requested())
                                
                            default:
                                //TODO: handle not ok server status
                                return
                            }
                        case .failure(let error):
                            self.action.send(ModelAction.PaymentTemplate.Update.Failed(error: error))
                        }
                    }
                    
                case let payload as ModelAction.PaymentTemplate.Delete.Requested:
                    guard let token = token else {
                        //TODO: handle not authoried server request attempt
                        return
                    }
                    let command = ServerCommands.PaymentTemplateController.DeletePaymentTemplates(token: token, payload: .init(paymentTemplateIdList: payload.paymentTemplateIdList))
                    serverAgent.executeCommand(command: command) { result in
                        
                        switch result {
                        case .success(let response):
                            switch response.statusCode {
                            case .ok:
                                // confirm templete deleted
                                self.action.send(ModelAction.PaymentTemplate.Delete.Complete())
                                // request all templates from server
                                self.action.send(ModelAction.PaymentTemplate.List.Requested())
                                
                            default:
                                //TODO: handle not ok server status
                                return
                            }
                        case .failure(let error):
                            self.action.send(ModelAction.PaymentTemplate.Delete.Failed(error: error))
                        }
                    }
                    
                case _ as ModelAction.PaymentTemplate.List.Requested:
                    guard let token = token else {
                        //TODO: handle not authoried server request attempt
                        return
                    }
                    let command = ServerCommands.PaymentTemplateController.GetPaymentTemplateList(token: token)
                    serverAgent.executeCommand(command: command) { result in
                        
                        switch result {
                        case .success(let response):
                            switch response.statusCode {
                            case .ok:
                                if let templates = response.data {
                                    
                                    //TODO: remove when all templates will be implemented
                                    let allowed = templates.filter{ paymentTemplatesDisplayed.contains($0.type) }
                                    self.paymentTemplates.value = allowed
                                    do {
                                        
                                        try self.localAgent.store(allowed, serial: nil)
                                        
                                    } catch {
                                        //TODO: os log
                                        print(error.localizedDescription)
                                    }
                                    self.action.send(ModelAction.PaymentTemplate.List.Complete(paymentTemplates: templates))
                                    
                                } else {
                                    
                                    self.paymentTemplates.value = []
                                    //TODO: delete cache data
                                    self.action.send(ModelAction.PaymentTemplate.List.Complete(paymentTemplates: []))
                                }

                            default:
                                //TODO: handle not ok server status
                                return
                            }
                        case .failure(let error):
                            self.action.send(ModelAction.PaymentTemplate.List.Failed(error: error))
                        }
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Private Helpers

private extension Model {
    
    func loadCachedData() {
        
        if let paymentTemplates = localAgent.load(type: [PaymentTemplateData].self) {
            
            self.paymentTemplates.value = paymentTemplates
        }
        
        //TODO: load paymentTemplatesViewSettings from cache
    }
    
    func clearCachedData() {
        
        do {
            
            try localAgent.clear(type: PaymentTemplateData.self)
            
        } catch {
            
            print("Model: clearCachedData: error: \(error.localizedDescription)")
        }
    }
}

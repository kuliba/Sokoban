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
    
    // interface
    let action: PassthroughSubject<Action, Never>
    let auth: CurrentValueSubject<AuthorizationState, Never>
    // services
    private let serverAgent: ServerAgentProtocol
    
    // private
    private var bindings: Set<AnyCancellable>
    private let queue = DispatchQueue(label: "ru.forabank.sense.model", qos: .userInitiated, attributes: .concurrent)
    private var token: String? {
        
        guard case .authorized(let token) = auth.value else {
            return nil
        }
        
        return token
    }
    
    init(serverAgent: ServerAgentProtocol) {
        
        self.action = .init()
        self.auth = .init(.notAuthorized)
        self.serverAgent = serverAgent
        self.bindings = []
        
        bind()
    }
    
    //FIXME: remove after refactoring
    static var shared: Model = {
       
//        #if DEBUG
        let context = ServerAgent.Context(for: .test)
//        #else
//        let context = ServerAgent.Context(for: .prod)
//        #endif
        
        let serverAgent = ServerAgent(context: context)
        
        return Model(serverAgent: serverAgent)
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
                                self.action.send(ModelAction.PaymentTemplate.Save.Complete(paymentTemplateId: response.data.paymentTemplateId))
                                
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
                                self.action.send(ModelAction.PaymentTemplate.Update.Complete())
                                
                            default:
                                //TODO: handle not ok server status
                                return
                            }
                        case .failure(let error):
                            self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
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
                                self.action.send(ModelAction.PaymentTemplate.Delete.Complete())
                                
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
                                self.action.send(ModelAction.PaymentTemplate.List.Complete(paymentTemplates: response.data))
                                
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


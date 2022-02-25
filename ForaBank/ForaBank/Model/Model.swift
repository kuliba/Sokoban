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
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    //TODO: store in cache 
    let paymentTemplatesViewSettings: CurrentValueSubject<TemplatesListViewModel.Settings, Never>
    
    //TODO: remove when all templates will be implemented
    let paymentTemplatesAllowed: [ProductStatementData.Kind] = [.sfp, .insideBank]
    let paymentTemplatesDisplayed: [PaymentTemplateData.Kind] = [.sfp, .byPhone, .insideBank]
    
    // services
    internal let serverAgent: ServerAgentProtocol
    internal let localAgent: LocalAgentProtocol
    
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
        requestDictionariesFromServer()
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
                
                //MARK: - Login Actions
                    
                case _ as ModelAction.LoggedIn:
                    loadCachedData()
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                case _ as ModelAction.LoggedOut:
                    clearCachedData()
                    paymentTemplates.value = []
                    
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
                    
                //MARK: - Dictionaries Actions
                case let payload as ModelAction.Dictionary.Request:
                    switch payload.type {
                    case .anywayOperators:
                        handleDictionaryAnywayOperatorsRequest(payload)
                        
                    case .banks:
                        handleDictionaryBanks(payload)
                        
                    case .countries:
                        handleDictionaryCountries(payload)
                        
                    case .currencyList:
                        handleDictionaryCurrencyList(payload)
                        
                    case .fmsList:
                        handleDictionaryFMSList(payload)
                        
                    case .fsspDebtList:
                        handleDictionaryFSSPDebtList(payload)
                        
                    case .fsspDocumentList:
                        handleDictionaryFSSPDocumentList(payload)
                        
                    case .ftsList:
                        handleDictionaryFTSList(payload)
                        
                    case .fullBankInfoList:
                        handleDictionaryFullBankInfoList(payload)
                        
                    case .mobileList:
                        handleDictionaryMobileList(payload)
                        
                    case .mosParkingList:
                        handleDictionaryMosParkingList(payload)
                        
                    case .paymentSystemList:
                        handleDictionaryPaymentSystemList(payload)
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Private Helpers

private extension Model {
    
    func requestDictionariesFromServer() {
        
        for type in ModelAction.Dictionary.Kind.allCases {
            
            action.send(ModelAction.Dictionary.Request(type: type, serial: serial(for: type)))
        }
    }
    
    func serial(for dictionaryType: ModelAction.Dictionary.Kind) -> String? {
        
        switch dictionaryType {
        case .anywayOperators:
            return localAgent.serial(for: [OperatorGroupData].self)
            
        case .banks:
            return localAgent.serial(for: [BankData].self)
            
        case .countries:
            return localAgent.serial(for: [CountryData].self)
            
        case .currencyList:
            return localAgent.serial(for: [CurrencyData].self)
            
        case .fmsList:
            return localAgent.serial(for: [FMSData].self)
            
        case .fsspDebtList:
            return localAgent.serial(for: [FSSPDebtData].self)
            
        case .fsspDocumentList:
            return localAgent.serial(for: [FSSPDocumentData].self)
            
        case .ftsList:
            return localAgent.serial(for: [FTSData].self)
            
        case .fullBankInfoList:
            return localAgent.serial(for: [BankFullInfoData].self)
            
        case .mobileList:
            return localAgent.serial(for: [MobileData].self)
            
        case .mosParkingList:
            return localAgent.serial(for: [MosParkingData].self)
            
        case .paymentSystemList:
            return localAgent.serial(for: [PaymentSystemData].self)
        }
    }
    
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

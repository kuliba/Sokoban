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
    let catalogProducts: CurrentValueSubject<[CatalogProductData], Never>
    
    //MARK: Templates
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    //TODO: store in cache 
    let paymentTemplatesViewSettings: CurrentValueSubject<TemplatesListViewModel.Settings, Never>
    
    //TODO: remove when all templates will be implemented
    let paymentTemplatesAllowed: [ProductStatementData.Kind] = [.sfp, .insideBank, .betweenTheir, .direct, .contactAddressless]
    let paymentTemplatesDisplayed: [PaymentTemplateData.Kind] = [.sfp, .byPhone, .insideBank, .betweenTheir, .direct, .contactAdressless]
    
    // services
    internal let serverAgent: ServerAgentProtocol
    internal let localAgent: LocalAgentProtocol
    internal let keychainAgent: KeychainAgentProtocol
    internal let settingsAgent: SettingsAgentProtocol
    
    // private
    private var bindings: Set<AnyCancellable>
    private let queue = DispatchQueue(label: "ru.forabank.sense.model", qos: .userInitiated, attributes: .concurrent)
    internal var token: String? {
        
        guard case .authorized(let token) = auth.value else {
            return nil
        }
        
        return token
    }
    
    init(serverAgent: ServerAgentProtocol, localAgent: LocalAgentProtocol, keychainAgent: KeychainAgentProtocol, settingsAgent: SettingsAgentProtocol) {
        
        self.action = .init()
        self.auth = .init(.notAuthorized)
        self.catalogProducts = .init([])
        self.paymentTemplates = .init([])
        self.paymentTemplatesViewSettings = .init(.initial)
        self.serverAgent = serverAgent
        self.localAgent = localAgent
        self.keychainAgent = keychainAgent
        self.settingsAgent = settingsAgent
        self.bindings = []
        
        loadCachedData()
        bind()
        cacheDictionaries()
    }
    
    //FIXME: remove after refactoring
    static var shared: Model = {
       
        // server agent
        #if DEBUG
        let enviroment = ServerAgent.Environment.test
        #else
        let enviroment = ServerAgent.Environment.prod
        #endif
        
        let serverAgent = ServerAgent(enviroment: enviroment)
        
        // local agent
        let localContext = LocalAgent.Context(cacheFolderName: "cache", encoder: .serverDate, decoder: .serverDate, fileManager: FileManager.default)
        let localAgent = LocalAgent(context: localContext)
        
        // keychain agent
        let keychainAgent = KeychainAgentMock()
        
        // settings agent
        let settingsAgent = SettingsAgentMock()
        
        return Model(serverAgent: serverAgent, localAgent: localAgent, keychainAgent: keychainAgent, settingsAgent: settingsAgent)
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
                    
                case let payload as ModelAction.Auth.ProductImage.Request:
                    handleAuthProductImageRequest(payload)
                    
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
                    
                case _ as ModelAction.Auth.Logout:
                    handleAuthLogoutRequest()

                //MARK: - Templates Actions
                    
                case _ as ModelAction.PaymentTemplate.List.Requested:
                    handleTemplatesListRequest()
                    
                case let payload as ModelAction.PaymentTemplate.Save.Requested:
                    handleTemplatesSaveRequest(payload)
                    
                case let payload as ModelAction.PaymentTemplate.Update.Requested:
                    handleTemplatesUpdateRequest(payload)
                    
                case let payload as ModelAction.PaymentTemplate.Delete.Requested:
                   handleTemplatesDeleteRequest(payload)
                    
                    
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
                        
                    case .productCatalogList:
                        handleDictionaryProductCatalogList(payload)
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Private Helpers

private extension Model {
    
    func cacheDictionaries() {
        
        for type in ModelAction.Dictionary.cached {
            
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
            
        case .productCatalogList:
            return localAgent.serial(for: [CatalogProductData].self)
        }
    }
    
    func loadCachedData() {
        
        if let catalogProducts = localAgent.load(type: [CatalogProductData].self) {
            
            self.catalogProducts.value = catalogProducts
        }
        
        if let paymentTemplates = localAgent.load(type: [PaymentTemplateData].self) {
            
            self.paymentTemplates.value = paymentTemplates
        }
    }
    
    func clearCachedData() {
        
        do {
            
            try localAgent.clear(type: PaymentTemplateData.self)
            
        } catch {
            
            print("Model: clearCachedData: error: \(error.localizedDescription)")
        }
    }
}

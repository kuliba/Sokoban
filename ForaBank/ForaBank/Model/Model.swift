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
    
    //MARK: Products
    
    //MARK: Templates
    let action: PassthroughSubject<Action, Never>
    let auth: CurrentValueSubject<AuthorizationState, Never>
    
    //MARK: Products
    let products: CurrentValueSubject<[ProductType: [ProductData]], Never>
    let productsUpdateState: CurrentValueSubject<ProductsUpdateState, Never>
    var productsAllowed: Set<ProductType> { [.card, .account, .deposit] }
    
    //MARK: Dictionaries
    let catalogProducts: CurrentValueSubject<[CatalogProductData], Never>
    let catalogBanners: CurrentValueSubject<[BannerCatalogListData], Never>
    
    //MARK: Templates
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    //TODO: store in cache 
    let paymentTemplatesViewSettings: CurrentValueSubject<TemplatesListViewModel.Settings, Never>
    
    //TODO: remove when all templates will be implemented
    let paymentTemplatesAllowed: [ProductStatementData.Kind] = [.sfp, .insideBank, .betweenTheir, .direct, .contactAddressless, .externalIndivudual, .externalEntity, .mobile]
    let paymentTemplatesDisplayed: [PaymentTemplateData.Kind] = [.sfp, .byPhone, .insideBank, .betweenTheir, .direct, .contactAdressless, .externalIndividual, .externalEntity, .mobile]
    
    // services
    internal let sessionAgent: SessionAgentProtocol
    internal let serverAgent: ServerAgentProtocol
    internal let localAgent: LocalAgentProtocol
    internal let keychainAgent: KeychainAgentProtocol
    internal let settingsAgent: SettingsAgentProtocol
    internal let biometricAgent: BiometricAgentProtocol
    
    // private
    private var bindings: Set<AnyCancellable>
    private let queue = DispatchQueue(label: "ru.forabank.sense.model", qos: .userInitiated, attributes: .concurrent)
    internal var token: String? {
        
        guard case .active(_, let credentials) = sessionAgent.sessionState.value else {
            return nil
        }
        
        return credentials.token
    }
    
    internal var credentials: SessionCredentials? {
        
        guard case .active(_, let credentials) = sessionAgent.sessionState.value else {
            return nil
        }
        
        return credentials
    }
    
    init(sessionAgent: SessionAgentProtocol, serverAgent: ServerAgentProtocol, localAgent: LocalAgentProtocol, keychainAgent: KeychainAgentProtocol, settingsAgent: SettingsAgentProtocol, biometricAgent: BiometricAgentProtocol) {
        
        self.action = .init()
        self.auth = .init(.registerRequired)
        self.products = .init([:])
        self.productsUpdateState = .init(.idle)
        self.catalogProducts = .init([])
        self.catalogBanners = .init([])
        self.paymentTemplates = .init([])
        self.paymentTemplatesViewSettings = .init(.initial)
        self.sessionAgent = sessionAgent
        self.serverAgent = serverAgent
        self.localAgent = localAgent
        self.keychainAgent = keychainAgent
        self.settingsAgent = settingsAgent
        self.biometricAgent = biometricAgent
        self.bindings = []
         
        loadCachedData()
        bind()
        cacheDictionaries()
    }
    
    //FIXME: remove after refactoring
    static var shared: Model = {
        
        // session agent
        let sessionAgent = SessionAgent()
       
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
        let keychainAgent = ValetKeychainAgent(valetName: "ru.forabank.sense.valet")
        
        // settings agent
        let settingsAgent = UserDefaultsSettingsAgent()
        
        // biometric agent
        let biometricAgent = BiometricAgent()
        
        return Model(sessionAgent: sessionAgent, serverAgent: serverAgent, localAgent: localAgent, keychainAgent: keychainAgent, settingsAgent: settingsAgent, biometricAgent: biometricAgent)
    }()
    
    private func bind() {
        
        sessionAgent.sessionState
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] auth in
                
                switch auth {
                case .inactive:
                    if let pincode = try? authStoredPincode() {
                        
                        self.auth.value = .signInRequired(pincode: pincode)
                        
                    } else {
                        
                        self.auth.value = .registerRequired
                    }
                    
                case .expired:
                    if let pincode = try? authStoredPincode() {
                        
                        self.auth.value = .unlockRequired(pincode: pincode)
                        
                    } else {
                        
                        self.auth.value = .registerRequired
                    }
                    
                case .failed(let error):
                    if let pincode = try? authStoredPincode() {
                        
                        self.auth.value = .unlockRequired(pincode: pincode)
                        
                    } else {
                        
                        self.auth.value = .registerRequired
                    }
                    
                    //TODO: show error message
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        sessionAgent.action
            .receive(on: queue)
            .sink { [unowned self] action in
                
                switch action {
                case _ as SessionAgentAction.Session.Start.Request:
                    self.action.send(ModelAction.Auth.Session.Start.Request())
                    
                case _ as SessionAgentAction.Session.Extend.Request:
                    self.action.send(ModelAction.Auth.Session.Extend.Request())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        serverAgent.action
            .receive(on: queue)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ServerAgentAction.NetworkActivityEvent:
                    sessionAgent.action.send(SessionAgentAction.Event.Network())
 
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: queue)
            .sink {[unowned self] action in
                
                switch action {
                
                //MARK: - Auth Actions
                    
                case _ as ModelAction.Auth.Session.Start.Request:
                    handleAuthSessionStartRequest()
                    
                case let payload as ModelAction.Auth.Session.Start.Response:
                    sessionAgent.action.send(SessionAgentAction.Session.Start.Response(result: payload.result))
                    
                case _ as ModelAction.Auth.Session.Extend.Request:
                    handleAuthSessionExtendRequest()
                    
                case let payload as ModelAction.Auth.Session.Extend.Response:
                    sessionAgent.action.send(SessionAgentAction.Session.Extend.Response(result: payload.result))
                    
                case let payload as ModelAction.Auth.ProductImage.Request:
                    handleAuthProductImageRequest(payload)
                    
                case let payload as ModelAction.Auth.CheckClient.Request:
                    handleAuthCheckClientRequest(payload: payload)
                
                case let payload as ModelAction.Auth.VerificationCode.Confirm.Request:
                    handleAuthVerificationCodeConfirmRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.VerificationCode.Resend.Request:
                    handleAuthVerificationCodeResendRequest(payload: payload)
                    
                case _ as ModelAction.Auth.Register.Request:
                    handleAuthRegisterRequest()
                    
                case let payload as ModelAction.Auth.Pincode.Set.Request:
                    handleAuthPincodeSetRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.Pincode.Check.Request:
                    handleAuthPincodeCheckRequest(payload: payload)
                    
                case let payload as ModelAction.Auth.Sensor.Settings:
                    handleAuthSensorSettings(payload: payload)
                    
                case let payload as ModelAction.Auth.Sensor.Evaluate.Request:
                    handleAuthSensorEvaluateRequest(payload: payload)
                    
                case _ as ModelAction.Auth.Push.Register.Request:
                    handleAuthPushRegisterRequest()
                    
                case let payload as ModelAction.Auth.SetDeviceSettings.Request:
                    handleAuthSetDeviceSettings(payload: payload)
                    
                case let payload as ModelAction.Auth.Login.Request:
                    handleAuthLoginRequest(payload: payload)
                    
                case _ as ModelAction.Auth.Logout:
                    handleAuthLogoutRequest()
                    
                //MARK: - Products Actions
                    
                case _ as ModelAction.Products.Update.Fast.All:
                    handleProductsUpdateFastAll()
                    
                case let payload as ModelAction.Products.Update.Fast.Single.Request:
                    handleProductsUpdateFastSingleRequest(payload)
                    
                case _ as ModelAction.Products.Update.Total.All:
                    handleProductsUpdateTotalAll()

                //MARK: - Payments
                    
                case let payload as ModelAction.Payment.Services.Request:
                    handlePaymentsServicesRequest(payload)
                    
                case let payload as ModelAction.Payment.Begin.Request:
                    handlePaymentsBeginRequest(payload)
                    
                case let payload as ModelAction.Payment.Continue.Request:
                    handlePaymentsContinueRequest(payload)
                    
                case let payload as ModelAction.Payment.Complete.Request:
                    handlePaymentsCompleteRequest(payload)
                    
                //MARK: - Settings Actions
                case _ as ModelAction.Settings.GetClientInfo.Requested:
                    handleGetClientInfoRequest()
                    
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
                        
                    case .bannerCatalogList:
                        handleDictionaryBannerCatalogList(payload)
                    }
                    
                    //MARK: - Deposits
                    
                case _ as ModelAction.Deposits.List.Request:
                    handleDepositsListRequest()
                    
                
                //MARK: - Notification Action
                
                case let payload as ModelAction.Notification.ChangeNotificationStatus.Requested:
                    guard let token = token else {
                        //TODO: handle not authoried server request attempt
                        return
                    }
                    let command = ServerCommands.NotificationController.ChangeNotificationStatus (token: token,
                                                                                                  payload: .init(eventId: payload.eventId,
                                                                                                                 cloudId: payload.cloudId,
                                                                                                                 status: payload.status))
                    serverAgent.executeCommand(command: command) { result in
                        
                        switch result {
                        case .success(let response):
                            switch response.statusCode {
                            case .ok:
                                self.action.send(ModelAction.Notification.ChangeNotificationStatus.Complete())
                            default:
                                //TODO: handle not ok server status
                                return
                            }
                        case .failure(let error):
                            self.action.send(ModelAction.Notification.ChangeNotificationStatus.Failed(error: error))
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
            
        case .bannerCatalogList:
            return localAgent.serial(for: [BannerCatalogListData].self)
        }
    }
    
    func productSerial() -> String? {
        
        localAgent.serial(for: [ProductData].self)
    }
    
    func loadCachedData() {
        
        if let catalogProducts = localAgent.load(type: [CatalogProductData].self) {
            
            self.catalogProducts.value = catalogProducts
        }
        
        if let paymentTemplates = localAgent.load(type: [PaymentTemplateData].self) {
            
            self.paymentTemplates.value = paymentTemplates
        }
        
        if let catalogBanner = localAgent.load(type: [BannerCatalogListData].self) {
            
            self.catalogBanners.value = catalogBanner
        }
        
        if let products = localAgent.load(type: [ProductData].self) {
            self.products.value = reduce(products: self.products.value, with: products)
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

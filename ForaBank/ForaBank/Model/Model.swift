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
    
    let action: PassthroughSubject<Action, Never>
    
    //MARK: Auth
    let auth: CurrentValueSubject<AuthorizationState, Never>
    
    //MARK: Products
    let products: CurrentValueSubject<ProductsData, Never>
    let productsUpdating: CurrentValueSubject<[ProductType], Never>
    var productsAllowed: Set<ProductType> { [.card, .account, .deposit, .loan] }
    
    //MARK: Statement
    var statement: CurrentValueSubject<ProductStatementDataCacheble, Never>
    
    //MARK: Dictionaries
    let catalogProducts: CurrentValueSubject<[CatalogProductData], Never>
    let catalogBanners: CurrentValueSubject<[BannerCatalogListData], Never>
    let currencyList: CurrentValueSubject<[CurrencyData], Never>
    let bankList: CurrentValueSubject<[BankData], Never>
    
    //MARK: Templates
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    //TODO: store in cache
    let paymentTemplatesViewSettings: CurrentValueSubject<TemplatesListViewModel.Settings, Never>
    
    //MARK: LatestAllPayments
    let latestPayments: CurrentValueSubject<[PaymentData], Never>
    
    //MARK: Notifications
    let notifications: CurrentValueSubject<[NotificationData], Never>
    
    //MARK: - UserData
    let userSettingData: CurrentValueSubject<ClientInfoState, Never> = .init(.empty)
    
    //MARK: Loacation
    let currentUserLoaction: CurrentValueSubject<LocationData?, Never>
    
    //TODO: remove when all templates will be implemented
    let paymentTemplatesAllowed: [ProductStatementData.Kind] = [.sfp, .insideBank, .betweenTheir, .direct, .contactAddressless, .externalIndivudual, .externalEntity, .mobile, .housingAndCommunalService, .transport, .internet]
    let paymentTemplatesDisplayed: [PaymentTemplateData.Kind] = [.sfp, .byPhone, .insideBank, .betweenTheir, .direct, .contactAdressless, .externalIndividual, .externalEntity, .mobile, .housingAndCommunalService, .transport, .internet]
    
    // services
    internal let sessionAgent: SessionAgentProtocol
    internal let serverAgent: ServerAgentProtocol
    internal let localAgent: LocalAgentProtocol
    internal let keychainAgent: KeychainAgentProtocol
    internal let settingsAgent: SettingsAgentProtocol
    internal let biometricAgent: BiometricAgentProtocol
    internal let locationAgent: LocationAgentProtocol
    
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
    
    init(sessionAgent: SessionAgentProtocol, serverAgent: ServerAgentProtocol, localAgent: LocalAgentProtocol, keychainAgent: KeychainAgentProtocol, settingsAgent: SettingsAgentProtocol, biometricAgent: BiometricAgentProtocol, locationAgent: LocationAgentProtocol) {
        
        self.action = .init()
        self.auth = .init(.registerRequired)
        self.products = .init([:])
        self.statement = .init(.init(productStatement: [:]))
        self.productsUpdating = .init([])
        self.catalogProducts = .init([])
        self.catalogBanners = .init([])
        self.currencyList = .init([])
        self.bankList = .init([])
        self.paymentTemplates = .init([])
        self.paymentTemplatesViewSettings = .init(.initial)
        self.latestPayments = .init([])
        self.notifications = .init([])
        self.currentUserLoaction = .init(nil)
        self.sessionAgent = sessionAgent
        self.serverAgent = serverAgent
        self.localAgent = localAgent
        self.keychainAgent = keychainAgent
        self.settingsAgent = settingsAgent
        self.biometricAgent = biometricAgent
        self.locationAgent = locationAgent
        self.bindings = []
        
        loadCachedData()
        bind()
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
        
        // location agent
        let locationAgent = LocationAgent()
        
        return Model(sessionAgent: sessionAgent, serverAgent: serverAgent, localAgent: localAgent, keychainAgent: keychainAgent, settingsAgent: settingsAgent, biometricAgent: biometricAgent, locationAgent: locationAgent)
    }()
    
    private func bind() {
        
        sessionAgent.sessionState
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] auth in
                
                switch auth {
                case .active:
                    action.send(ModelAction.Products.Update.Total.All())
                    action.send(ModelAction.Settings.GetClientInfo.Requested())
                    
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
                    
                    //MARK: - General
                case let payload as ModelAction.General.DownloadImage.Request:
                    handleGeneralDownloadImageRequest(payload)
                    
                    //MARK: - Auth Actions
                    
                case _ as ModelAction.Auth.Session.Start.Request:
                    handleAuthSessionStartRequest()
                    
                case let payload as ModelAction.Auth.Session.Start.Response:
                    sessionAgent.action.send(SessionAgentAction.Session.Start.Response(result: payload.result))
                    
                case _ as ModelAction.Auth.Session.Extend.Request:
                    handleAuthSessionExtendRequest()
                    
                case let payload as ModelAction.Auth.Session.Extend.Response:
                    sessionAgent.action.send(SessionAgentAction.Session.Extend.Response(result: payload.result))
                    
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
                    
                case let payload as ModelAction.Products.UpdateCustomName.Request:
                    handleProductsUpdateCustomName(payload)
                    
                    //MARK: - Statement
                    
                case let payload as ModelAction.Statement.List.Request:
                    handleStatementRequest(payload)
                    
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
                    
                    //MARK: - Notifications
                    
                case _ as ModelAction.Notification.Fetch.New.Request:
                    handleNotificationsFetchNewRequest()
                    
                case _ as ModelAction.Notification.Fetch.Next.Request:
                    handleNotificationsFetchNextRequest()
                    
                case let payload as ModelAction.Notification.ChangeNotificationStatus.Requested:
                   handleNotificationsChangeNotificationStatusRequest(payload: payload)
                    
                    //MARK: - LatestPayments Actions
                    
                case _ as ModelAction.LatestPayments.List.Requested:
                    handleLatestPaymentsListRequest()
                    
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
                    
                case _ as ModelAction.Dictionary.UpdateCache.All:
                    handleDictionaryUpdateAll()
                    
                case let payload as ModelAction.Dictionary.UpdateCache.List:
                    handleDictionaryUpdateList(payload)
                    
                case let payload as ModelAction.Dictionary.UpdateCache.Request:
                    switch payload.type {
                    case .anywayOperators:
                        handleDictionaryAnywayOperatorsRequest(payload.serial)
                        
                    case .banks:
                        handleDictionaryBanks(payload.serial)
                        
                    case .countries:
                        handleDictionaryCountries(payload.serial)
                        
                    case .currencyList:
                        handleDictionaryCurrencyList(payload.serial)
                        
                    case .fmsList:
                        handleDictionaryFMSList(payload.serial)
                        
                    case .fsspDebtList:
                        handleDictionaryFSSPDebtList(payload.serial)
                        
                    case .fsspDocumentList:
                        handleDictionaryFSSPDocumentList(payload.serial)
                        
                    case .ftsList:
                        handleDictionaryFTSList(payload.serial)
                        
                    case .fullBankInfoList:
                        handleDictionaryFullBankInfoList(payload.serial)
                        
                    case .mobileList:
                        handleDictionaryMobileList(payload.serial)
                        
                    case .mosParkingList:
                        handleDictionaryMosParkingList(payload.serial)
                        
                    case .paymentSystemList:
                        handleDictionaryPaymentSystemList(payload.serial)
                        
                    case .productCatalogList:
                        handleDictionaryProductCatalogList(payload.serial)
                        
                    case .bannerCatalogList:
                        handleDictionaryBannerCatalogList(payload.serial)
                        
                    case .atmList:
                        handleDictionaryAtmDataList(payload.serial)
                        
                    case .atmServiceList:
                        handleDictionaryAtmServiceDataList(payload.serial)
                        
                    case .atmTypeList:
                        handleDictionaryAtmTypeDataList(payload.serial)
                        
                    case .atmMetroStationList:
                        handleDictionaryAtmMetroStationDataList(payload.serial)
                        
                    case .atmCityList:
                        handleDictionaryAtmCityDataList(payload.serial)
                        
                    case .atmRegionList:
                        handleDictionaryAtmRegionDataList(payload.serial)
                    }
                    
                    //MARK: - Deposits
                    
                case _ as ModelAction.Deposits.List.Request:
                    handleDepositsListRequest()
                    
                    //MARK: - Location Actions
                    
                case _ as ModelAction.Location.Updates.Start:
                    handleLocationUpdatesStart()
                    
                case _ as ModelAction.Location.Updates.Stop:
                    handleLocationUpdateStop()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        locationAgent.currentLoaction.sink { [unowned self] coordinate in
            
            if let coordinate = coordinate {
                
                currentUserLoaction.value = LocationData(with: coordinate)
                
            } else {
                
                currentUserLoaction.value = nil
            }
            
        }.store(in: &bindings)
    }
}

//MARK: - Private Helpers

private extension Model {
    
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
        
        if let currency = localAgent.load(type: [CurrencyData].self) {
            
            self.currencyList.value = currency
        }
        
        if let bankList = localAgent.load(type: [BankData].self) {
            
            self.bankList.value = bankList
        }
        
        self.products.value = productsCacheLoadData()
    }
    
    func clearCachedData() {
        
        do {
            
            try localAgent.clear(type: [PaymentTemplateData].self)
            
        } catch {
            
            print("Model: clearCachedData: templates error: \(error.localizedDescription)")
        }
        
        do {
            
            try productsCacheClearData()
            
        } catch {
            
            print("Model: clearCachedData: products error: \(error.localizedDescription)")
        }
    }
}

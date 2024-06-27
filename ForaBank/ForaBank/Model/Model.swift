//
//  Model.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import CodableLanding
import Combine
import Foundation
import LandingUIComponent
import os
import ServerAgent
import SymmetricEncryption
import UserModel
import GetProductListByTypeService

class Model {
    
    let action: PassthroughSubject<Action, Never>
    
    //MARK: Auth
    let auth: CurrentValueSubject<AuthorizationState, Never>
    var sessionState: AnyPublisher<SessionState, Never> {
        sessionAgent.sessionState
            .eraseToAnyPublisher()
    }
    let fcmToken: CurrentValueSubject<String?, Never>

    //MARK: Pre-Auth
    let transferLanding: CurrentValueSubject<Result<UILanding?, Error>, Never>
    let orderCardLanding: CurrentValueSubject<Result<UILanding?, Error>, Never>
    
    //MARK: Sticker
    let stickerLanding: CurrentValueSubject<Result<UILanding?, Error>, Never>
    
    //MARK: Products
    let products: CurrentValueSubject<ProductsData, Never>
    let productsUpdating: CurrentValueSubject<[ProductType], Never>
    let productsFastUpdating: CurrentValueSubject<Set<ProductData.ID>, Never>
    let productsVisibilityUpdating: CurrentValueSubject<Set<ProductData.ID>, Never>
    let productsOrdersUpdating: CurrentValueSubject<Bool, Never>
    var productsAllowed: Set<ProductType> { [.card, .account, .deposit, .loan] }
    let loans: CurrentValueSubject<LoansData, Never>
    let loansUpdating: CurrentValueSubject<Set<ProductData.ID>, Never>
    let depositsInfo: CurrentValueSubject<DepositsInfoData, Never>
    let productsOpening: CurrentValueSubject<Set<ProductType>, Never>
    
    //MARK: Account
    let accountProductsList: CurrentValueSubject<[OpenAccountProductData], Never>
    
    //MARK: Statements
    let statements: CurrentValueSubject<StatementsData, Never>
    let statementsUpdating: CurrentValueSubject<[ProductData.ID: ProductStatementsUpdateState], Never>
    
    //MARK: Currency rates
    let rates: CurrentValueSubject<[ExchangeRateData], Never>
    let ratesUpdating: CurrentValueSubject<[Currency], Never>
    
    //MARK: Dictionaries
    let dictionariesUpdating: CurrentValueSubject<Set<DictionaryType>, Never>
    let catalogProducts: CurrentValueSubject<[CatalogProductData], Never>
    let authCatalogBanners: CurrentValueSubject<[BannerCatalogListData], Never>
    let catalogBanners: CurrentValueSubject<[BannerCatalogListData], Never>
    let productListBannersWithSticker: CurrentValueSubject<[StickerBannersMyProductList], Never>
    let currencyList: CurrentValueSubject<[CurrencyData], Never>
    let countriesList: CurrentValueSubject<[CountryData], Never>
    let countriesListWithSevice: CurrentValueSubject<[CountryWithServiceData], Never>
    let paymentSystemList: CurrentValueSubject<[PaymentSystemData], Never>
    let bankList: CurrentValueSubject<[BankData], Never>
    let bankListFullInfo: CurrentValueSubject<[BankFullInfoData], Never>
    let prefferedBanksList: CurrentValueSubject<[String], Never>
    let currencyWalletList: CurrentValueSubject<[CurrencyWalletData], Never>
    let centralBankRates: CurrentValueSubject<[CentralBankRatesData], Never>
    var images: CurrentValueSubject<[String: ImageData], Never>
    let clientInform: CurrentValueSubject<ClientInformDataState, Never>
    
    //MARK: Deposits
    let deposits: CurrentValueSubject<[DepositProductData], Never>
    var depositsCloseNotified: Set<DepositCloseNotification>
    
    //MARK: Templates
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    let paymentTemplatesUpdating: CurrentValueSubject<Bool, Never>
    let productTemplates: CurrentValueSubject<[ProductTemplateData], Never>
 
    
    //MARK: LatestAllPayments
    let latestPayments: CurrentValueSubject<[LatestPaymentData], Never>
    let latestPaymentsUpdating: CurrentValueSubject<Bool, Never>
    let paymentsByPhone: CurrentValueSubject<[String: [PaymentPhoneData]], Never>
    let paymentsByPhoneUpdating: CurrentValueSubject<Set<String>, Never>
    
    //MARK: Notifications
    let notifications: CurrentValueSubject<[NotificationData], Never>
    var notificationsTransition: NotificationTransition?
    
    //MARK: - Client Info
    let clientInfo: CurrentValueSubject<ClientInfoData?, Never>
    let clientPhoto: CurrentValueSubject<ClientPhotoData?, Never>
    let clientName: CurrentValueSubject<ClientNameData?, Never>
    let fastPaymentContractFullInfo: CurrentValueSubject<[FastPaymentContractFullInfoType], Never>
    
    //MARK: - User Settings
    let userSettings: CurrentValueSubject<[UserSettingData], Never>

    //MARK: Location
    let currentUserLocation: CurrentValueSubject<LocationData?, Never>

    //MARK: Bank Client Info
    let bankClientsInfo: CurrentValueSubject<Set<BankClientInfo>, Never>
    
    //MARK: DeepLink
    //TODO: remove deepLinkType because shared mutable state
    var deepLinkType: DeepLinkType?
    
    //MARK: C2B
    var subscriptions: CurrentValueSubject<C2BSubscription?, Never>

    //MARK: QR
    let qrMapping: CurrentValueSubject<QRMapping?, Never>
    let qrPaymentType: CurrentValueSubject<[QRPaymentType], Never>
    
    //MARK: ClientInform show flags
    var clientInformStatus: ClientInformStatus
    
    // MARK: GetProductListByTypev5
    typealias GetProductListByTypeResponse = GetProductListByTypeService.ProductResponse
    
    typealias GetProductListByTypeCompletion = (GetProductListByTypeResponse?) -> Void
    typealias GetProductListByType = (ProductType, @escaping GetProductListByTypeCompletion) -> Void

    let updateInfo: CurrentValueSubject<UpdateInfo, Never>

    var getProducts: GetProductListByType

    // services
    internal let sessionAgent: SessionAgentProtocol
    internal let serverAgent: ServerAgentProtocol
    internal let localAgent: LocalAgentProtocol
    internal let keychainAgent: KeychainAgentProtocol
    internal let settingsAgent: SettingsAgentProtocol
    internal let biometricAgent: BiometricAgentProtocol
    internal let locationAgent: LocationAgentProtocol
    internal let contactsAgent: ContactsAgentProtocol
    internal let cameraAgent: CameraAgentProtocol
    internal let imageGalleryAgent: ImageGalleryAgentProtocol
    internal let networkMonitorAgent: NetworkMonitorAgentProtocol
    
    // Models
    private let userModel: UserModel<ProductData.ID>
    var preferredProductID: ProductData.ID? {
        userModel.preferredProductValue
    }
    
    var preferredProductIDPublisher: AnyPublisher<ProductData.ID?, Never> {
        userModel.preferredProductPublisher
    }
    
    // private
    private var bindings: Set<AnyCancellable>
    private let queue = DispatchQueue(label: "ru.forabank.sense.model", qos: .userInitiated, attributes: .concurrent)
    internal var token: String? {
        
        guard case .active(_, let credentials) = sessionAgent.sessionState.value else {
            return nil
        }
        
        return credentials.token
    }
    
    internal var activeCredentials: SessionCredentials? {
        
        guard case .active(_, let credentials) = sessionAgent.sessionState.value else {
            return nil
        }
        
        return credentials
    }
    
    init(sessionAgent: SessionAgentProtocol, serverAgent: ServerAgentProtocol, localAgent: LocalAgentProtocol, keychainAgent: KeychainAgentProtocol, settingsAgent: SettingsAgentProtocol, biometricAgent: BiometricAgentProtocol, locationAgent: LocationAgentProtocol, contactsAgent: ContactsAgentProtocol, cameraAgent: CameraAgentProtocol, imageGalleryAgent: ImageGalleryAgentProtocol, networkMonitorAgent: NetworkMonitorAgentProtocol, userModel: UserModel<ProductData.ID> = .init()) {
        
        self.action = .init()
        self.auth = keychainAgent.isStoredString(values: [.pincode, .serverDeviceGUID]) ? .init(.signInRequired) : .init(.registerRequired)
        self.fcmToken = .init(.none)
        self.products = .init([:])
        self.productsUpdating = .init([])
        self.accountProductsList = .init([])
        self.productsFastUpdating = .init([])
        self.productsVisibilityUpdating = .init([])
        self.productsOrdersUpdating = .init(false)
        self.loans = .init([])
        self.loansUpdating = .init([])
        self.depositsInfo = .init(DepositsInfoData())
        self.statements = .init([:])
        self.statementsUpdating = .init([:])
        self.transferLanding = .init(.success(.none))
        self.orderCardLanding = .init(.success(.none))
        self.stickerLanding = .init(.success(.none))
        self.rates = .init([])
        self.ratesUpdating = .init([])
        self.catalogProducts = .init([])
        self.authCatalogBanners = .init([])
        self.catalogBanners = .init([])
        self.productListBannersWithSticker = .init([])
        self.currencyList = .init([])
        self.currencyWalletList = .init([])
        self.centralBankRates = .init([])
        self.bankList = .init([])
        self.bankListFullInfo = .init([])
        self.prefferedBanksList = .init([])
        self.countriesList = .init([])
        self.countriesListWithSevice = .init([])
        self.paymentSystemList = .init([])
        self.images = .init([:])
        self.deposits = .init([])
        self.paymentTemplates = .init([])
        self.paymentTemplatesUpdating = .init(false)
        self.latestPayments = .init([])
        self.latestPaymentsUpdating = .init(false)
        self.paymentsByPhone = .init([:])
        self.paymentsByPhoneUpdating = .init([])
        self.notifications = .init([])
        self.clientInfo = .init(nil)
        self.clientPhoto = .init(nil)
        self.clientName = .init(nil)
        self.fastPaymentContractFullInfo = .init([])
        self.currentUserLocation = .init(nil)
        self.notificationsTransition = nil
        self.dictionariesUpdating = .init([])
        self.userSettings = .init([])
        self.bankClientsInfo = .init([])
        self.deepLinkType = nil
        self.subscriptions = .init(nil)
        self.qrMapping = .init(nil)
        self.qrPaymentType = .init([])
        self.productsOpening = .init([])
        self.depositsCloseNotified = .init([])
        self.clientInform = .init(.notRecieved)
        self.clientInformStatus = .init(isShowNotAuthorized: false, isShowAuthorized: false)
        self.productTemplates = .init([])
        self.getProducts = { _, _ in }
        self.updateInfo = .init(.init())
        
        self.sessionAgent = sessionAgent
        self.serverAgent = serverAgent
        self.localAgent = localAgent
        self.keychainAgent = keychainAgent
        self.settingsAgent = settingsAgent
        self.biometricAgent = biometricAgent
        self.locationAgent = locationAgent
        self.contactsAgent = contactsAgent
        self.cameraAgent = cameraAgent
        self.imageGalleryAgent = imageGalleryAgent
        self.networkMonitorAgent = networkMonitorAgent
        self.userModel = userModel
        self.bindings = []
        
        LoggerAgent.shared.log(level: .debug, category: .model, message: "initialized")

        bind()
    }
    
    //FIXME: remove after refactoring
    static var shared: Model = {
        
        // session agent
        let sessionAgent = SessionAgent()
        
        // server agent
        let environment = Config.serverAgentEnvironment
        let serverAgent = ServerAgent(
            baseURL: environment.baseURL,
            encoder: .serverDate,
            decoder: .serverDate,
            logError: { LoggerAgent.shared.log(level: .error, category: .network, message: $0) },
            logMessage: { LoggerAgent.shared.log(category: .network, message: $0) },
            sendAction: { action in
                
                switch action {
                case .networkActivityEvent:
                    sessionAgent.action.send(SessionAgentAction.Event.Network())
                    
                case .notAuthorized:
                    LoggerAgent.shared.log(level: .error, category: .model, message: "received ServerAgentAction.notAuthorized")
                    
                    LoggerAgent.shared.log(category: .model, message: "sent SessionAgentAction.Session.Terminate")
                    sessionAgent.action.send(SessionAgentAction.Session.Terminate())
                }
            }
        )

        // keychain agent
        let keychainAgent = ValetKeychainAgent(valetName: "ru.forabank.sense.valet")
        
        // settings agent
        let settingsAgent = UserDefaultsSettingsAgent()
        
        // remove old cache symmetric key from a keychain on a first app launch
        do {
            let cleaner = LocalAgentOldSymmetricKeyCleaner(settingsAgent: settingsAgent, keychainAgent: keychainAgent)
            try cleaner.clean()
            
        } catch {
            
            LoggerAgent.shared.log(level: .error, category: .cache, message: "Unable remove old cache symmetric key data from keychain with error: \(error)")
        }
        
        // local agent
        let localAgent: LocalAgent = {
            
            let localAgentContext = LocalAgent.Context(cacheFolderName: "cache", encoder: .serverDate, decoder: .serverDate, fileManager: .default)
            let symmetricKeyProvider = KeychainSymmetricKeyProviderAdapter(keychainAgent: keychainAgent, keyProvider: SymmetricKeyProvider(keySize: .bits256), keychainValueType: .symmetricKeyCache)
            let localAgentSymmetricKeyData = symmetricKeyProvider.getSymmetricKeyRawRepresentation()
            let encryptionAgent = ChaChaPolyEncryptionAgent(with: localAgentSymmetricKeyData)
            
            return EncryptionLocalAgent(context: localAgentContext, encryptionAgent: encryptionAgent)
        }()
                
        // biometric agent
        let biometricAgent = BiometricAgent()
        
        // location agent
        let locationAgent = LocationAgent()
        
        // contacts agent
        let contactsAgent = ContactsAgent(phoneNumberFormatter: PhoneNumberKitFormater())
        
        // camera agent
        let cameraAgent = CameraAgent()
        
        // imageGallery agent
        let imageGalleryAgent = ImageGalleryAgent()
        
        // networkMonitor agent
        let networkMonitorAgent = NetworkMonitorAgent()
        
        return Model(sessionAgent: sessionAgent, serverAgent: serverAgent, localAgent: localAgent, keychainAgent: keychainAgent, settingsAgent: settingsAgent, biometricAgent: biometricAgent, locationAgent: locationAgent, contactsAgent: contactsAgent, cameraAgent: cameraAgent, imageGalleryAgent: imageGalleryAgent, networkMonitorAgent: networkMonitorAgent)
    }()
    
    //MARK: - Session Agent State
    
    private func bind(sessionAgent: SessionAgentProtocol) {
        
        sessionAgent.sessionState
            .receive(on: queue)
            .sink { [unowned self] sessionState in
                
                switch sessionState {
                case .active:
                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Auth.Session.Activated")
                    action.send(ModelAction.Auth.Session.Activated())
                    
                    loadCachedPublicData()
                    LoggerAgent.shared.log(category: .model, message: "sent ModelAction.Dictionary.UpdateCache.All")
                    action.send(ModelAction.Dictionary.UpdateCache.All())
                    
                case .inactive:
                    auth.value = authIsCredentialsStored ? .signInRequired : .registerRequired
                    
                case .expired, .failed:
                    auth.value = authIsCredentialsStored ? .unlockRequired : .registerRequired
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind() {
        
        //MARK: - Auth
        
        auth
            .receive(on: queue)
            .sink { [unowned self] auth in
                
                switch auth {
                case .authorized:
                    LoggerAgent.shared.log(category: .model, message: "auth: AUTHORIZED")
                    loadCachedAuthorizedData()
                    loadSettings()
                    action.send(ModelAction.Products.Update.Total.All())
                    action.send(ModelAction.ClientInfo.Fetch.Request())
                    action.send(ModelAction.ClientPhoto.Load())
                    action.send(ModelAction.Rates.Update.All())
                    action.send(ModelAction.Deposits.List.Request())
                    action.send(ModelAction.Notification.Fetch.New.Request())
                    action.send(ModelAction.FastPaymentSettings.ContractFindList.Request())
                    action.send(ModelAction.LatestPayments.List.Requested())
                    action.send(ModelAction.PaymentTemplate.List.Requested())
                    action.send(ModelAction.Account.ProductList.Request())
                    action.send(ModelAction.AppVersion.Request())
                    action.send(ModelAction.Settings.GetUserSettings())
                    action.send(ModelAction.ProductTemplate.List.Request())
                    action.send(ModelAction.C2B.GetC2BSubscription.Request())
                    action.send(ModelAction.Dictionary.UpdateCache.List(types: [.bannersMyProductListWithSticker]))
                    
                    if let deepLinkType = deepLinkType {
                        
                        action.send(ModelAction.DeepLink.Process(type: deepLinkType))
                    }
                    
                    if let notification = notificationsTransition {
                        
                        action.send(ModelAction.Notification.Transition.Process(transition: notification))
                    }
                    
                case .registerRequired:
                    LoggerAgent.shared.log(category: .model, message: "auth: REGISTER REQUIRED")
                    
                case .signInRequired:
                    LoggerAgent.shared.log(category: .model, message: "auth: SIGN IN REQUIRED")
                    
                case .unlockRequired:
                    LoggerAgent.shared.log(category: .model, message: "auth: UNLOCK REQUIRED")
                    
                case .unlockRequiredManual:
                    LoggerAgent.shared.log(category: .model, message: "auth: UNLOCK REQUIRED MANUAL")
                }
                
            }.store(in: &bindings)

        //MARK: - Session Agent Action
        
        sessionAgent.action
            .receive(on: queue)
            .sink { [unowned self] action in
                
                switch action {
                case _ as SessionAgentAction.Session.Start.Request:
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "received SessionAgentAction.Session.Start.Request")
                    
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "sent ModelAction.Auth.Session.Start.Request")
                    self.action.send(ModelAction.Auth.Session.Start.Request())
                    
                case _ as SessionAgentAction.Session.Extend:
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "received SessionAgentAction.Session.Extend")
                    
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "sent ModelAction.ClientInfo.Fetch")
                    self.action.send(ModelAction.ClientInfo.Fetch.Request())
                    
                case _ as SessionAgentAction.Session.Timeout.Request:
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "received SessionAgentAction.Session.Timeout.Request")
                    
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "sent ModelAction.Auth.Session.Timeout.Request")
                    self.action.send(ModelAction.Auth.Session.Timeout.Request())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        //MARK: - Contacts Agent Action
        
        contactsAgent.status
            .receive(on: queue)
            .sink { [weak self] status in
                
                self?.action.send(ModelAction.Contacts.PermissionStatus.Update(status: status))
                
        }.store(in: &bindings)
        
        //MARK: - Model Action
        
        action
            .receive(on: queue)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                    
                    //MARK: - App
                    
                case _ as ModelAction.App.Launched:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.App.Launched")
                    handleAppFirstLaunch()
                    bind(sessionAgent: sessionAgent)

                case _ as ModelAction.App.Activated:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.App.Activated")
                    
                    //FIXME: workaround for push notification extension
                    if auth.value == .registerRequired {
                        
                        auth.value = keychainAgent.isStoredString(values: [.pincode, .serverDeviceGUID]) ? .signInRequired : .registerRequired
                    }
                    
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "sent SessionAgentAction.App.Activated")
                    sessionAgent.action.send(SessionAgentAction.App.Activated())
                    
                    if auth.value == .authorized,
                       let deepLinkType = deepLinkType {
                        
                        self.action.send(ModelAction.DeepLink.Process(type: deepLinkType))
                    }
                    
                    if auth.value == .authorized,
                       let notification = notificationsTransition {
                        
                        self.action.send(ModelAction.Notification.Transition.Process(transition: notification))
                    }
                    
                case _ as ModelAction.App.Inactivated:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.App.Inactivated")
                    
                    LoggerAgent.shared.log(category: .model, message: "sent SessionAgentAction.App.Inactivated")
                    sessionAgent.action.send(SessionAgentAction.App.Inactivated())
                    
                    //MARK: - General
                    
                case let payload as ModelAction.General.DownloadImage.Request:
                    handleGeneralDownloadImageRequest(payload)
                    
                    //MARK: - Auth Actions
                    
                case _ as ModelAction.Auth.Session.Start.Request:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.Auth.Session.Start.Request")
                    handleAuthSessionStartRequest()
                    
                case let payload as ModelAction.Auth.Session.Start.Response:
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "received ModelAction.Auth.Session.Start.Response")
                    
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "sent SessionAgentAction.Session.Start.Response")
                    sessionAgent.action.send(SessionAgentAction.Session.Start.Response(result: payload.result))
                    
                case _ as ModelAction.Auth.Session.Timeout.Request:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.Auth.Session.Timeout.Request")
                    handleAuthSessionTimeoutRequest()
                    
                case let payload as ModelAction.Auth.Session.Timeout.Response:
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "received ModelAction.Auth.Session.Timeout.Response")
                    
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "sent SessionAgentAction.Session.Timeout.Response")
                    sessionAgent.action.send(SessionAgentAction.Session.Timeout.Response(result: payload.result))
                 
                case _ as ModelAction.Auth.Session.Terminate:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.Auth.Session.Terminate")
                    
                    LoggerAgent.shared.log(category: .model, message: "sent SessionAgentAction.Session.Terminate")
                    sessionAgent.action.send(SessionAgentAction.Session.Terminate())
                    
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
                    
                case let payload as ModelAction.Auth.Login.Response:
                    LoggerAgent.shared.log(level: .debug, category: .model, message: "received ModelAction.Auth.Login.Response")
                    switch payload {
                    case .success:
                        auth.value = .authorized
                    
                    default:
                        auth.value = authIsCredentialsStored ? .signInRequired : .registerRequired
                    }
                    
                case _ as ModelAction.Auth.Logout:
                    LoggerAgent.shared.log(category: .model, message: "received ModelAction.Auth.Logout")
                    clearKeychainData()
                    clearCachedAuthorizedData()
                    clearMemoryData()
                    sessionAgent.action.send(SessionAgentAction.Session.Terminate())
                    
                case let payload as ModelAction.Auth.OrderLead.Request:
                    handleOrderLeadRequest(payload)
                    
                case let payload as ModelAction.Auth.VerifyPhone.Request:
                    handleVerifyPhoneRequest(payload)
                    
        //MARK: - Products Actions
                    
                case _ as ModelAction.Products.Update.Fast.All:
                    handleProductsUpdateFastAll()
                    
                case let payload as ModelAction.Products.Update.Fast.Single.Request:
                    handleProductsUpdateFastSingleRequest(payload)
                    
                case _ as ModelAction.Products.Update.Total.All:
                    handleProductsUpdateTotalAll()
                
                case let payload as ModelAction.Products.UpdateVisibility:
                    handleProductsUpdateVisibility(payload)
                    
                case let payload as ModelAction.Products.UpdateOrders :
                    handleProductsUpdateOrders(payload)

                case let payload as ModelAction.Products.UpdateCustomName.Request:
                    handleProductsUpdateCustomName(payload)
                    
                case let payload as ModelAction.Products.UpdateCustomName.Response:
                    handleProductsUpdateCustomNameResponse(payload)
                    
                case let payload as ModelAction.Products.ActivateCard.Request:
                    handleProductsActivateCard(payload)
                    
                case let payload as ModelAction.Products.ProductDetails.Request:
                    handleProductDetails(payload)
                    
                case _ as ModelAction.Loans.Update.All:
                    handleLoansUpdateAllRequest()
                    
                case let payload as ModelAction.Loans.Update.Single.Request:
                    handleLoansUpdateSingleRequest(payload)

                case let payload as ModelAction.Products.Update.ForProductType:
                    handleProductsUpdateTotalProduct(payload)
                    
                case let payload as ModelAction.Products.StatementPrintForm.Request:
                    handleProductsStatementPrintFormRequest(payload)
                    
                case let payload as ModelAction.Products.DepositConditionsPrintForm.Request:
                    handleProductsDepositConditionPrintFormRequest(payload)
                    
                case let payload as ModelAction.Products.ContractPrintForm.Request:
                    handleProductsContractPrintFormRequest(payload)
                    
                case let payload as ModelAction.Card.Unblock.Request:
                    handleUnblockCardRequest(payload)
                    
                case let payload as ModelAction.Card.Block.Request:
                    handleBlockCardRequest(payload)
                    
                    //MARK: - Statement
                    
                case let payload as ModelAction.Statement.List.Request:
                    handleStatementRequest(payload)
                    
                    //MARK: - Rates
                    
                case _ as ModelAction.Rates.Update.All:
                    handleRatesUpdate(allProductsCurrency())
                    
                case let payload as ModelAction.Rates.Update.Single:
                    handleRateUpdate(payload.currency)
                    
                    //MARK: - Payments
                    
                case let payload as ModelAction.Payment.Process.Request:
                    Task { [weak self] in
                        
                        guard let self else { return }
                        
                        await handlePaymentsProcessRequest(payload)
                    }
                    
                case let payload as ModelAction.Payment.Subscription.Request:
                    Task { [weak self] in
                        
                        guard let self else { return }
                        
                        await handlePaymentSubscriptionRequest(payload)
                    }
                    
                    //MARK: - Operation
                    
                case let payload as ModelAction.Operation.Detail.Request:
                    handleOperationDetailRequest(payload)
                    
                case let payload as ModelAction.Payment.MeToMe.CreateTransfer.Request:
                    handlerCreateTransferRequest(payload)
                    
                case let payload as ModelAction.Payment.MeToMe.MakeTransfer.Request:
                    handlerMakeTransferRequest(payload)
                    
                    //MARK: - Transfers
                    
                case let payload as ModelAction.Transfers.CreateInterestDepositTransfer.Request:
                    handleCreateInterestDepositTransferRequest(payload)
                    
                case let payload as ModelAction.Transfers.TransferLimit.Request:
                    handleTransferLimitRequest(payload)
                    
                case _ as ModelAction.Transfers.ResendCode.Request:
                    handleTransfersResendCodeRequest()
                    
                case let payload as ModelAction.Transfers.CheckCard.Request:
                    handleCheckCard(payload)
                    
                    //MARK: - CurrencyWallet
                    
                case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Start.Request:
                    handlerCurrencyWalletExchangeOperationsStartRequest(payload)
                    
                case _ as ModelAction.CurrencyWallet.ExchangeOperations.Approve.Request:
                    handlerCurrencyWalletExchangeOperationsApproveRequest()
                    
                    //MARK: - Media
                    
                case _ as ModelAction.Media.CameraPermission.Request:
                    handleMediaCameraPermissionStatusRequest()
                    
                case _ as ModelAction.Media.GalleryPermission.Request:
                    handleMediaGalleryPermissionStatusRequest()
                    
                case _ as ModelAction.Media.DocumentPermission.Request:
                    handleMediaDocumentPermissionStatusRequest()
                    
                    //MARK: - Client Info
                    
                case _ as ModelAction.ClientInfo.Fetch.Request:
                    handleClientInfoFetchRequest()
                    
                case let payload as ModelAction.ClientPhoto.Save:
                    handleClientPhotoSave(payload)
                    
                case _ as ModelAction.ClientPhoto.Load:
                    handleClientPhotoRequest()
                    
                case _ as ModelAction.ClientPhoto.Delete:
                    handleMediaDeleteAvatarRequest()
                    
                case let payload as ModelAction.ClientName.Save:
                    handleClientNameSave(payload)
                    
                case _ as ModelAction.ClientName.Get.Request:
                    handleClientNameLoad()
                    
                case _ as ModelAction.FastPaymentSettings.ContractFindList.Request:
                    handleContractFindListRequest()
                    
                case _ as ModelAction.ClientName.Delete:
                    handleClientNameDelete()
                    
                case _ as ModelAction.ClientInfo.Delete.Request:
                    handleClientInfoDelete()
                    
                case let payload as ModelAction.GetPersonAgreement.Request:
                    handleClientAgreement(payload)
                    
                    //MARK: - SBPay
                case let payload as ModelAction.SbpPay.Register.Request:
                    handleRegisterSbpPay(payload)
                    
                case let payload as ModelAction.SbpPay.ProcessTokenIntent.Request:
                    processTokenIntent(payload)
                    
                    //MARK: - User Settings
                case let payload as ModelAction.Settings.UpdateUserSettingPush:
                    handleUpdateUserSetting(payload)
                    
                case _ as ModelAction.Settings.GetUserSettings:
                    handleGetUserSettings()
                    
                    //MARK: - Settings Actions
                    
                case _ as ModelAction.Settings.ApplicationSettings.Request:
                    handleAppSettingsRequest()
                    
                    //MARK: - BankClients
                
                case let payload as ModelAction.BankClient.Request:
                    handleBankClientRequest(payload)
                    
                    //MARK: - Notifications
                       
                case _ as ModelAction.Notification.Fetch.New.Request:
                    handleNotificationsFetchNewRequest()
                    
                case _ as ModelAction.Notification.Fetch.Next.Request:
                    handleNotificationsFetchNextRequest()
                    
                case let payload as ModelAction.Notification.ChangeNotificationStatus.Request:
                    handleNotificationsChangeNotificationStatusRequest(payload: payload)
                    
                case let payload as ModelAction.Notification.Transition.Set:
                    handleNotificationTransitionSet(payload: payload)
                    
                case _ as ModelAction.Notification.Transition.Clear:
                    handleNotificationTransitionClear()
                 
                case _ as ModelAction.Notification.Transition.ClearBadges:
                    handleNotificationTransitionClearBadges()
                    
                    //MARK: - LatestPayments Actions
                    
                case _ as ModelAction.LatestPayments.List.Requested:
                    handleLatestPaymentsListRequest()
                    
                case let payload as ModelAction.LatestPayments.BanksList.Request:
                    handleLatestPaymentsBankListRequest(payload)
                    
                    //MARK: - Templates Actions
                    
                case _ as ModelAction.ProductTemplate.List.Request:
                    handleProductTemplatesListRequest()
                    
                case let payload as ModelAction.ProductTemplate.Delete.Request:
                    handleProductTemplateDeleteRequest(payload)
                    
                case _ as ModelAction.PaymentTemplate.List.Requested:
                    handleTemplatesListRequest()
                    
                case let payload as ModelAction.PaymentTemplate.Save.Requested:
                    handleTemplatesSaveRequest(payload)
                    
                case let payload as ModelAction.PaymentTemplate.Update.Requested:
                    handleTemplatesUpdateRequest(payload)
                    
                case let payload as ModelAction.PaymentTemplate.Delete.Requested:
                    handleTemplatesDeleteRequest(payload)
                
                case let payload as ModelAction.PaymentTemplate.Sort.Requested:
                    handleTemplatesSortRequest(payload)
                    
                    //MARK: - Dictionaries Actions
                    
                case let payload as ModelAction.Dictionary.AnywayOperator.Request:
                    handleAnywayOperatorsCountryRequest(code: payload.code, codeParent: payload.codeParent)
                    
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
                    
                    case .countriesWithService:
                        handleDictionaryCountryWithService(payload.serial)
                        
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
                        
                    case .bannersMyProductListWithSticker:
                        handleDictionaryBannersMyProductListWithSticker(payload.serial)
                        
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
                    
                    case .currencyWalletList:
                        handleDictionaryCurrencyWalletList(payload.serial)
                        
                    case .centralBanksRates:
                        handleDictionaryCentralBankRates()
                        
                    case .qrMapping:
                        handleDictionaryQRMapping(payload.serial)
                        
                    case .qrPaymentType:
                        handleDictionaryQRPaymentType(payload.serial)
                        
                    case .prefferedBanks:
                        handleDictionaryPrefferedBanks(payload.serial)
                    
                    case .clientInform:
                        handleClientInform(payload.serial)
                    }
                    
                case let payload as ModelAction.Dictionary.DownloadImages.Request:
                    handleDictionaryDownloadImages(payload: payload)
                    
                    //MARK: - Deposits
                    
                case _ as ModelAction.Deposits.List.Request:
                    handleDepositsListRequest()
                    
                case _ as ModelAction.Deposits.Info.All:
                    handleDepositsInfoAllRequest()
                    
                case let payload as ModelAction.Deposits.Info.Single.Request:
                    handleDepositsInfoSingleRequest(payload)
                    
                case let payload as ModelAction.Deposits.Close.Request:
                    handleCloseDepositRequest(payload)
                    
                case let payload as ModelAction.Deposits.CloseNotified:
                    handleDidShowCloseAlert(payload)
                    
                case let payload as ModelAction.Deposits.BeforeClosing.Request:
                    handleBeforeClosingRequest(payload)
                    
                    //MARK: - Location Actions
                    
                case _ as ModelAction.Location.Updates.Start:
                    handleLocationUpdatesStart()
                    
                case _ as ModelAction.Location.Updates.Stop:
                    handleLocationUpdateStop()
                    
                    //MARK: - ContactsAgent Actions
                    
                case _ as ModelAction.Contacts.PermissionStatus.Request:
                    handleContactsPermissionStatusRequest()

                // MARK: - Account

                case _ as ModelAction.Account.ProductList.Request:
                    handleAccountProductsListUpdate()

                case _ as ModelAction.Account.PrepareOpenAccount.Request:
                    handlePrepareOpenAccount()

                case let payload as ModelAction.Account.MakeOpenAccount.Request:
                    handleMakeOpenAccount(payload)

                case let payload as ModelAction.Account.MakeOpenAccount.Response:
                    handleMakeOpenAccountUpdate(payload: payload)
                    
                case let payload as ModelAction.Account.Close.Request:
                    handleCloseAccountRequest(payload)
                    
                case let payload as ModelAction.Account.CloseAccount.PrintForm.Request:
                    handleCloseAccountPrintForm(payload)
                    
                //MARK: - DeepLink

                case let payload as ModelAction.DeepLink.Set:
                    handleDeepLinkSet(payload)
                    
                case _ as ModelAction.DeepLink.Clear:
                    handleDeepLinkClear()

                //MARK: - AppStore Version
                case _ as ModelAction.AppVersion.Request:
                    handleVersionAppStore()
                    
                //MARK: - Print Form
                    
                case let payload as ModelAction.PrintForm.Request:
                    handlePrintFormRequest(payload)
                    
                //MARK: - Consent Me2Me
                    
                case _ as ModelAction.Consent.Me2MePull.Request:
                    handleConsentMe2MePull()
                    
                case let payload as ModelAction.Consent.Me2MeDebit.Request:
                    handleConsentGetMe2MeDebit(payload)
                    
                //MARK: - C2B
                case let payload as ModelAction.C2B.GetC2BSubscription.Request:
                    handleGetC2BSubscription(payload)
                 
                case let payload as ModelAction.C2B.GetC2BDetail.Request:
                    handleGetC2BSubscriptionDetail(payload)
                    
                case let payload as ModelAction.C2B.CancelC2BSub.Request:
                    handleCancelC2BSubscription(payload)
                 
                case let payload as ModelAction.C2B.UpdateC2BSub.Request:
                    let product = self.product(productId: payload.productId)
                    switch product?.productType {
                    case .card:
                        handleUpdateC2BSubscriptionCard(payload)

                    default:
                        handleUpdateC2BSubscriptionAcc(payload)
                    }
                //MARK: - QR
                    
                case let payload as ModelAction.QRAction.SendFailData.Request:
                    handleQRActionSendFailData(payload)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        locationAgent.currentLocation.sink { [unowned self] coordinate in
            
            if let coordinate = coordinate {
                
                currentUserLocation.value = LocationData(with: coordinate)
                
            } else {
                
                currentUserLocation.value = nil
            }
            
        }.store(in: &bindings)
    }
}

// MARK: - Protocol Conformances

extension ServerAgent: ServerAgentProtocol {}

//MARK: - Public Methods

extension Model {
    
    func setPreferredProductID(to productID: ProductData.ID?) {
        
        userModel.setPreferredProduct(to: productID)
    }
}

//MARK: - Private Helpers

private extension Model {
    
    func handleAppFirstLaunch() {
        
        if settingsLaunchedBefore == false {
            
            if let serverDeviceGUID = UserDefaults.standard.string(forKey: "serverDeviceGUID"),
               let legacyKeychainAgent = LegacyKeychainAgent(),
               let pincode = legacyKeychainAgent.pinCode {
                
                // user is authorized in legacy version
                
                do {
                    
                    // move legacy auth to keychain
                    try keychainAgent.store(pincode, type: .pincode)
                    try keychainAgent.store(serverDeviceGUID, type: .serverDeviceGUID)
                    
                } catch {
                    
                    //TODO: set logger
                }
                
                do {
                    
                    // update is sensor enabled
                    let isSensorEnabled = UserDefaults.standard.bool(forKey: "isSensorsEnabled")
                    try settingsAgent.store(isSensorEnabled, type: .security(.sensor))
                    
                } catch {
                    
                    //TODO: set logger
                }
                
                do {
                    
                    // update first launch setting
                    try settingsAgent.store(true, type: .general(.launchedBefore))
                    
                } catch {
                    
                    //TODO: set logger
                }
                
                do {
                    
                    // clean up legacy auth
                    try legacyKeychainAgent.clearPincode()
                    UserDefaults.standard.removeObject(forKey: "serverDeviceGUID")
                    UserDefaults.standard.removeObject(forKey: "isSensorsEnabled")
                    
                } catch {
                    
                    //TODO: set logger
                }
                
            } else {
                
                // app just installed, remove previos keychan data that may remain from previous install
                
                clearKeychainData()
                
                do {
                    
                    try settingsAgent.store(true, type: .general(.launchedBefore))
                    
                } catch {
                    
                    //TODO: set logger
                }
            }
        }
    }
        
    func loadCachedPublicData() {
        
        if let catalogProducts = localAgent.load(type: [CatalogProductData].self) {
            
            self.catalogProducts.value = catalogProducts
        }
        
        //FIXME: why this code is commented? Remove if not recquired
        /*
        if let catalogBanner = localAgent.load(type: [BannerCatalogListData].self) {
            
            self.authCatalogBanners.value = catalogBanner
        }
        */
        
        if let catalogBanner = localAgent.load(type: [BannerCatalogListData].self) {
            
            self.catalogBanners.value = catalogBanner
        }
        
        if let productListBannersWithSticker = localAgent.load(type: [StickerBannersMyProductList].self) {
            
            self.productListBannersWithSticker.value = productListBannersWithSticker
        }
        
        if let currency = localAgent.load(type: [CurrencyData].self) {
            
            self.currencyList.value = currency
        }
        
        if let bankList = localAgent.load(type: [BankData].self) {
            
            self.bankList.value = bankList
        }
        
        if let bankListFullInfo = localAgent.load(type: [BankFullInfoData].self) {
            
            self.bankListFullInfo.value = bankListFullInfo
        }
        
        if let countriesList = localAgent.load(type: [CountryData].self) {
            
            self.countriesList.value = countriesList
        }

        if let productsList = productsListCacheLoadData() {
            
            self.accountProductsList.value = productsList
        }
        
        if let paymentSystemList = localAgent.load(type: [PaymentSystemData].self) {
            
            self.paymentSystemList.value = paymentSystemList
        }
        
        if let rates = localAgent.load(type: [ExchangeRateData].self) {
            
            self.rates.value = rates
        }

        if let deposits = localAgent.load(type: [DepositProductData].self) {
            
            self.deposits.value = deposits
        }
        
        if let images = localAgent.load(type: [String: ImageData].self) {
            
            self.images.value = images
        }
        
        if let currencyWalletList = localAgent.load(type: [CurrencyWalletData].self) {
            
            self.currencyWalletList.value = currencyWalletList
        }
                
        loadLanding()
                
        if let qrMapping = localAgent.load(type: QRMapping.self) {
            
            self.qrMapping.value = qrMapping
        }
    }
    
    func loadLanding() {
        
        self.transferLanding.value = .success(localAgent.load(.transfer))
        self.orderCardLanding.value = .success(localAgent.load(.orderCard))
    }

    func loadCachedAuthorizedData() {
        
        self.products.value = productsCacheLoad()

        if let paymentTemplates = localAgent.load(type: [PaymentTemplateData].self) {
            
            self.paymentTemplates.value = paymentTemplates
        }
        
        if let productTemplates = localAgent.load(type: [ProductTemplateData].self) {
        
            self.productTemplates.value = productTemplates
        }
        
        if localAgent.serial(for: StatementsData.self) == Self.statementsSerial,
           let statements = localAgent.load(type: StatementsData.self) {
            
            self.statements.value = statements
        }
        
        if let fastPaymentSettings = localAgent.load(type: [FastPaymentContractFullInfoType].self) {
            
            self.fastPaymentContractFullInfo.value = fastPaymentSettings
        }
        
        self.clientInfo.value = localAgent.load(type: ClientInfoData.self)
        self.clientPhoto.value = localAgent.load(type: ClientPhotoData.self)
        self.clientName.value = localAgent.load(type: ClientNameData.self)
        
        if let loans = localAgent.load(type: LoansData.self) {
            
            self.loans.value = loans
        }
        
        if let depositsInfo = localAgent.load(type: DepositsInfoData.self) {
            
            self.depositsInfo.value = depositsInfo
        }
        
        if let bankClientInfo = localAgent.load(type: Set<BankClientInfo>.self) {
            
            self.bankClientsInfo.value = bankClientInfo
        }
        
        if let paymentsByPhone = localAgent.load(type: [String: [PaymentPhoneData]].self) {
            
            self.paymentsByPhone.value = paymentsByPhone
        }
        
        if let depositsCloseNotified = localAgent.load(type: Set<DepositCloseNotification>.self) {
            
            self.depositsCloseNotified = depositsCloseNotified
        } else {
            
            self.depositsCloseNotified = []
        }
    }
    
    func loadSettings() {
        
        if let userSettings = localAgent.load(type: [UserSettingData].self) {
            
            self.userSettings.value = userSettings
        }
    }
    
    func clearKeychainData() {
        
        do {
            
            try keychainAgent.clear(type: .pincode)
            try keychainAgent.clear(type: .serverDeviceGUID)

        } catch {
            
            //TODO: set logger
        }
    }
    
    func clearCachedAuthorizedData() {
                
        do {
            
            try localAgent.clear(type: [PaymentTemplateData].self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try productsCacheClear()
            
        } catch {
            
            //TODO: set logger
        }

        do {

            try productsListCacheClearData()

        } catch {

            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: StatementsData.self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: ClientInfoData.self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: [DepositProductData].self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: ClientPhotoData.self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: ClientNameData.self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: LoansData.self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: [LatestPaymentData].self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: DepositsInfoData.self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: [ProductData.ID].self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: [NotificationData].self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: [FastPaymentContractFullInfoType].self)
            
        } catch {
            
            //TODO: set logger
        }
        do {
            
            try localAgent.clear(type: Set<DepositCloseNotification>.self)
            
        } catch {
            
            LoggerAgent.shared.log(category: .cache, message: "Clear temporary chache error: \(error)")
        }
    }
    
    func clearMemoryData() {
        
        products.value = [:]
        productsUpdating.value = []
        productsVisibilityUpdating.value = []
        loans.value = []
        loansUpdating.value = []
        statements.value = [:]
        statementsUpdating.value = [:]
        paymentTemplates.value = []
        latestPayments.value = []
        latestPaymentsUpdating.value = false
        notifications.value = []
        clientInfo.value = nil
        clientPhoto.value = nil
        clientName.value = nil
        currentUserLocation.value = nil
        dictionariesUpdating.value = []
        currencyWalletList.value = []
        userSettings.value = []
        qrMapping.value = nil
        productsOpening.value = []
        productTemplates.value = []
        
        LoggerAgent.shared.log(category: .model, message: "Memory data cleaned")
    }
}

// MARK: - Adapter

private extension LocalAgentProtocol {
    
    func load(_ abroadType: AbroadType) -> UILanding? {
        
        switch abroadType {
        case .transfer:
            return load(type: LocalAgentDomain.AbroadTransfer.self)
                .map(\.landing)
                .map(UILanding.init)
            
        case .orderCard:
            return load(type: LocalAgentDomain.AbroadOrderCard.self)
                .map(\.landing)
                .map(UILanding.init)
            
        case .sticker:
            return load(type: LocalAgentDomain.AbroadSticker.self)
                .map(\.landing)
                .map(UILanding.init)
            
        case .main:
            return load(type: LocalAgentDomain.MainCard.self)
                .map(\.landing)
                .map(UILanding.init)

        case .regular:
            return load(type: LocalAgentDomain.RegularCard.self)
                .map(\.landing)
                .map(UILanding.init)
            
        case .additionalSelf:
            return load(type: LocalAgentDomain.AdditionalSelfCard.self)
                .map(\.landing)
                .map(UILanding.init)
            
        case .additionalSelfAccOwn:
            return load(type: LocalAgentDomain.AdditionalSelfAccOwnCard.self)
                .map(\.landing)
                .map(UILanding.init)

        case .additionalOther:
            return load(type: LocalAgentDomain.AdditionalOtherCard.self)
                .map(\.landing)
                .map(UILanding.init)
        }
    }
}

//MARK: - Extensions

extension ChaChaPolyEncryptionAgent: EncryptionAgent {}

// MARK: - Local Agent Domain

enum LocalAgentDomain {}

extension LocalAgentDomain {
    
    typealias Landing = CodableLanding
        
    struct AbroadOrderCard: Codable {
        
        let landing: Landing
    }
    
    struct AbroadTransfer: Codable {
        
        let landing: Landing
    }
    
    struct AbroadSticker: Codable {
        
        let landing: Landing
    }

    struct MainCard: Codable {
        
        let landing: Landing
    }
    
    struct RegularCard: Codable {
        
        let landing: Landing
    }
    
    struct AdditionalSelfCard: Codable {
        
        let landing: Landing
    }

    struct AdditionalSelfAccOwnCard: Codable {
        
        let landing: Landing
    }

    struct AdditionalOtherCard: Codable {
        
        let landing: Landing
    }
}

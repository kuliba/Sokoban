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
    let productsFastUpdating: CurrentValueSubject<Set<ProductData.ID>, Never>
    let productsHidden: CurrentValueSubject<[ProductData.ID], Never>
    var productsAllowed: Set<ProductType> { [.card, .account, .deposit, .loan] }
    let loans: CurrentValueSubject<LoansData, Never>
    let loansUpdating: CurrentValueSubject<Set<ProductData.ID>, Never>
    let depositsInfo: CurrentValueSubject<DepositsInfoData, Never>

    //MARK: Account
    let accountProductsList: CurrentValueSubject<[OpenAccountProductData], Never>
    
    //MARK: Statements
    let statements: CurrentValueSubject<StatementsData, Never>
    let statementsUpdating: CurrentValueSubject<[ProductData.ID: ProductStatementsUpdateState], Never>
    
    //MARK: Currency rates
    let rates: CurrentValueSubject<[ExchangeRateData], Never>
    let ratesUpdating: CurrentValueSubject<[Currency], Never>
    var ratesAllowed: Set<Currency> { [.usd, .eur] }
    
    //MARK: Dictionaries
    let dictionariesUpdating: CurrentValueSubject<Set<DictionaryType>, Never>
    let catalogProducts: CurrentValueSubject<[CatalogProductData], Never>
    let catalogBanners: CurrentValueSubject<[BannerCatalogListData], Never>
    let currencyList: CurrentValueSubject<[CurrencyData], Never>
    let countriesList: CurrentValueSubject<[CountryData], Never>
    let paymentSystemList: CurrentValueSubject<[PaymentSystemData], Never>
    let bankList: CurrentValueSubject<[BankData], Never>
    let currencyWalletList: CurrentValueSubject<[CurrencyWalletData], Never>
    let centralBankRates: CurrentValueSubject<[CentralBankRatesData], Never>
    var images: CurrentValueSubject<[String: ImageData], Never>
    
    //MARK: Deposits
    let deposits: CurrentValueSubject<[DepositProductData], Never>
    
    //MARK: Templates
    let paymentTemplates: CurrentValueSubject<[PaymentTemplateData], Never>
    //TODO: move to settings agent
    let paymentTemplatesViewSettings: CurrentValueSubject<TemplatesListViewModel.Settings, Never>
    
    //MARK: LatestAllPayments
    let latestPayments: CurrentValueSubject<[LatestPaymentData], Never>
    let latestPaymentsUpdating: CurrentValueSubject<Bool, Never>
    
    //MARK: Notifications
    let notifications: CurrentValueSubject<[NotificationData], Never>
    let notificationsTransition: CurrentValueSubject<NotificationTransition?, Never>
    
    //MARK: - Client Info
    let clientInfo: CurrentValueSubject<ClientInfoData?, Never>
    let clientPhoto: CurrentValueSubject<ClientPhotoData?, Never>
    let clientName: CurrentValueSubject<ClientNameData?, Never>
    let fastPaymentContractFullInfo: CurrentValueSubject<[FastPaymentContractFullInfoType], Never>
    
    //MARK: - User Settings
    let userSettings: CurrentValueSubject<[UserSettingData], Never>

    //MARK: Loacation
    let currentUserLoaction: CurrentValueSubject<LocationData?, Never>

    //MARK: Informer
    let informer: CurrentValueSubject<InformerData?, Never>

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
    internal let contactsAgent: ContactsAgentProtocol
    internal let cameraAgent: CameraAgentProtocol
    internal let imageGalleryAgent: ImageGalleryAgentProtocol
    
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
    
    init(sessionAgent: SessionAgentProtocol, serverAgent: ServerAgentProtocol, localAgent: LocalAgentProtocol, keychainAgent: KeychainAgentProtocol, settingsAgent: SettingsAgentProtocol, biometricAgent: BiometricAgentProtocol, locationAgent: LocationAgentProtocol, contactsAgent: ContactsAgentProtocol, cameraAgent: CameraAgentProtocol, imageGalleryAgent: ImageGalleryAgentProtocol) {
        
        self.action = .init()
        self.auth = .init(.registerRequired)
        self.products = .init([:])
        self.productsUpdating = .init([])
        self.accountProductsList = .init([])
        self.productsFastUpdating = .init([])
        self.productsHidden = .init([])
        self.loans = .init([])
        self.loansUpdating = .init([])
        self.depositsInfo = .init(DepositsInfoData())
        self.statements = .init([:])
        self.statementsUpdating = .init([:])
        self.rates = .init([])
        self.ratesUpdating = .init([])
        self.catalogProducts = .init([])
        self.catalogBanners = .init([])
        self.currencyList = .init([])
        self.currencyWalletList = .init([])
        self.centralBankRates = .init([])
        self.bankList = .init([])
        self.countriesList = .init([])
        self.paymentSystemList = .init([])
        self.images = .init([:])
        self.deposits = .init([])
        self.paymentTemplates = .init([])
        self.paymentTemplatesViewSettings = .init(.initial)
        self.latestPayments = .init([])
        self.latestPaymentsUpdating = .init(false)
        self.notifications = .init([])
        self.clientInfo = .init(nil)
        self.clientPhoto = .init(nil)
        self.clientName = .init(nil)
        self.fastPaymentContractFullInfo = .init([])
        self.currentUserLoaction = .init(nil)
        self.informer = .init(nil)
        self.notificationsTransition = .init(nil)
        self.dictionariesUpdating = .init([])
        self.userSettings = .init([])
        
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
        self.bindings = []

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
        
        // contacts agent
        let contactsAgent = ContactsAgent()
        
        // camera agent
        let cameraAgent = CameraAgent()
        
        // imageGallery agent
        let imageGalleryAgent = ImageGalleryAgent()
        
        return Model(sessionAgent: sessionAgent, serverAgent: serverAgent, localAgent: localAgent, keychainAgent: keychainAgent, settingsAgent: settingsAgent, biometricAgent: biometricAgent, locationAgent: locationAgent, contactsAgent: contactsAgent, cameraAgent: cameraAgent, imageGalleryAgent: imageGalleryAgent)
    }()
    
    private func bind(sessionAgent: SessionAgentProtocol) {
        
        sessionAgent.sessionState
            .receive(on: queue)
            .sink { [unowned self] sessionState in
                
                switch sessionState {
                case .inactive:
                    auth.value = authIsCredentialsStored ? .signInRequired : .registerRequired
                    action.send(ModelAction.Auth.Session.Start.Request())
                    
                case .active:
                    loadCachedPublicData()
                    action.send(ModelAction.Dictionary.UpdateCache.All())

                case .expired, .failed:
                    guard auth.value == .authorized else {
                        return
                    }
                    auth.value = authIsCredentialsStored ? .unlockRequired : .registerRequired
                }
                
            }.store(in: &bindings)
    }
    
    private func bind() {
        
        auth
            .receive(on: queue)
            .sink { [unowned self] auth in
                
                switch auth {
                case .authorized:
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
                    
                default:
                    break
                }
                
            }.store(in: &bindings)

        sessionAgent.action
            .receive(on: queue)
            .sink { [unowned self] action in
                
                switch action {
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
        
        contactsAgent.status
            .receive(on: queue)
            .sink { [unowned self] status in
                
                action.send(ModelAction.Contacts.PermissionStatus.Update(status: status))
                
        }.store(in: &bindings)
        
        action
            .receive(on: queue)
            .sink {[unowned self] action in
                
                switch action {
                    
                    //MARK: - App
                    
                case _ as ModelAction.App.Launched:
                    handleAppFirstLaunch()
                    bind(sessionAgent: sessionAgent)

                case _ as ModelAction.App.Activated:
                    sessionAgent.action.send(SessionAgentAction.Timer.Start())
                    
                case _ as ModelAction.App.Inactivated:
                    sessionAgent.action.send(SessionAgentAction.Timer.Stop())
                    
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
                 
                case _ as ModelAction.Auth.Session.Terminate:
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
                    switch payload {
                    case .success:
                        auth.value = .authorized
                    
                    default:
                        break
                    }
                    
                case _ as ModelAction.Auth.Logout:
                    clearKeychainData()
                    clearCachedAuthorizedData()
                    clearMemoryData()
                    sessionAgent.action.send(SessionAgentAction.Session.Terminate())
                    
                    //MARK: - Products Actions
                    
                case _ as ModelAction.Products.Update.Fast.All:
                    handleProductsUpdateFastAll()
                    
                case let payload as ModelAction.Products.Update.Fast.Single.Request:
                    handleProductsUpdateFastSingleRequest(payload)
                    
                case _ as ModelAction.Products.Update.Total.All:
                    handleProductsUpdateTotalAll()

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
                    
                case let payload as ModelAction.Card.Unblock.Request:
                    handleUnblockCardRequest(payload)
                    
                case let payload as ModelAction.Card.Block.Request:
                    handleBlockCardRequest(payload)
                    
                    //MARK: - Statement
                    
                case let payload as ModelAction.Statement.List.Request:
                    handleStatementRequest(payload)
                    
                    //MARK: - Rates
                    
                case _ as ModelAction.Rates.Update.All:
                    handleRatesUpdateAll()
                    
                    //MARK: - Payments
                    
                case let payload as ModelAction.Payment.Services.Request:
                    handlePaymentsServicesRequest(payload)
                    
                case let payload as ModelAction.Payment.Begin.Request:
                    handlePaymentsBeginRequest(payload)
                    
                case let payload as ModelAction.Payment.Continue.Request:
                    handlePaymentsContinueRequest(payload)
                    
                case let payload as ModelAction.Payment.Complete.Request:
                    handlePaymentsCompleteRequest(payload)

                case let payload as ModelAction.Payment.OperationDetail.Request:
                    handleOperationDetailRequest(payload)
                    
                case let payload as ModelAction.Payment.OperationDetailByPaymentId.Request:
                    handleOperationDetailByPaymentIdRequest(payload)
                    
                    //MARK: - Transfers
                    
                case let payload as ModelAction.Transfers.CreateInterestDepositTransfer.Request:
                    handleCreateInterestDepositTransferRequest(payload)
                    
                case let payload as ModelAction.Transfers.TransferLimit.Request:
                    handleTransferLimitRequest(payload)
                    
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
                    
                    //MARK: - User Settings
                case let payload as ModelAction.Settings.UpdateUserSettingPush:
                    handleUpdateUserSetting(payload)
                    
                case let _ as ModelAction.Settings.GetUserSettings:
                    handleGetUserSettings()
                    
                    //MARK: - Settings Actions
                    
                case let payload as ModelAction.Settings.UpdateProductsHidden:
                    handleUpdateProductsHidden(payload.productID)
                    
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
                    
                    case .currencyWalletList:
                        handleDictionaryCurrencyWalletList(payload.serial)
                        
                    case .centralBanksRates:
                        handleDictionaryCentralBankRates()
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

                // MARK: - Informer

                case let payload as ModelAction.Account.Informer.Show:
                    handleInformerShow(payload: payload)

                case let payload as ModelAction.Account.Informer.Dismiss:
                    handleInformerDismiss(payload: payload)

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
        
        if let catalogBanner = localAgent.load(type: [BannerCatalogListData].self) {
            
            self.catalogBanners.value = catalogBanner
        }
        
        if let currency = localAgent.load(type: [CurrencyData].self) {
            
            self.currencyList.value = currency
        }
        
        if let bankList = localAgent.load(type: [BankData].self) {
            
            self.bankList.value = bankList
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
    }
    
    func loadCachedAuthorizedData() {
        
        self.products.value = productsCacheLoadData()
        
        if let paymentTemplates = localAgent.load(type: [PaymentTemplateData].self) {
            
            self.paymentTemplates.value = paymentTemplates
        }
        
        if let statements = localAgent.load(type: StatementsData.self) {
            
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
    }
    
    func loadSettings() {
        
        do {
            
            let productsHidden: [ProductData.ID] = try settingsAgent.load(type: .interface(.productsHidden))
            self.productsHidden.value = productsHidden
            
        } catch {
            
            handleSettingsCachingError(error: error)
        }
        
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
            
            try productsCacheClearData()
            
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
            
            try localAgent.clear(type: [NotificationData].self)
            
        } catch {
            
            //TODO: set logger
        }
        
        do {
            
            try localAgent.clear(type: [FastPaymentContractFullInfoType].self)
            
        } catch {
            
            //TODO: set logger
        }
    }
    
    func clearMemoryData() {
        
        products.value = [:]
        productsUpdating.value = []
        productsHidden.value = []
        loans.value = []
        loansUpdating.value = []
        statements.value = [:]
        statementsUpdating.value = [:]
        paymentTemplates.value = []
        paymentTemplatesViewSettings.value = .initial
        latestPayments.value = []
        latestPaymentsUpdating.value = false
        notifications.value = []
        clientInfo.value = nil
        clientPhoto.value = nil
        clientName.value = nil
        currentUserLoaction.value = nil
        dictionariesUpdating.value = []
        currencyWalletList.value = []
        userSettings.value = []
        
        print("Model: memory data cleaned")
    }
}

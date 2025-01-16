// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-vortex",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .fastPaymentsSettings,
        .loadableModel,
        .loadableResourceComponent,
        .operatorsListComponents,
        .paymentSticker,
        .phoneNumberWrapper,
        .sberQR,
        .sharedAPIInfra,
        .textFieldModel,
        .productProfile,
        // Landing
        .codableLanding,
        .landingMapping,
        .landingUIComponent,
        .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend,
        .collateralLoanLandingCreateDraftCollateralLoanApplicationUI,
        .collateralLoanLandingGetConsentsBackend,
        .collateralLoanLandingGetCollateralLandingBackend,
        .collateralLoanLandingGetCollateralLandingUI,
        .collateralLoanLandingGetShowcaseBackend,
        .collateralLoanLandingGetShowcaseUI,
        .collateralLoanLandingSaveConsentsBackend,
        // Infra
        .ephemeralStores,
        .fetcher,
        .genericLoader,
        .keyChainStore,
        .serialComponents,
        // Payments
        .anywayPayment,
        .latestPaymentsBackendV2,
        .latestPaymentsBackendV3,
        .operatorsListBackendV0,
        .serviceCategoriesBackendV0,
        .paymentTemplateBackendV3,
        .payHub,
        .payHubUI,
        .utilityPayment,
        .utilityServicePrepayment,
        // Banners
        .banners,
        // MarketShowcase
        .marketShowcase,
        .modifyC2BSubscriptionService,
        // Services
        .cardStatementAPI,
        .svCardLimitAPI,
        .getBannerCatalogListAPI,
        .getBannersMyProductListService,
        .cryptoSwaddler,
        .cvvPin,
        .cvvPIN_Services,
        .cvvPINServices,
        .vortexCrypto,
        .genericRemoteService,
        .getProcessingSessionCodeService,
        .getInfoRepeatPaymentService,
        .serverAgent,
        .symmetricEncryption,
        .transferPublicKey,
        .urlRequestFactory,
        .getProductListByTypeService,
        .getProductListByTypeV6Service,
        .getProductListByTypeV7Service,
        .getClientInformDataServices,
        .savingsServices,
        // UI
        .buttonWithSheet,
        .c2bSubscriptionUI,
        .calendarUI,
        .clientInformList,
        .flowCore,
        .linkableText,
        .manageSubscriptionsUI,
        .orderCard,
        .otpInputComponent,
        .pickerWithPreviewComponent,
        .pinCodeUI,
        .prePaymentPicker,
        .productUI,
        .rxViewModel,
        .savingsAccount,
        .searchBarComponent,
        .textFieldComponent,
        .uiKitHelpers,
        .uiPrimitives,
        .userAccountNavigationComponent,
        // UI Components
        .bottomSheetComponent,
        .carouselComponent,
        .dropDownTextListComponent,
        .openNewProductComponent,
        .paymentComponents,
        .productProfileComponents,
        .selectorComponents,
        .toggleComponent,
        // Utilities
        .remoteServices,
        // tools
        .vortexTools,
        // WIP: Explorations
        .userModel,
    ],
    dependencies: [
        .combineSchedulers,
        .customDump,
        .phoneNumberKit,
        .tagged,
        .shimmer,
        .svgKit,
    ],
    targets: [
        .fastPaymentsSettings,
        .fastPaymentsSettingsTests,
        .loadableModel,
        .loadableModelTests,
        .loadableResourceComponent,
        .loadableResourceComponentTests,
        .paymentSticker,
        .paymentStickerTests,
        .phoneNumberWrapper,
        .phoneNumberWrapperTests,
        .productProfile,
        .productProfileTests,
        .sberQR,
        .sberQRTests,
        .sharedAPIInfra,
        .sharedAPIInfraTests,
        .textFieldDomain,
        .textFieldDomainTests,
        .textFieldModel,
        .textFieldModelTests,
        // Landing
        .codableLanding,
        .landingMapping,
        .landingMappingTests,
        .landingUIComponent,
        .landingUIComponentTests,
        .collateralLoanLandingGetShowcaseBackend,
        .collateralLoanLandingGetShowcaseBackendTests,
        .collateralLoanLandingGetShowcaseUI,
        .collateralLoanLandingGetShowcaseUITests,
        .collateralLoanLandingGetConsentsBackend,
        .collateralLoanLandingGetConsentsBackendTests,
        .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend,
        .collateralLoanLandingCreateDraftCollateralLoanApplicationBackendTests,
        .collateralLoanLandingCreateDraftCollateralLoanApplicationUI,
        .collateralLoanLandingCreateDraftCollateralLoanApplicationUITests,
        .collateralLoanLandingGetCollateralLandingBackend,
        .collateralLoanLandingGetCollateralLandingBackendTests,
        .collateralLoanLandingGetCollateralLandingUI,
        .collateralLoanLandingGetCollateralLandingUITests,
        .collateralLoanLandingSaveConsentsBackend,
        .collateralLoanLandingSaveConsentsBackendTests,
        // Infra
        .ephemeralStores,
        .ephemeralStoresTests,
        .fetcher,
        .fetcherTests,
        .genericLoader,
        .genericLoaderTests,
        .keyChainStore,
        .keyChainStoreTests,
        .serialComponents,
        .serialComponentsTests,
        // Payments
        .anywayPaymentAdapters,
        .anywayPaymentAdaptersTests,
        .anywayPaymentBackend,
        .anywayPaymentBackendTests,
        .anywayPaymentCore,
        .anywayPaymentCoreTests,
        .anywayPaymentDomain,
        .anywayPaymentUI,
        .anywayPaymentUITests,
        .latestPaymentsBackendV2,
        .latestPaymentsBackendV2Tests,
        .latestPaymentsBackendV3,
        .latestPaymentsBackendV3Tests,
        .operatorsListBackendV0,
        .operatorsListBackendV0Tests,
        .serviceCategoriesBackendV0,
        .serviceCategoriesBackendV0Tests,
        .paymentTemplateBackendV3,
        .paymentTemplateBackendV3Tests,
        .payHub,
        .payHubTests,
        .payHubUI,
        .payHubUITests,
        .utilityPayment,
        .utilityPaymentTests,
        .utilityServicePrepaymentCore,
        .utilityServicePrepaymentCoreTests,
        .utilityServicePrepaymentDomain,
        .utilityServicePrepaymentUI,
        // Banners
        .banners,
        // MarketShowcase
        .marketShowcase,
        .marketShowcaseTests,
        .modifyC2BSubscriptionService,
        // Services
        .cardStatementAPI,
        .cardStatementAPITests,
        .svCardLimitAPI,
        .svCardLimitAPITests,
        .getBannerCatalogListAPI,
        .getBannerCatalogListAPITests,
        .getBannersMyProductListService,
        .getBannersMyProductListServiceTests,
        .cryptoSwaddler,
        .cryptoSwaddlerTests,
        .cvvPin,
        .cvvPinTests,
        .cvvPIN_Services,
        .cvvPIN_ServicesTests,
        .cvvPINServices,
        .cvvPINServicesTests,
        .vortexCrypto,
        .vortexCryptoTests,
        .genericRemoteService,
        .genericRemoteServiceTests,
        .getProcessingSessionCodeService,
        .getProcessingSessionCodeServiceTests,
        .getInfoRepeatPaymentService,
        .getInfoRepeatPaymentServiceTests,
        .serverAgent,
        .serverAgentTests,
        .symmetricEncryption,
        .symmetricEncryptionTests,
        .transferPublicKey,
        .transferPublicKeyTests,
        .urlRequestFactory,
        .urlRequestFactoryTests,
        .getProductListByTypeService,
        .getProductListByTypeServiceTests,
        .getProductListByTypeV6Service,
        .getProductListByTypeV6ServiceTests,
        .getProductListByTypeV7Service,
        .getProductListByTypeV7ServiceTests,
        .getClientInformDataServices,
        .getClientInformDataServicesTests,
        .savingsServices,
        .savingsServicesTests,
        // UI
        .activateSlider,
        .activateSliderTests,
        .accountInfoPanel,
        .accountInfoPanelTests,
        .calendarUI,
        .calendarUITests,
        .cardUI,
        .cardUITests,
        .productDetailsUI,
        .productDetailsUITests,
        .buttonWithSheet,
        .c2bSubscriptionUI,
        .cardGuardianUI,
        .cardGuardianUITests,
        .clientInformList,
        .clientInformListTests,
        .linkableText,
        .linkableTextTests,
        .flowCore,
        .flowCoreTests,
        .manageSubscriptionsUI,
        .otpInputComponent,
        .otpInputComponentTests,
        .operatorsListComponents,
        .operatorsListComponentsTests,
        .orderCard,
        .pickerWithPreviewComponent,
        .pickerWithPreviewComponentTests,
        .pinCodeUI,
        .pinCodeUITests,
        .prePaymentPicker,
        .prePaymentPickerTests,
        .productUI,
        .rxViewModel,
        .rxViewModelTests,
        .savingsAccount,
        .savingsAccountTests,
        .searchBarComponent,
        .textFieldComponent,
        .textFieldComponentTests,
        .textFieldUI,
        .textFieldUITests,
        .topUpCardUI,
        .topUpCardUITests,
        .uiKitHelpers,
        .uiPrimitives,
        .uiPrimitivesTests,
        .userAccountNavigationComponent,
        .userAccountNavigationComponentTests,
        // UI Components
        .amountComponent,
        .amountComponentTests,
        .buttonComponent,
        .infoComponent,
        .checkBoxComponent,
        .dropDownTextListComponent,
        .footerComponent,
        .nameComponent,
        .openNewProductComponent,
        .optionalSelectorComponent,
        .optionalSelectorComponentTests,
        .selectComponent,
        .selectComponentTests,
        .selectorComponent,
        .selectorComponentTests,
        .toggleComponent,
        .inputPhoneComponent,
        .inputComponent,
        .inputComponentTests,
        .paymentCompletionUI,
        .paymentComponents,
        .productProfileComponents,
        .productSelectComponent,
        .productSelectComponentTests,
        .sharedConfigs,
        .bottomSheetComponent,
        .carouselComponent,
        .carouselComponentTests,
        // Utilities
        .remoteServices,
        .remoteServicesTests,
        // tools
        .vortexTools,
        .vortexToolsTests,
        // WIP: Explorations
        .wipTests,
        .userModel,
        .userModelTests,
    ]
)

private extension Product {
    
    static let fastPaymentsSettings = library(
        name: .fastPaymentsSettings,
        targets: [
            .fastPaymentsSettings,
        ]
    )
    
    static let loadableModel = library(
        name: .loadableModel,
        targets: [
            .loadableModel,
        ]
    )
    
    static let loadableResourceComponent = library(
        name: .loadableResourceComponent,
        targets: [
            .loadableResourceComponent,
        ]
    )
    
    static let paymentSticker = library(
        name: .paymentSticker,
        targets: [
            .paymentSticker,
        ]
    )
    
    static let phoneNumberWrapper = library(
        name: .phoneNumberWrapper,
        targets: [
            .phoneNumberWrapper,
        ]
    )
    
    static let productProfile = library(
        name: .productProfile,
        targets: [
            .productProfile,
            .getInfoRepeatPaymentService
        ]
    )
    
    static let sberQR = library(
        name: .sberQR,
        targets: [
            .sberQR,
        ]
    )
    
    static let sharedAPIInfra = library(
        name: .sharedAPIInfra,
        targets: [
            .sharedAPIInfra,
        ]
    )
    
    static let textFieldModel = library(
        name: .textFieldModel,
        targets: [
            .textFieldModel,
        ]
    )
    
    static let userModel = library(
        name: .userModel,
        targets: [
            .userModel
        ]
    )
    
    // MARK: - Landing
    
    static let codableLanding = library(
        name: .codableLanding,
        targets: [
            .codableLanding
        ]
    )
    
    static let landingMapping = library(
        name: .landingMapping,
        targets: [
            .landingMapping
        ]
    )
    
    static let landingUIComponent = library(
        name: .landingUIComponent,
        targets: [
            .landingUIComponent
        ]
    )
    
    static let collateralLoanLandingGetShowcaseBackend = library(
        name: .collateralLoanLandingGetShowcaseBackend,
        targets: [
            .collateralLoanLandingGetShowcaseBackend
        ]
    )

    static let collateralLoanLandingGetShowcaseUI = library(
        name: .collateralLoanLandingGetShowcaseUI,
        targets: [
            .collateralLoanLandingGetShowcaseUI
        ]
    )

    static let collateralLoanLandingGetConsentsBackend = library(
        name: .collateralLoanLandingGetConsentsBackend,
        targets: [
            .collateralLoanLandingGetConsentsBackend
        ]
    )

    static let collateralLoanLandingCreateDraftCollateralLoanApplicationBackend = library(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend,
        targets: [
            .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend
        ]
    )

    static let collateralLoanLandingCreateDraftCollateralLoanApplicationUI = library(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationUI,
        targets: [
            .collateralLoanLandingCreateDraftCollateralLoanApplicationUI
        ]
    )
    
    static let collateralLoanLandingGetCollateralLandingBackend = library(
        name: .collateralLoanLandingGetCollateralLandingBackend,
        targets: [
            .collateralLoanLandingGetCollateralLandingBackend
        ]
    )

    static let collateralLoanLandingGetCollateralLandingUI = library(
        name: .collateralLoanLandingGetCollateralLandingUI,
        targets: [
            .collateralLoanLandingGetCollateralLandingUI
        ]
    )
        
    static let collateralLoanLandingSaveConsentsBackend = library(
        name: .collateralLoanLandingSaveConsentsBackend,
        targets: [
            .collateralLoanLandingSaveConsentsBackend
        ]
    )
        
    // MARK: - UI
    
    static let activateSlider = library(
        name: .activateSlider,
        targets: [
            .activateSlider
        ]
    )
    
    static let accountInfoPanel = library(
        name: .accountInfoPanel,
        targets: [
            .accountInfoPanel
        ]
    )
    
    static let calendarUI = library(
        name: .calendarUI,
        targets: [
            .calendarUI
        ]
    )
    
    
    static let cardUI = library(
        name: .cardUI,
        targets: [
            .cardUI
        ]
    )
    
    static let clientInformList = library(
        name: .clientInformList,
        targets: [
            .clientInformList
        ]
    )

    static let productDetailsUI = library(
        name: .productDetailsUI,
        targets: [
            .productDetailsUI
        ]
    )
        
    static let buttonWithSheet = library(
        name: .buttonWithSheet,
        targets: [
            .buttonWithSheet
        ]
    )
    
    static let c2bSubscriptionUI = library(
        name: .c2bSubscriptionUI,
        targets: [
            .c2bSubscriptionUI
        ]
    )
    
    static let cardGuardianUI = library(
        name: .cardGuardianUI,
        targets: [
            .cardGuardianUI
        ]
    )
    
    static let linkableText = library(
        name: .linkableText,
        targets: [
            .linkableText
        ]
    )
    
    static let flowCore = library(
        name: .flowCore,
        targets: [
            .flowCore
        ]
    )
    
    static let manageSubscriptionsUI = library(
        name: .manageSubscriptionsUI,
        targets: [
            .manageSubscriptionsUI,
        ]
    )
    
    static let otpInputComponent = library(
        name: .otpInputComponent,
        targets: [
            .otpInputComponent,
        ]
    )
    
    static let operatorsListComponents = library(
        name: .operatorsListComponents,
        targets: [
            .operatorsListComponents
        ]
    )
    
    static let orderCard = library(
        name: .orderCard,
        targets: [
            .orderCard
        ]
    )
    
    static let pickerWithPreviewComponent = library(
        name: .pickerWithPreviewComponent,
        targets: [
            .pickerWithPreviewComponent,
        ]
    )
    
    static let pinCodeUI = library(
        name: .pinCodeUI,
        targets: [
            .pinCodeUI,
        ]
    )
    
    static let prePaymentPicker = library(
        name: .prePaymentPicker,
        targets: [
            .prePaymentPicker,
        ]
    )
    
    static let productUI = library(
        name: .productUI,
        targets: [
            .productUI,
        ]
    )
    
    static let rxViewModel = library(
        name: .rxViewModel,
        targets: [
            .rxViewModel,
        ]
    )
    
    static let savingsAccount = library(
        name: .savingsAccount,
        targets: [
            .savingsAccount,
        ]
    )
    
    static let searchBarComponent = library(
        name: .searchBarComponent,
        targets: [
            .searchBarComponent,
        ]
    )
    
    static let textFieldComponent = library(
        name: .textFieldComponent,
        targets: [
            .textFieldComponent,
        ]
    )
    static let topUpCardUI = library(
        name: .topUpCardUI,
        targets: [
            .topUpCardUI,
        ]
    )
    
    static let uiKitHelpers = library(
        name: .uiKitHelpers,
        targets: [
            .uiKitHelpers,
        ]
    )
    
    static let uiPrimitives = library(
        name: .uiPrimitives,
        targets: [
            .uiPrimitives,
        ]
    )
    
    static let userAccountNavigationComponent = library(
        name: .userAccountNavigationComponent,
        targets: [
            .userAccountNavigationComponent,
            .manageSubscriptionsUI
        ]
    )

    // MARK: - UI Components
    
    static let bottomSheetComponent = library(
        name: .bottomSheetComponent,
        targets: [
            .bottomSheetComponent
        ]
    )
    
    static let carouselComponent = library(
        name: .carouselComponent,
        targets: [
            .carouselComponent,
            .rxViewModel
        ]
    )
    
    static let dropDownTextListComponent = library(
        name: .dropDownTextListComponent,
        targets: [.dropDownTextListComponent]
    )

    static let openNewProductComponent = library(
        name: .openNewProductComponent,
        targets: [.openNewProductComponent]
    )
    
    static let paymentComponents = library(
        name: .paymentComponents,
        targets: [
            .amountComponent,
            .buttonComponent,
            .carouselComponent,
            .checkBoxComponent,
            .footerComponent,
            .infoComponent,
            .inputComponent,
            .inputPhoneComponent,
            .nameComponent,
            .paymentComponents,
            .paymentCompletionUI,
            .productSelectComponent,
            .selectComponent,
            // .selectorComponent,
            .sharedConfigs,
        ]
    )
        
    static let productProfileComponents = library(
        name: .productProfileComponents,
        targets: [
            .activateSlider,
            .accountInfoPanel,
            .cardUI,
            .productDetailsUI,
            .cardGuardianUI,
            .productProfileComponents,
            .topUpCardUI,
            .calendarUI
        ]
    )
    
    static let selectorComponents = library(
        name: .selectorComponents,
        targets: [
            .optionalSelectorComponent,
            .selectorComponent,
        ]
    )
    
    static let toggleComponent = library(
        name: .toggleComponent,
        targets: [
            .toggleComponent
        ]
    )
    
    // MARK: - Utilities
    
    static let remoteServices = library(
        name: .remoteServices,
        targets: [
            .remoteServices
        ]
    )
    
    // MARK: - Infra
    
    static let ephemeralStores = library(
        name: .ephemeralStores,
        targets: [
            .ephemeralStores
        ]
    )
    
    static let fetcher = library(
        name: .fetcher,
        targets: [
            .fetcher
        ]
    )
    
    static let genericLoader = library(
        name: .genericLoader,
        targets: [
            .genericLoader
        ]
    )
    
    static let keyChainStore = library(
        name: .keyChainStore,
        targets: [
            .keyChainStore
        ]
    )
    
    static let serialComponents = library(
        name: .serialComponents,
        targets: [
            .serialComponents
        ]
    )
    
    // MARK: - Payments
    
    static let anywayPayment = library(
        name: .anywayPayment,
        targets: [
            .anywayPaymentAdapters,
            .anywayPaymentBackend,
            .anywayPaymentCore,
            .anywayPaymentDomain,
            .anywayPaymentUI,
        ]
    )
    
    static let latestPaymentsBackendV2 = library(
        name: .latestPaymentsBackendV2,
        targets: [
            .latestPaymentsBackendV2,
        ]
    )
    
    static let latestPaymentsBackendV3 = library(
        name: .latestPaymentsBackendV3,
        targets: [
            .latestPaymentsBackendV3,
        ]
    )
    
    static let operatorsListBackendV0 = library(
        name: .operatorsListBackendV0,
        targets: [
            .operatorsListBackendV0,
        ]
    )
    
    static let serviceCategoriesBackendV0 = library(
        name: .serviceCategoriesBackendV0,
        targets: [
            .serviceCategoriesBackendV0,
        ]
    )
    
    static let paymentTemplateBackendV3 = library(
        name: .paymentTemplateBackendV3,
        targets: [
            .paymentTemplateBackendV3,
        ]
    )
    
    static let payHub = library(
        name: .payHub,
        targets: [
            .payHub,
        ]
    )
    
    static let payHubUI = library(
        name: .payHubUI,
        targets: [
            .payHubUI,
        ]
    )
    
    static let utilityPayment = library(
        name: .utilityPayment,
        targets: [
            .utilityPayment,
        ]
    )
    
    static let utilityServicePrepayment = library(
        name: .utilityServicePrepayment,
        targets: [
            .utilityServicePrepaymentCore,
            .utilityServicePrepaymentDomain,
            .utilityServicePrepaymentUI,
        ]
    )
    
    // MARK: - Banners
    
    static let banners = library(
        name: .banners,
        targets: [
            .banners,
        ]
    )
    
    // MARK: - MarketShowcase
    
    static let marketShowcase = library(
        name: .marketShowcase,
        targets: [
            .marketShowcase,
        ]
    )
    
    static let modifyC2BSubscriptionService = library(
        name: .modifyC2BSubscriptionService,
        targets: [
            .modifyC2BSubscriptionService,
        ]
    )
    // MARK: - Services
    
    static let cardStatementAPI = library(
        name: .cardStatementAPI,
        targets: [
            .cardStatementAPI,
        ]
    )
    
    static let svCardLimitAPI = library(
        name: .svCardLimitAPI,
        targets: [
            .svCardLimitAPI,
        ]
    )
    
    static let getBannerCatalogListAPI = library(
        name: .getBannerCatalogListAPI,
        targets: [
            .getBannerCatalogListAPI,
        ]
    )
    
    static let getBannersMyProductListService = library(
        name: .getBannersMyProductListService,
        targets: [
            .getBannersMyProductListService
        ]
    )
    
    static let cryptoSwaddler = library(
        name: .cryptoSwaddler,
        targets: [
            .cryptoSwaddler,
        ]
    )
    
    static let cvvPin = library(
        name: .cvvPin,
        targets: [
            .cvvPin,
        ]
    )
    
    static let genericRemoteService = library(
        name: .genericRemoteService,
        targets: [
            .genericRemoteService,
        ]
    )
    
    static let vortexCrypto = library(
        name: .vortexCrypto,
        targets: [
            .vortexCrypto,
        ]
    )
    
    static let getProcessingSessionCodeService = library(
        name: .getProcessingSessionCodeService,
        targets: [
            .getProcessingSessionCodeService,
        ]
    )
    
    static let getInfoRepeatPaymentService = library(
        name: .getInfoRepeatPaymentService,
        targets: [
            .getInfoRepeatPaymentService,
        ]
    )
    
    static let serverAgent = library(
        name: .serverAgent,
        targets: [
            .serverAgent,
        ]
    )
    
    static let symmetricEncryption = library(
        name: .symmetricEncryption,
        targets: [
            .symmetricEncryption,
        ]
    )
    
    
    static let cvvPIN_Services = library(
        name: .cvvPIN_Services,
        targets: [
            .cvvPIN_Services
        ]
    )
    
    static let cvvPINServices = library(
        name: .cvvPINServices,
        targets: [
            .cvvPINServices
        ]
    )
    
    static let urlRequestFactory = library(
        name: .urlRequestFactory,
        targets: [
            .urlRequestFactory
        ]
    )
    
    static let transferPublicKey = library(
        name: .transferPublicKey,
        targets: [
            .transferPublicKey,
        ]
    )
    
    static let getProductListByTypeService = library(
        name: .getProductListByTypeService,
        targets: [
            .getProductListByTypeService
        ]
    )
    
    static let getProductListByTypeV6Service = library(
        name: .getProductListByTypeV6Service,
        targets: [
            .getProductListByTypeV6Service
        ]
    )
    
    static let getProductListByTypeV7Service = library(
        name: .getProductListByTypeV7Service,
        targets: [
            .getProductListByTypeV7Service
        ]
    )

    static let getClientInformDataServices = library(
        name: .getClientInformDataServices,
        targets: [
            .getClientInformDataServices
        ]
    )
    
    static let savingsServices = library(
        name: .savingsServices,
        targets: [
            .savingsServices
        ]
    )
    
    // MARK: - Tools
    
    static let vortexTools = library(
        name: .vortexTools,
        targets: [
            .vortexTools,
        ]
    )
}

// MARK: - Target

private extension Target {
    
    static let fastPaymentsSettings = target(
        name: .fastPaymentsSettings,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .c2bSubscriptionUI,
            .paymentComponents,
            .rxViewModel,
            .remoteServices,
            .uiPrimitives,
        ]
    )
    static let fastPaymentsSettingsTests = testTarget(
        name: .fastPaymentsSettingsTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .fastPaymentsSettings,
            .rxViewModel,
        ]
    )
    
    static let loadableModel = target(
        name: .loadableModel,
        dependencies: [
            // external packages
            .combineSchedulers,
        ]
    )
    static let loadableModelTests = testTarget(
        name: .loadableModelTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .loadableModel,
        ]
    )
    
    static let loadableResourceComponent = target(
        name: .loadableResourceComponent,
        dependencies: [
            // external packages
            .combineSchedulers,
        ]
    )
    static let loadableResourceComponentTests = testTarget(
        name: .loadableResourceComponentTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .loadableResourceComponent,
        ]
    )
    
    static let paymentSticker = target(
        name: .paymentSticker,
        dependencies: [
            .genericRemoteService,
            .textFieldComponent
        ]
    )
    
    static let paymentStickerTests = testTarget(
        name: .paymentStickerTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .paymentSticker
        ]
    )
    
    static let phoneNumberWrapper = target(
        name: .phoneNumberWrapper,
        dependencies: [
            .phoneNumberKit
        ]
    )
    
    static let phoneNumberWrapperTests = testTarget(
        name: .phoneNumberWrapperTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .phoneNumberWrapper,
        ]
    )
    
    static let productProfile = target(
        name: .productProfile,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .productProfileComponents,
            .uiPrimitives,
            .remoteServices
        ]
    )
    
    static let productProfileTests = testTarget(
        name: .productProfileTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .productProfile,
            .rxViewModel,
            .remoteServices,
        ]
    )
    
    static let sberQR = target(
        name: .sberQR,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .amountComponent,
            .buttonComponent,
            .vortexTools,
            .infoComponent,
            .paymentComponents,
            .productSelectComponent,
            .sharedConfigs,
        ]
    )
    
    static let sberQRTests = testTarget(
        name: .sberQRTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .amountComponent,
            .buttonComponent,
            .sberQR,
        ],
        resources: [
            .copy("QRPaymentTypeDictionary/Resources/QRPaymentType.json"),
            .copy("BackendDomain/Responses/getSberQRData_any_sum.json"),
            .copy("BackendDomain/Responses/getSberQRData_fix_sum.json"),
            .copy("BackendDomain/Responses/createSberQRPayment_IN_PROGRESS.json"),
            .copy("BackendDomain/Responses/createSberQRPayment_rejected.json"),
            .copy("BackendDomain/Responses/createSberQRPayment.json"),
        ]
    )
    
    static let sharedAPIInfra = target(
        name: .sharedAPIInfra
    )
    static let sharedAPIInfraTests = testTarget(
        name: .sharedAPIInfraTests,
        dependencies: [
            .sharedAPIInfra,
        ]
    )
    
    static let textFieldDomain = target(
        name: .textFieldDomain,
        dependencies: []
    )
    static let textFieldDomainTests = testTarget(
        name: .textFieldDomainTests,
        dependencies: [
            .customDump,
            .textFieldDomain,
        ]
    )
    
    static let textFieldModel = target(
        name: .textFieldModel,
        dependencies: [
            .combineSchedulers,
            .textFieldDomain,
        ]
    )
    static let textFieldModelTests = testTarget(
        name: .textFieldModelTests,
        dependencies: [
            .combineSchedulers,
            .customDump,
            .textFieldDomain,
            .textFieldModel,
        ]
    )
    
    // MARK: - Landing
    
    static let codableLanding = target(
        name: .codableLanding,
        dependencies: [
            .tagged,
        ],
        path: "Sources/Landing/\(String.codableLanding)"
    )
    
    static let landingMapping = target(
        name: .landingMapping,
        dependencies: [
            .tagged,
        ],
        path: "Sources/Landing/\(String.landingMapping)"
    )
    static let landingMappingTests = testTarget(
        name: .landingMappingTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .landingMapping,
        ],
        path: "Tests/Landing/\(String.landingMappingTests)"
    )
    
    static let landingUIComponent = target(
        name: .landingUIComponent,
        dependencies: [
            .bottomSheetComponent,
            .combineSchedulers,
            .vortexTools,
            .rxViewModel,
            .sharedConfigs,
            .shimmer,
            .svCardLimitAPI,
            .tagged,
            .textFieldComponent,
            .uiPrimitives,
        ],
        path: "Sources/Landing/\(String.landingUIComponent)"
    )
    static let landingUIComponentTests = testTarget(
        name: .landingUIComponentTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .landingUIComponent,
            .sharedConfigs
        ],
        path: "Tests/Landing/\(String.landingUIComponentTests)"
    )

    static let collateralLoanLandingGetShowcaseBackend = target(
        name: .collateralLoanLandingGetShowcaseBackend,
        dependencies: [
            .remoteServices,
            .sharedConfigs
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.collateralLoanLandingGetShowcaseName)/Backend"
    )
    
    static let collateralLoanLandingGetShowcaseBackendTests = testTarget(
        name: .collateralLoanLandingGetShowcaseBackendTests,
        dependencies: [
            .collateralLoanLandingGetShowcaseBackend,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.collateralLoanLandingGetShowcaseName)Tests/Backend"
    )
    
    static let collateralLoanLandingGetShowcaseUI = target(
        name: .collateralLoanLandingGetShowcaseUI,
        dependencies: [
            .rxViewModel,
            .uiPrimitives
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.collateralLoanLandingGetShowcaseName)/UI"
    )
    
    static let collateralLoanLandingGetShowcaseUITests = testTarget(
        name: .collateralLoanLandingGetShowcaseUITests,
        dependencies: [
            .collateralLoanLandingGetShowcaseUI,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.collateralLoanLandingGetShowcaseName)Tests/UI"
    )

    static let collateralLoanLandingGetConsentsBackend = target(
        name: .collateralLoanLandingGetConsentsBackend,
        dependencies: [
            .remoteServices,
            .vortexTools
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.collateralLoanLandingGetConsentsName)/Backend"
    )
    
    static let collateralLoanLandingGetConsentsBackendTests = testTarget(
        name: .collateralLoanLandingGetConsentsBackendTests,
        dependencies: [
            .collateralLoanLandingGetConsentsBackend,
            .customDump,
            .vortexTools
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.collateralLoanLandingGetConsentsName)Tests/Backend",
        resources: [
            .copy("Resources/valid.pdf")
        ]
    )
    
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationBackend = target(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend,
        dependencies: [
            .remoteServices
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.collateralLoanLandingCreateDraftCollateralLoanApplicationName)/Backend/V1"
    )
    
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationBackendTests = testTarget(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationBackendTests,
        dependencies: [
            .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.collateralLoanLandingCreateDraftCollateralLoanApplicationName)Tests/Backend/V1"
    )

    static let collateralLoanLandingCreateDraftCollateralLoanApplicationUI = target(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationUI,
        dependencies: [
            .uiPrimitives,
            .paymentComponents
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.collateralLoanLandingCreateDraftCollateralLoanApplicationName)/UI"
    )

    static let collateralLoanLandingCreateDraftCollateralLoanApplicationUITests = testTarget(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationUITests,
        dependencies: [
            .collateralLoanLandingCreateDraftCollateralLoanApplicationUI,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.collateralLoanLandingCreateDraftCollateralLoanApplicationName)Tests/UI"
    )

    static let collateralLoanLandingGetCollateralLandingBackend = target(
        name: .collateralLoanLandingGetCollateralLandingBackend,
        dependencies: [
            .vortexTools,
            .remoteServices
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.GetCollateralLanding)/Backend/V1"
    )
    
    static let collateralLoanLandingGetCollateralLandingBackendTests = testTarget(
        name: .collateralLoanLandingGetCollateralLandingBackendTests,
        dependencies: [
            .collateralLoanLandingGetCollateralLandingBackend,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.GetCollateralLanding)Tests/Backend/V1"
    )

    static let collateralLoanLandingGetCollateralLandingUI = target(
        name: .collateralLoanLandingGetCollateralLandingUI,
        dependencies: [
            .dropDownTextListComponent,
            .rxViewModel,
            .sharedConfigs,
            .toggleComponent,
            .uiPrimitives        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.GetCollateralLanding)/UI"
    )
    
    static let collateralLoanLandingGetCollateralLandingUITests = testTarget(
        name: .collateralLoanLandingGetCollateralLandingUITests,
        dependencies: [
            .collateralLoanLandingGetCollateralLandingUI,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.GetCollateralLanding)Tests/UI"
    )

    static let collateralLoanLandingSaveConsentsBackend = target(
        name: .collateralLoanLandingSaveConsentsBackend,
        dependencies: [
            .remoteServices,
            .sharedConfigs
        ],
        path: "Sources/Landing/\(String.collateralLoan)/\(String.SaveConsents)/Backend"
    )
    
    static let collateralLoanLandingSaveConsentsBackendTests = testTarget(
        name: .collateralLoanLandingSaveConsentsBackendTests,
        dependencies: [
            .collateralLoanLandingSaveConsentsBackend,
            .customDump
        ],
        path: "Tests/Landing/\(String.collateralLoanTests)/\(String.SaveConsents)Tests/Backend"
    )
    
    // MARK: - Infra
    
    static let ephemeralStores = target(
        name: .ephemeralStores,
        dependencies: [
            .vortexTools,
            .genericLoader,
        ],
        path: "Sources/Infra/\(String.ephemeralStores)"
    )
    static let ephemeralStoresTests = testTarget(
        name: .ephemeralStoresTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .ephemeralStores,
        ],
        path: "Tests/Infra/\(String.ephemeralStoresTests)"
    )
    
    static let fetcher = target(
        name: .fetcher,
        path: "Sources/Infra/\(String.fetcher)"
    )
    static let fetcherTests = testTarget(
        name: .fetcherTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .fetcher,
        ],
        path: "Tests/Infra/\(String.fetcherTests)"
    )
    
    static let genericLoader = target(
        name: .genericLoader,
        path: "Sources/Infra/\(String.genericLoader)"
    )
    static let genericLoaderTests = testTarget(
        name: .genericLoaderTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .genericLoader,
        ],
        path: "Tests/Infra/\(String.genericLoaderTests)"
    )
    
    static let keyChainStore = target(
        name: .keyChainStore,
        path: "Sources/Infra/\(String.keyChainStore)"
    )
    static let keyChainStoreTests = testTarget(
        name: .keyChainStoreTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .keyChainStore,
        ],
        path: "Tests/Infra/\(String.keyChainStoreTests)"
    )
    
    static let serialComponents = target(
        name: .serialComponents,
        dependencies: [
            .vortexTools,
        ],
        path: "Sources/Infra/\(String.serialComponents)"
    )
    static let serialComponentsTests = testTarget(
        name: .serialComponentsTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .ephemeralStores,
            .vortexTools,
            .genericLoader,
            .serialComponents,
        ],
        path: "Tests/Infra/\(String.serialComponentsTests)"
    )
    
    // MARK: - Payments
    
    static let anywayPaymentAdapters = target(
        name: .anywayPaymentAdapters,
        dependencies: [
            .anywayPaymentBackend,
            .anywayPaymentCore,
            .anywayPaymentDomain,
            .anywayPaymentUI,
            .remoteServices,
            .tagged,
        ],
        path: "Sources/Payments/AnywayPayment/\(String.anywayPaymentAdapters)"
    )
    static let anywayPaymentAdaptersTests = testTarget(
        name: .anywayPaymentAdaptersTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .anywayPaymentAdapters,
            .anywayPaymentBackend,
            .anywayPaymentCore,
            .anywayPaymentDomain,
            .remoteServices,
            .tagged,
        ],
        path: "Tests/Payments/AnywayPayment/\(String.anywayPaymentAdaptersTests)"
    )
    
    static let anywayPaymentBackend = target(
        name: .anywayPaymentBackend,
        dependencies: [
            .remoteServices,
            .tagged,
        ],
        path: "Sources/Payments/AnywayPayment/\(String.anywayPaymentBackend)"
    )
    static let anywayPaymentBackendTests = testTarget(
        name: .anywayPaymentBackendTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .anywayPaymentBackend,
            .remoteServices,
            .tagged,
        ],
        path: "Tests/Payments/AnywayPayment/\(String.anywayPaymentBackendTests)"
    )
    
    static let anywayPaymentCore = target(
        name: .anywayPaymentCore,
        dependencies: [
            .anywayPaymentDomain,
            .vortexTools,
            .remoteServices,
            .tagged,
        ],
        path: "Sources/Payments/AnywayPayment/\(String.anywayPaymentCore)"
    )
    static let anywayPaymentCoreTests = testTarget(
        name: .anywayPaymentCoreTests,
        dependencies: [
            // external packages
            .customDump,
            .tagged,
            // internal modules
            .anywayPaymentAdapters,
            .anywayPaymentBackend,
            .anywayPaymentCore,
            .anywayPaymentDomain,
            .vortexTools,
            .remoteServices,
            .rxViewModel,
        ],
        path: "Tests/Payments/AnywayPayment/\(String.anywayPaymentCoreTests)"
    )
    
    static let anywayPaymentDomain = target(
        name: .anywayPaymentDomain,
        dependencies: [
            .remoteServices,
            .tagged,
        ],
        path: "Sources/Payments/AnywayPayment/\(String.anywayPaymentDomain)"
    )
    
    static let anywayPaymentUI = target(
        name: .anywayPaymentUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            // internal modules
            .anywayPaymentCore,
            .anywayPaymentDomain,
            .vortexTools,
            .paymentComponents,
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/Payments/AnywayPayment/\(String.anywayPaymentUI)"
    )
    static let anywayPaymentUITests = testTarget(
        name: .anywayPaymentUITests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .anywayPaymentUI,
            .vortexTools,
            .remoteServices,
            .rxViewModel,
        ],
        path: "Tests/Payments/AnywayPayment/\(String.anywayPaymentUITests)"
    )
    
    static let latestPaymentsBackendV2 = target(
        name: .latestPaymentsBackendV2,
        dependencies: [
            // internal modules
            .remoteServices,
        ],
        path: "Sources/Payments/LatestPayments/Backend/V2"
    )
    static let latestPaymentsBackendV2Tests = testTarget(
        name: .latestPaymentsBackendV2Tests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .latestPaymentsBackendV2,
            .remoteServices,
        ],
        path: "Tests/Payments/LatestPayments/Backend/V2"
    )
    
    static let latestPaymentsBackendV3 = target(
        name: .latestPaymentsBackendV3,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
            .vortexTools,
            .remoteServices,
        ],
        path: "Sources/Payments/LatestPayments/Backend/V3"
    )
    static let latestPaymentsBackendV3Tests = testTarget(
        name: .latestPaymentsBackendV3Tests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .latestPaymentsBackendV3,
            .remoteServices,
        ],
        path: "Tests/Payments/LatestPayments/Backend/V3",
        resources: [
            .copy("Resources/v3_getAllLatestPayments.json")
        ]
    )
    
    static let operatorsListBackendV0 = target(
        name: .operatorsListBackendV0,
        dependencies: [
            // internal modules
            .vortexTools,
            .remoteServices,
        ],
        path: "Sources/Payments/OperatorsList/Backend/V0"
    )
    static let operatorsListBackendV0Tests = testTarget(
        name: .operatorsListBackendV0Tests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .operatorsListBackendV0,
            .remoteServices,
        ],
        path: "Tests/Payments/OperatorsList/Backend/V0",
        resources: [
            .copy("Resources/getOperatorsListByParam.json")
        ]
    )
    
    static let serviceCategoriesBackendV0 = target(
        name: .serviceCategoriesBackendV0,
        dependencies: [
            // internal modules
            .remoteServices,
        ],
        path: "Sources/Payments/ServiceCategories/Backend/V0"
    )
    static let serviceCategoriesBackendV0Tests = testTarget(
        name: .serviceCategoriesBackendV0Tests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .serviceCategoriesBackendV0,
            .remoteServices,
        ],
        path: "Tests/Payments/ServiceCategories/Backend/V0"
    )
    
    static let paymentTemplateBackendV3 = target(
        name: .paymentTemplateBackendV3,
        dependencies: [
            // internal modules
            .remoteServices,
        ],
        path: "Sources/Payments/PaymentTemplate/Backend/V3"
    )
    static let paymentTemplateBackendV3Tests = testTarget(
        name: .paymentTemplateBackendV3Tests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .paymentTemplateBackendV3,
            .remoteServices,
        ],
        path: "Tests/Payments/PaymentTemplate/Backend/V3",
        resources: [
            .copy("Resources/v3_getPaymentTemplateList.json"),
            .copy("Resources/v3_getPaymentTemplateList_housing.json"),
            .copy("Resources/v3_getPaymentTemplateList_newFields.json"),
            .copy("Resources/v3_getPaymentTemplateList_one.json"),
        ]
    )
    
    static let payHub = target(
        name: .payHub,
        dependencies: [
            // external packages
            .combineSchedulers,
            // internal modules
            .flowCore,
            .rxViewModel,
        ],
        path: "Sources/Payments/\(String.payHub)"
    )
    static let payHubTests = testTarget(
        name: .payHubTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .payHub,
        ],
        path: "Tests/Payments/\(String.payHubTests)"
    )
    
    static let payHubUI = target(
        name: .payHubUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            // internal modules
            .flowCore,
            .payHub,
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/Payments/\(String.payHubUI)"
    )
    static let payHubUITests = testTarget(
        name: .payHubUITests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .payHub,
            .payHubUI,
        ],
        path: "Tests/Payments/\(String.payHubUITests)"
    )
    
    static let utilityPayment = target(
        name: .utilityPayment,
        dependencies: [
            .vortexTools,
            .prePaymentPicker,
            .tagged,
        ],
        path: "Sources/Payments/\(String.utilityPayment)"
    )
    static let utilityPaymentTests = testTarget(
        name: .utilityPaymentTests,
        dependencies: [
            // external packages
            .customDump,
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .utilityPayment,
        ],
        path: "Tests/Payments/\(String.utilityPaymentTests)"
    )
    
    static let utilityServicePrepaymentCore = target(
        name: .utilityServicePrepaymentCore,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
            .vortexTools,
            .utilityServicePrepaymentDomain,
        ],
        path: "Sources/Payments/UtilityServicePrepayment/Core"
    )
    static let utilityServicePrepaymentDomain = target(
        name: .utilityServicePrepaymentDomain,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
            .vortexTools,
        ],
        path: "Sources/Payments/UtilityServicePrepayment/Domain"
    )
    static let utilityServicePrepaymentUI = target(
        name: .utilityServicePrepaymentUI,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
            .vortexTools,
            .uiPrimitives,
            .utilityServicePrepaymentDomain,
        ],
        path: "Sources/Payments/UtilityServicePrepayment/UI"
    )
    static let utilityServicePrepaymentCoreTests = testTarget(
        name: .utilityServicePrepaymentCoreTests,
        dependencies: [
            // external packages
            .customDump,
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .utilityServicePrepaymentCore,
            .utilityServicePrepaymentDomain,
        ],
        path: "Tests/Payments/UtilityServicePrepayment/CoreTests"
    )
    
    // MARK: - Banners
    
    static let banners = target(
        name: .banners,
        dependencies: [
            // external packages
            .combineSchedulers,
            // internal modules
            .payHub,
            .payHubUI,
            .rxViewModel,
            .uiPrimitives,
            .sharedConfigs,
        ],
        path: "Sources/\(String.banners)"
    )
    
    // MARK: - MarketShowcase
    
    static let marketShowcase = target(
        name: .marketShowcase,
        dependencies: [
            // external packages
            .combineSchedulers,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/\(String.marketShowcase)"
    )
    static let marketShowcaseTests = testTarget(
        name: .marketShowcaseTests,
        dependencies: [
            // external packages
            .customDump,
            .combineSchedulers,
            // internal modules
            .marketShowcase,
        ],
        path: "Tests/\(String.marketShowcaseTests)"
    )

    static let modifyC2BSubscriptionService = target(
        name: .modifyC2BSubscriptionService,
        dependencies: [
            .genericRemoteService,
            .remoteServices,
            .vortexTools,
            .uiPrimitives
        ],
        path: "Sources/Services/\(String.modifyC2BSubscriptionService)"
    )
    
    // MARK: - Services
    
    static let cardStatementAPI = target(
        name: .cardStatementAPI,
        dependencies: [
            .tagged,
        ],
        path: "Sources/\(String.cardStatementAPI)"
    )
    static let cardStatementAPITests = testTarget(
        name: .cardStatementAPITests,
        dependencies: [
            // external packages
            .customDump,
            .combineSchedulers,
            .tagged,
            // internal modules
            .cardStatementAPI,
        ],
        path: "Tests/\(String.cardStatementAPITests)",
        resources: [
            .copy("Resources/GetProductDynamicParamsList.json"),
            .copy("Resources/StatementSample.json"),
        ]
    )
    
    static let svCardLimitAPI = target(
        name: .svCardLimitAPI,
        dependencies: [
            .remoteServices,
        ],
        path: "Sources/\(String.svCardLimitAPI)"
    )
    static let svCardLimitAPITests = testTarget(
        name: .svCardLimitAPITests,
        dependencies: [
            // external packages
            .customDump,
            .combineSchedulers,
            // internal modules
            .svCardLimitAPI,
        ],
        path: "Tests/\(String.svCardLimitAPITests)"
        //TODO: add resources
    )
    
    static let getBannerCatalogListAPI = target(
        name: .getBannerCatalogListAPI,
        dependencies: [
            .remoteServices,
        ],
        path: "Sources/Services/\(String.getBannerCatalogListAPI)"
    )
    static let getBannerCatalogListAPITests = testTarget(
        name: .getBannerCatalogListAPITests,
        dependencies: [
            // external packages
            .customDump,
            .combineSchedulers,
            // internal modules
            .getBannerCatalogListAPI,
        ],
        path: "Tests/Services/\(String.getBannerCatalogListAPITests)"
        //TODO: add resources
    )

    static let getBannersMyProductListService = target(
        name: .getBannersMyProductListService,
        dependencies: [
            .remoteServices,
            .vortexTools
        ],
        path: "Sources/Services/\(String.getBannersMyProductListService)"
    )
    static let getBannersMyProductListServiceTests = testTarget(
        name: .getBannersMyProductListServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .getBannersMyProductListService,
            .remoteServices
        ],
        path: "Tests/Services/\(String.getBannersMyProductListServiceTests)"
    )

    static let cryptoSwaddler = target(
        name: .cryptoSwaddler,
        dependencies: [
            .vortexCrypto,
            .transferPublicKey
        ]
    )
    static let cryptoSwaddlerTests = testTarget(
        name: .cryptoSwaddlerTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .cryptoSwaddler,
            .vortexCrypto,
            .transferPublicKey
        ]
    )
    
    static let cvvPin = target(
        name: .cvvPin,
        dependencies: [
            // external packages
            .combineSchedulers,
        ]
    )
    
    static let cvvPinTests = testTarget(
        name: .cvvPinTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .cvvPin,
        ]
    )
    
    static let operatorsComponent = target(
        name: .operatorsListComponents,
        dependencies: [
            // internal packages
            .rxViewModel,
            .prePaymentPicker,
            .remoteServices
        ]
    )
    
    static let operatorsComponentTests = testTarget(
        name: .operatorsListComponentsTests,
        dependencies: [
            //            .operatorsListComponents
        ],
        path: "Tests/Services/\(String.operatorsListComponentsTests)"
    )
    
    static let cvvPIN_Services = target(
        name: .cvvPIN_Services,
        path: "Sources/Services/\(String.cvvPIN_Services)"
    )
    
    static let cvvPIN_ServicesTests = testTarget(
        name: .cvvPIN_ServicesTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .cvvPIN_Services,
        ],
        path: "Tests/Services/\(String.cvvPIN_ServicesTests)"
    )
    
    static let cvvPINServices = target(
        name: .cvvPINServices,
        dependencies: [
            .genericLoader
        ],
        path: "Sources/Services/\(String.cvvPINServices)"
    )
    static let cvvPINServicesTests = testTarget(
        name: .cvvPINServicesTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .cvvPINServices,
        ],
        path: "Tests/Services/\(String.cvvPINServicesTests)"
    )
    
    static let vortexCrypto = target(
        name: .vortexCrypto,
        resources: [
            .copy("Resources/public.crt"),
            .copy("Resources/der.crt"),
            .copy("Resources/publicCert.pem"),
            .copy("Resources/generatepin.pem"),
        ]
    )
    
    static let vortexCryptoTests = testTarget(
        name: .vortexCryptoTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .vortexCrypto,
        ]
    )
    
    static let genericRemoteService = target(
        name: .genericRemoteService,
        path: "Sources/Services/\(String.genericRemoteService)"
    )
    
    static let genericRemoteServiceTests = testTarget(
        name: .genericRemoteServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .genericRemoteService,
        ],
        path: "Tests/Services/\(String.genericRemoteServiceTests)"
    )
    
    static let getProcessingSessionCodeService = target(
        name: .getProcessingSessionCodeService,
        path: "Sources/Services/\(String.getProcessingSessionCodeService)"
    )
    
    static let getProcessingSessionCodeServiceTests = testTarget(
        name: .getProcessingSessionCodeServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .getProcessingSessionCodeService,
        ],
        path: "Tests/Services/\(String.getProcessingSessionCodeServiceTests)"
    )
    
    static let getInfoRepeatPaymentService = target(
        name: .getInfoRepeatPaymentService,
        dependencies: [
            .remoteServices
        ],
        path: "Sources/Services/\(String.getInfoRepeatPaymentService)"
    )
    
    static let getInfoRepeatPaymentServiceTests = testTarget(
        name: .getInfoRepeatPaymentServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .getInfoRepeatPaymentService,
            .remoteServices
        ],
        path: "Tests/Services/\(String.getInfoRepeatPaymentServiceTests)"
    )
    
    static let serverAgent = target(
        name: .serverAgent,
        path: "Sources/Services/\(String.serverAgent)"
    )
    static let serverAgentTests = testTarget(
        name: .serverAgentTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .serverAgent,
        ],
        path: "Tests/Services/\(String.serverAgentTests)"
    )
    
    static let symmetricEncryption = target(
        name: .symmetricEncryption
    )
    static let symmetricEncryptionTests = testTarget(
        name: .symmetricEncryptionTests,
        dependencies: [
            .symmetricEncryption,
        ]
    )
    
    static let transferPublicKey = target(
        name: .transferPublicKey,
        dependencies: [
            .vortexTools
        ],
        path: "Sources/Services/\(String.transferPublicKey)"
    )

    static let transferPublicKeyTests = testTarget(
        name: .transferPublicKeyTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .transferPublicKey,
            .vortexTools
        ],
        path: "Tests/Services/\(String.transferPublicKeyTests)"
    )
    
    static let urlRequestFactory = target(
        name: .urlRequestFactory,
        path: "Sources/Services/\(String.urlRequestFactory)"
    )
    static let urlRequestFactoryTests = testTarget(
        name: .urlRequestFactoryTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .urlRequestFactory,
        ],
        path: "Tests/Services/\(String.urlRequestFactoryTests)"
    )
    
    static let getProductListByTypeService = target(
        name: .getProductListByTypeService,
        dependencies: [
            .remoteServices
        ],
        path: "Sources/Services/\(String.getProductListByTypeService)"
    )
    
    static let getProductListByTypeServiceTests = testTarget(
        name: .getProductListByTypeServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .urlRequestFactory,
            .getProductListByTypeService
        ],
        path: "Tests/Services/\(String.getProductListByTypeServiceTests)",
        resources: [
            .copy("Responses/GetProductListByType_Account_Response.json"),
            .copy("Responses/GetProductListByType_Card_Response.json"),
            .copy("Responses/GetProductListByType_Deposit_Response.json"),
            .copy("Responses/GetProductListByType_Loan_Response.json")
        ]
    )
    
    static let getProductListByTypeV6Service = target(
        name: .getProductListByTypeV6Service,
        dependencies: [
            .remoteServices
        ],
        path: "Sources/Services/\(String.getProductListByTypeV6Service)"
    )
    
    static let getProductListByTypeV6ServiceTests = testTarget(
        name: .getProductListByTypeV6ServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .urlRequestFactory,
            .getProductListByTypeV6Service
        ],
        path: "Tests/Services/\(String.getProductListByTypeV6ServiceTests)",
        resources: [
            .copy("Responses/GetProductListByType_Account_Response.json"),
            .copy("Responses/GetProductListByType_Card_Response.json"),
            .copy("Responses/GetProductListByType_Deposit_Response.json"),
            .copy("Responses/GetProductListByType_Loan_Response.json")
        ]
    )
    
    static let getProductListByTypeV7Service = target(
        name: .getProductListByTypeV7Service,
        dependencies: [
            .vortexTools,
            .remoteServices
        ],
        path: "Sources/Services/\(String.getProductListByTypeV7Service)"
    )
    
    static let getProductListByTypeV7ServiceTests = testTarget(
        name: .getProductListByTypeV7ServiceTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .urlRequestFactory,
            .getProductListByTypeV7Service
        ],
        path: "Tests/Services/\(String.getProductListByTypeV7ServiceTests)",
        resources: [
            .copy("Responses/GetProductListByType_Account_Response.json"),
            .copy("Responses/GetProductListByType_Card_Response.json"),
            .copy("Responses/GetProductListByType_Deposit_Response.json"),
            .copy("Responses/GetProductListByType_Loan_Response.json")
        ]
    )


    static let getClientInformDataServices = target(
        name: .getClientInformDataServices,
        dependencies: [
            .remoteServices
        ],
        path: "Sources/Services/\(String.getClientInformDataServices)"
    )

    static let getClientInformDataServicesTests = testTarget(
        name: .getClientInformDataServicesTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .getClientInformDataServices
        ],
        path: "Tests/Services/\(String.getClientInformDataServicesTests)",
        resources: [

        ]
    )
    
    static let savingsServices = target(
        name: .savingsServices,
        dependencies: [
            .vortexTools,
            .remoteServices
        ],
        path: "Sources/Services/\(String.savingsServices)"
    )

    static let savingsServicesTests = testTarget(
        name: .savingsServicesTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .vortexTools,
            .savingsServices,
        ],
        path: "Tests/Services/\(String.savingsServicesTests)"
    )

    // MARK: - UI
    
    static let activateSlider = target(
        name: .activateSlider,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/UI/ProductProfile/\(String.activateSlider)"
    )
    
    static let activateSliderTests = testTarget(
        name: .activateSliderTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .activateSlider,
        ],
        path: "Tests/UI/ProductProfileTests/\(String.activateSliderTests)"
    )
    
    static let accountInfoPanel = target(
        name: .accountInfoPanel,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
            .remoteServices,
        ],
        path: "Sources/UI/ProductProfile/\(String.accountInfoPanel)"
    )
    
    static let accountInfoPanelTests = testTarget(
        name: .accountInfoPanelTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .accountInfoPanel,
            .remoteServices,
        ],
        path: "Tests/UI/ProductProfileTests/\(String.accountInfoPanelTests)"
    )
    
    static let calendarUI = target(
        name: .calendarUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/\(String.calendarUI)"
    )
    
    static let calendarUITests = target(
        name: .calendarUITests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .calendarUI,
        ],
        path: "Tests/\(String.calendarUITests)"
    )
    
    static let cardUI = target(
        name: .cardUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/UI/ProductProfile/\(String.cardUI)"
    )
    
    static let cardUITests = testTarget(
        name: .cardUITests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .cardUI,
            .remoteServices,
        ],
        path: "Tests/UI/ProductProfileTests/\(String.cardUITests)"
    )
    
    static let productDetailsUI = target(
        name: .productDetailsUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
            .remoteServices,
        ],
        path: "Sources/UI/ProductProfile/\(String.productDetailsUI)"
    )
    
    static let productDetailsUITests = testTarget(
        name: .productDetailsUITests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .productDetailsUI,
            .remoteServices,
        ],
        path: "Tests/UI/ProductProfileTests/\(String.productDetailsUITests)"
    )
    
    static let buttonWithSheet = target(
        name: .buttonWithSheet,
        path: "Sources/UI/\(String.buttonWithSheet)"
    )
    
    static let c2bSubscriptionUI = target(
        name: .c2bSubscriptionUI,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
            .searchBarComponent,
            .textFieldComponent,
            .uiPrimitives,
        ],
        path: "Sources/UI/\(String.c2bSubscriptionUI)"
    )
    
    static let cardGuardianUI = target(
        name: .cardGuardianUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/UI/ProductProfile/\(String.cardGuardianUI)"
    )
    static let cardGuardianUITests = testTarget(
        name: .cardGuardianUITests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .cardGuardianUI,
        ],
        path: "Tests/UI/ProductProfileTests/\(String.cardGuardianUITests)"
    )
    
    static let clientInformList = target(
        name: .clientInformList,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/\(String.clientInformList)"
    )
    static let clientInformListTests = testTarget(
        name: .clientInformListTests,
        dependencies: [
            .clientInformList
        ],
        path: "Tests/UI/\(String.clientInformListTests)"
    )

    static let linkableText = target(
        name: .linkableText,
        path: "Sources/UI/\(String.linkableText)"
    )
    static let linkableTextTests = testTarget(
        name: .linkableTextTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .linkableText,
        ],
        path: "Tests/UI/\(String.linkableTextTests)"
    )
    
    static let flowCore = target(
        name: .flowCore,
        dependencies: [
            // external packages
            .combineSchedulers,
            // internal modules
            .rxViewModel,
        ],
        path: "Sources/UI/\(String.flowCore)"
    )
    static let flowCoreTests = testTarget(
        name: .flowCoreTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .flowCore,
            .rxViewModel,
        ],
        path: "Tests/UI/\(String.flowCoreTests)"
    )
    
    static let manageSubscriptionsUI = target(
        name: .manageSubscriptionsUI,
        dependencies: [
        ],
        path: "Sources/\(String.manageSubscriptionsUI)"
    )
    
    static let otpInputComponent = target(
        name: .otpInputComponent,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .vortexTools,
            .rxViewModel,
            .sharedConfigs,
            .uiPrimitives,
        ],
        path: "Sources/UI/\(String.otpInputComponent)"
    )
    
    static let otpInputComponentTests = testTarget(
        name: .otpInputComponentTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .otpInputComponent,
        ],
        path: "Tests/UI/\(String.otpInputComponentTests)"
    )
    
    static let pickerWithPreviewComponent = target(
        name: .pickerWithPreviewComponent,
        dependencies: [
            .uiKitHelpers,
        ]
    )
    static let pickerWithPreviewComponentTests = testTarget(
        name: .pickerWithPreviewComponentTests,
        dependencies: [
            .pickerWithPreviewComponent,
        ]
    )
    
    static let pinCodeUI = target(
        name: .pinCodeUI,
        dependencies: [
            .tagged,
        ]
    )
    static let pinCodeUITests = testTarget(
        name: .pinCodeUITests,
        dependencies: [
            .pinCodeUI,
        ]
    )
    
    static let prePaymentPicker = target(
        name: .prePaymentPicker,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
        ],
        path: "Sources/UI/\(String.prePaymentPicker)"
    )
    
    static let prePaymentPickerTests = testTarget(
        name: .prePaymentPickerTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .rxViewModel,
            .prePaymentPicker,
        ],
        path: "Tests/UI/\(String.prePaymentPickerTests)"
    )
    
    static let productUI = target(
        name: .productUI
    )
    
    static let rxViewModel = target(
        name: .rxViewModel,
        dependencies: [
            // internal packages
            .vortexTools,
        ],
        path: "Sources/UI/\(String.rxViewModel)"
    )
    
    static let rxViewModelTests = testTarget(
        name: .rxViewModelTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .rxViewModel,
        ],
        path: "Tests/UI/\(String.rxViewModelTests)"
    )
    
    static let savingsAccount = target(
        name: .savingsAccount,
        dependencies: [
            // internal packages
            .dropDownTextListComponent,
            .linkableText,
            .paymentComponents,
            .sharedConfigs,
            .toggleComponent,
            .uiPrimitives,
        ],
        path: "Sources/UI/\(String.savingsAccount)"
    )
    
    static let savingsAccountTests = testTarget(
        name: .savingsAccountTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .savingsAccount
        ],
        path: "Tests/UI/\(String.savingsAccountTests)"
    )

    static let orderCard = target(
        name: .orderCard,
        dependencies: [
            // internal packages
            .sharedConfigs,
            .uiPrimitives,
            .rxViewModel,
        ],
        path: "Sources/UI/\(String.orderCard)"
    )
    
    static let searchBarComponent = target(
        name: .searchBarComponent,
        dependencies: [
            .textFieldComponent,
        ]
    )
    
    static let textFieldComponent = target(
        name: .textFieldComponent,
        dependencies: [
            .combineSchedulers,
            .textFieldDomain,
            .textFieldModel,
            .textFieldUI,
            .uiKitHelpers,
        ]
    )
    static let textFieldComponentTests = testTarget(
        name: .textFieldComponentTests,
        dependencies: [
            .customDump,
            .textFieldComponent,
            .textFieldDomain,
            .textFieldUI,
        ]
    )
    
    static let textFieldUI = target(
        name: .textFieldUI,
        dependencies: [
            .textFieldDomain,
            .uiKitHelpers,
        ]
    )
    static let textFieldUITests = testTarget(
        name: .textFieldUITests,
        dependencies: [
            .customDump,
            .textFieldDomain,
            .textFieldUI,
        ]
    )
    
    static let topUpCardUI = target(
        name: .topUpCardUI,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .rxViewModel,
            .uiPrimitives,
        ],
        path: "Sources/UI/ProductProfile/\(String.topUpCardUI)"
    )
    
    static let topUpCardUITests = testTarget(
        name: .topUpCardUITests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .topUpCardUI,
        ],
        path: "Tests/UI/ProductProfileTests/\(String.topUpCardUITests)"
    )
    
    static let uiKitHelpers = target(name: .uiKitHelpers)
    
    static let uiPrimitives = target(
        name: .uiPrimitives,
        dependencies: [
            .vortexTools,
            .sharedConfigs,
            .shimmer,
        ],
        path: "Sources/UI/\(String.uiPrimitives)"
    )
    
    static let uiPrimitivesTests = testTarget(
        name: .uiPrimitivesTests,
        dependencies: [
            .customDump,
            .vortexTools,
            .sharedConfigs,
            .uiPrimitives,
        ],
        path: "Tests/UI/\(String.uiPrimitivesTests)"
    )
    
    static let userAccountNavigationComponent = target(
        name: .userAccountNavigationComponent,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .fastPaymentsSettings,
            .otpInputComponent,
            .rxViewModel,
            .uiPrimitives,
            .manageSubscriptionsUI
        ],
        path: "Sources/UI/\(String.userAccountNavigationComponent)"
    )
    
    static let userAccountNavigationComponentTests = testTarget(
        name: .userAccountNavigationComponentTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .userAccountNavigationComponent,
        ],
        path: "Tests/UI/\(String.userAccountNavigationComponentTests)"
    )
    
    // MARK: - UI Components
    
    static let amountComponent = target(
        name: .amountComponent,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
            .buttonComponent,
            .vortexTools,
            .textFieldComponent,
            .sharedConfigs,
        ],
        path: "Sources/UI/Components/\(String.amountComponent)"
    )
    
    static let amountComponentTests = testTarget(
        name: .amountComponentTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .amountComponent,
            .vortexTools,
            .textFieldComponent,
            .sharedConfigs,
        ],
        path: "Tests/UI/Components/\(String.amountComponentTests)"
    )
    
    static let buttonComponent = target(
        name: .buttonComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.buttonComponent)"
    )
    
    static let checkBoxComponent = target(
        name: .checkBoxComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.checkBoxComponent)"
    )
    
    static let dropDownTextListComponent = target(
        name: .dropDownTextListComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.dropDownTextListComponent)"
    )
    
    static let footerComponent = target(
        name: .footerComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.footerComponent)"
    )
    
    static let infoComponent = target(
        name: .infoComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.infoComponent)"
    )
    
    static let nameComponent = target(
        name: .nameComponent,
        dependencies: [
            .inputComponent,
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.nameComponent)"
    )
    
    static let openNewProductComponent = target(
        name: .openNewProductComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.openNewProductComponent)"
    )
    
    static let optionalSelectorComponent = target(
        name: .optionalSelectorComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.optionalSelectorComponent)"
    )
    
    static let optionalSelectorComponentTests = testTarget(
        name: .optionalSelectorComponentTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .rxViewModel,
            // internal modules
            .optionalSelectorComponent,
        ],
        path: "Tests/UI/Components/\(String.optionalSelectorComponentTests)"
    )
    
    static let paymentCompletionUI = target(
        name: .paymentCompletionUI,
        dependencies: [
            .sharedConfigs,
            .uiPrimitives,
        ],
        path: "Sources/UI/Components/\(String.paymentCompletionUI)"
    )
    
    static let selectComponent = target(
        name: .selectComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.selectComponent)"
    )
    
    static let selectComponentTests = testTarget(
        name: .selectComponentTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            .rxViewModel,
            // internal modules
            .selectComponent,
        ],
        path: "Tests/UI/Components/\(String.selectComponentTests)"
    )
    
    static let selectorComponent = target(
        name: .selectorComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.selectorComponent)"
    )
    
    static let selectorComponentTests = testTarget(
        name: .selectorComponentTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            .rxViewModel,
            // internal modules
            .selectorComponent,
        ],
        path: "Tests/UI/Components/\(String.selectorComponentTests)"
    )
    
    static let toggleComponent = target(
        name: .toggleComponent,
        dependencies: [
            .uiPrimitives,
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.toggleComponent)"
    )
    
    static let inputPhoneComponent = target(
        name: .inputPhoneComponent,
        dependencies: [
            .phoneNumberKit,
            .phoneNumberWrapper,
            .searchBarComponent,
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.inputPhoneComponent)"
    )
    
    static let inputComponent = target(
        name: .inputComponent,
        dependencies: [
            .sharedConfigs,
            .textFieldComponent
        ],
        path: "Sources/UI/Components/\(String.inputComponent)"
    )
    
    static let inputComponentTests = testTarget(
        name: .inputComponentTests,
        dependencies: [
            .customDump,
            .inputComponent,
            .rxViewModel,
            .textFieldModel
        ],
        path: "Tests/UI/Components/\(String.inputComponentTests)"
    )
    
    static let paymentComponents = target(
        name: .paymentComponents,
        dependencies: [
            // external
            .combineSchedulers,
            // internal
            .amountComponent,
            .buttonComponent,
            .carouselComponent,
            .checkBoxComponent,
            .footerComponent,
            .infoComponent,
            .nameComponent,
            .otpInputComponent,
            .optionalSelectorComponent,
            .paymentCompletionUI,
            .inputComponent,
            .inputPhoneComponent,
            .productSelectComponent,
            .rxViewModel,
            .selectComponent,
            .selectorComponent,
            .sharedConfigs,
        ],
        path: "Sources/UI/Components/\(String.paymentComponents)"
    )
    
    static let productProfileComponents = target(
        name: .productProfileComponents,
        dependencies: [
            .activateSlider,
            .accountInfoPanel,
            .cardUI,
            .productDetailsUI,
            .cardGuardianUI,
            .topUpCardUI,
            .calendarUI
        ],
        path: "Sources/UI/ProductProfile/\(String.productProfileComponents)"
    )
    
    static let bottomSheetComponent = target(
        name: .bottomSheetComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.bottomSheetComponent)"
    )

    static let carouselComponent = target(
        name: .carouselComponent,
        dependencies: [
            .sharedConfigs,
            .rxViewModel
        ],
        path: "Sources/UI/Components/\(String.carouselComponent)"
    )
    
    static let carouselComponentTests = testTarget(
        name: .carouselComponentTests,
        dependencies: [
            .carouselComponent,
            .customDump
        ],
        path: "Tests/UI/Components/\(String.carouselComponentTests)"
    )
    
    static let operatorsListComponents = target(
        name: .operatorsListComponents,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .amountComponent,
            .buttonComponent,
            .vortexTools,
            .paymentComponents,
            .productSelectComponent,
            .prePaymentPicker,
            .remoteServices,
            .rxViewModel,
            .textFieldComponent,
            .searchBarComponent,
            .phoneNumberWrapper
        ]
    )
    
    static let operatorsListComponentsTests = testTarget(
        name: .operatorsListComponentsTests,
        dependencies: [
            .customDump,
            .operatorsListComponents
        ],
        path: "Tests/\(String.operatorsListComponentsTests)",
        resources: [
            .copy("Resources/getOperatorsListByParam_prod.json"),
        ]
    )
    
    static let productSelectComponent = target(
        name: .productSelectComponent,
        dependencies: [
            .vortexTools,
            .sharedConfigs,
            .tagged,
            .uiPrimitives,
            .carouselComponent,
        ],
        path: "Sources/UI/Components/\(String.productSelectComponent)"
    )
    
    static let productSelectComponentTests = testTarget(
        name: .productSelectComponentTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .productSelectComponent,
        ],
        path: "Tests/UI/Components/\(String.productSelectComponentTests)"
    )
    
    static let sharedConfigs = target(
        name: .sharedConfigs,
        dependencies: [
            .vortexTools,
            .tagged,
        ],
        path: "Sources/UI/Components/\(String.sharedConfigs)"
    )
    
    // MARK: - Utilities
    
    static let remoteServices = target(
        name: .remoteServices,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
        ],
        path: "Sources/Utilities/\(String.remoteServices)"
    )
    
    static let remoteServicesTests = testTarget(
        name: .remoteServicesTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .remoteServices,
        ],
        path: "Tests/Utilities/\(String.remoteServicesTests)"
    )
    
    
    // MARK: - WIP: Explorations
    
    static let wipTests = testTarget(
        name: .wipTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            .tagged,
            // internal modules
            .ephemeralStores,
            .fetcher,
            .genericLoader,
            .genericRemoteService,
            .latestPaymentsBackendV3,
            .remoteServices,
            .rxViewModel,
            .serialComponents,
            .textFieldDomain,
            .textFieldModel,
            .vortexTools,
        ]
    )
    
    static let userModel = target(name: .userModel)
    static let userModelTests = testTarget(
        name: .userModelTests,
        dependencies: [
            .userModel
        ]
    )
    
    // MARK: - Tools
    
    static let vortexTools = target(
        name: .vortexTools,
        dependencies: [
            .combineSchedulers,
            .svgKit
        ]
    )
    static let vortexToolsTests = testTarget(
        name: .vortexToolsTests,
        dependencies: [
            .combineSchedulers,
            .customDump,
            .vortexTools
        ]
    )
}

private extension Target.Dependency {
    
    static let fastPaymentsSettings = byName(
        name: .fastPaymentsSettings
    )
    
    static let loadableModel = byName(
        name: .loadableModel
    )
    
    static let loadableResourceComponent = byName(
        name: .loadableResourceComponent
    )
    
    static let operatorsListComponents = byName(
        name: .operatorsListComponents
    )
    
    static let paymentSticker = byName(
        name: .paymentSticker
    )
    
    static let phoneNumberWrapper = byName(
        name: .phoneNumberWrapper
    )
    
    static let productProfile = byName(
        name: .productProfile
    )
    
    static let sberQR = byName(
        name: .sberQR
    )
    
    static let sharedAPIInfra = byName(
        name: .sharedAPIInfra
    )
    
    static let textFieldComponent = byName(
        name: .textFieldComponent
    )
    
    static let textFieldDomain = byName(
        name: .textFieldDomain
    )
    
    static let textFieldModel = byName(
        name: .textFieldModel
    )
    
    static let userModel = byName(
        name: .userModel
    )
    
    // MARK: - Landing
    
    static let codableLanding = byName(
        name: .codableLanding
    )
    static let landingMapping = byName(
        name: .landingMapping
    )
    static let landingUIComponent = byName(
        name: .landingUIComponent
    )
    
    static let collateralLoanLandingGetShowcaseBackend = byName(
        name: .collateralLoanLandingGetShowcaseBackend
    )
    
    static let collateralLoanLandingGetShowcaseUI = byName(
        name: .collateralLoanLandingGetShowcaseUI
    )

    static let collateralLoanLandingGetConsentsBackend = byName(
        name: .collateralLoanLandingGetConsentsBackend
    )

    static let collateralLoanLandingCreateDraftCollateralLoanApplicationBackend = byName(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationBackend
    )
    
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationUI = byName(
        name: .collateralLoanLandingCreateDraftCollateralLoanApplicationUI
    )
    
    static let collateralLoanLandingGetCollateralLandingUI = byName(
        name: .collateralLoanLandingGetCollateralLandingUI
    )

    static let collateralLoanLandingGetCollateralLandingBackend = byName(
        name: .collateralLoanLandingGetCollateralLandingBackend
    )

    static let collateralLoanLandingSaveConsentsBackend = byName(
        name: .collateralLoanLandingSaveConsentsBackend
    )
    
    static let serverAgent = byName(
        name: .serverAgent
    )
    
    // MARK: - UI
    
    static let activateSlider = byName(
        name: .activateSlider
    )
    
    static let accountInfoPanel = byName(
        name: .accountInfoPanel
    )
    
    static let bottomSheetComponent = byName(
        name: .bottomSheetComponent
    )
    
    static let calendarUI = byName(
        name: .calendarUI
    )
    
    static let cardUI = byName(
        name: .cardUI
    )
    
    static let productDetailsUI = byName(
        name: .productDetailsUI
    )
    
    static let buttonWithSheet = byName(
        name: .buttonWithSheet
    )
    
    static let c2bSubscriptionUI = byName(
        name: .c2bSubscriptionUI
    )
    
    static let cardGuardianUI = byName(
        name: .cardGuardianUI
    )
    
    static let clientInformList = byName(
        name: .clientInformList
    )

    static let linkableText = byName(
        name: .linkableText
    )
    
    static let flowCore = byName(
        name: .flowCore
    )
    
    static let otpInputComponent = byName(
        name: .otpInputComponent
    )
    
    static let paymentCompletionUI = byName(
        name: .paymentCompletionUI
    )
    
    static let pickerWithPreviewComponent = byName(
        name: .pickerWithPreviewComponent
    )
    
    static let pinCodeUI = byName(
        name: .pinCodeUI
    )
    
    static let prePaymentPicker = byName(
        name: .prePaymentPicker
    )
    
    static let rxViewModel = byName(
        name: .rxViewModel
    )
    
    static let savingsAccount = byName(
        name: .savingsAccount
    )

    static let searchBarComponent = byName(
        name: .searchBarComponent
    )
    
    static let textFieldUI = byName(
        name: .textFieldUI
    )
    
    static let topUpCardUI = byName(
        name: .topUpCardUI
    )
    
    static let uiKitHelpers = byName(
        name: .uiKitHelpers
    )
    
    static let uiPrimitives = byName(
        name: .uiPrimitives
    )
    
    static let userAccountNavigationComponent = byName(
        name: .userAccountNavigationComponent
    )

    static let orderCard = byName(
        name: .orderCard
    )
    
    // MARK: - UI Components
    
    static let amountComponent = byName(
        name: .amountComponent
    )
    
    static let buttonComponent = byName(
        name: .buttonComponent
    )
    
    static let checkBoxComponent = byName(
        name: .checkBoxComponent
    )
    
    static let dropDownTextListComponent = byName(
        name: .dropDownTextListComponent
    )
    
    static let footerComponent = byName(
        name: .footerComponent
    )
    
    static let infoComponent = byName(
        name: .infoComponent
    )
    
    static let optionalSelectorComponent = byName(
        name: .optionalSelectorComponent
    )
    
    static let nameComponent = byName(
        name: .nameComponent
    )
    
    static let openNewProductComponent = byName(
        name: .openNewProductComponent
    )
    
    static let selectComponent = byName(
        name: .selectComponent
    )
    
    static let selectorComponent = byName(
        name: .selectorComponent
    )
    
    static let toggleComponent = byName(
        name: .toggleComponent
    )
    
    static let inputPhoneComponent = byName(
        name: .inputPhoneComponent
    )
    
    static let inputComponent = byName(
        name: .inputComponent
    )
    
    static let paymentComponents = byName(
        name: .paymentComponents
    )
    
    static let productProfileComponents = byName(
        name: .productProfileComponents
    )
    
    static let productSelectComponent = byName(
        name: .productSelectComponent
    )
    
    static let sharedConfigs = byName(
        name: .sharedConfigs
    )
    
    static let carouselComponent = byName(
        name: .carouselComponent
    )
    
    // MARK: - Utilities
    
    static let remoteServices = byName(
        name: .remoteServices
    )
    
    // MARK: - Infra
    
    static let ephemeralStores = byName(
        name: .ephemeralStores
    )
    
    static let fetcher = byName(
        name: .fetcher
    )
    
    static let genericLoader = byName(
        name: .genericLoader
    )
    
    static let keyChainStore = byName(
        name: .keyChainStore
    )
    
    static let serialComponents = byName(
        name: .serialComponents
    )
    
    // MARK: - Payments
    
    static let anywayPaymentAdapters = byName(
        name: .anywayPaymentAdapters
    )
    
    static let anywayPaymentBackend = byName(
        name: .anywayPaymentBackend
    )
    
    static let anywayPaymentCore = byName(
        name: .anywayPaymentCore
    )
    
    static let anywayPaymentDomain = byName(
        name: .anywayPaymentDomain
    )
    
    static let anywayPaymentUI = byName(
        name: .anywayPaymentUI
    )
    
    static let latestPaymentsBackendV2 = byName(
        name: .latestPaymentsBackendV2
    )
    
    static let latestPaymentsBackendV3 = byName(
        name: .latestPaymentsBackendV3
    )
    
    static let operatorsListBackendV0 = byName(
        name: .operatorsListBackendV0
    )
    
    static let serviceCategoriesBackendV0 = byName(
        name: .serviceCategoriesBackendV0
    )
    
    static let paymentTemplateBackendV3 = byName(
        name: .paymentTemplateBackendV3
    )
    
    static let payHub = byName(
        name: .payHub
    )
    
    static let payHubUI = byName(
        name: .payHubUI
    )
    
    static let utilityPayment = byName(
        name: .utilityPayment
    )
    
    static let utilityServicePrepaymentCore = byName(
        name: .utilityServicePrepaymentCore
    )
    
    static let utilityServicePrepaymentDomain = byName(
        name: .utilityServicePrepaymentDomain
    )
    
    // MARK: - Banners
    
    static let banners = byName(
        name: .banners
    )
    
    // MARK: - MarketShowcase
    
    static let marketShowcase = byName(
        name: .marketShowcase
    )
    
    static let modifyC2BSubscriptionService = byName(
        name: .modifyC2BSubscriptionService
    )

    static let manageSubscriptionsUI = byName(
        name: .manageSubscriptionsUI
    )
    
    // MARK: - Services
    
    static let cardStatementAPI = byName(
        name: .cardStatementAPI
    )
    
    static let svCardLimitAPI = byName(
        name: .svCardLimitAPI
    )
    
    static let getBannerCatalogListAPI = byName(
        name: .getBannerCatalogListAPI
    )
    
    static let getBannersMyProductListService = byName(
        name: .getBannersMyProductListService
    )
    
    static let cryptoSwaddler = byName(
        name: .cryptoSwaddler
    )
    
    static let cvvPin = byName(
        name: .cvvPin
    )
    
    static let cvvPIN_Services = byName(
        name: .cvvPIN_Services
    )
    
    static let cvvPINServices = byName(
        name: .cvvPINServices
    )
    
    static let vortexCrypto = byName(
        name: .vortexCrypto
    )
    
    static let genericRemoteService = byName(
        name: .genericRemoteService
    )
    
    static let getProcessingSessionCodeService = byName(
        name: .getProcessingSessionCodeService
    )
    
    static let getInfoRepeatPaymentService = byName(
        name: .getInfoRepeatPaymentService
    )
    
    static let transferPublicKey = byName(
        name: .transferPublicKey
    )
    
    static let symmetricEncryption = byName(
        name: .symmetricEncryption
    )
    
    static let urlRequestFactory = byName(
        name: .urlRequestFactory
    )
    
    static let getProductListByTypeService = byName(
        name: .getProductListByTypeService
    )
    
    static let getProductListByTypeV6Service = byName(
        name: .getProductListByTypeV6Service
    )
    
    static let getProductListByTypeV7Service = byName(
        name: .getProductListByTypeV7Service
    )

    static let getClientInformDataServices = byName(
        name: .getClientInformDataServices
    )
    
    static let savingsServices = byName(
        name: .savingsServices
    )

    // MARK: - Tools
    
    static let vortexTools = byName(
        name: .vortexTools
    )
}

private extension String {
    
    static let fastPaymentsSettings = "FastPaymentsSettings"
    static let fastPaymentsSettingsTests = "FastPaymentsSettingsTests"
    
    static let loadableModel = "LoadableModel"
    static let loadableModelTests = "LoadableModelTests"
    
    static let loadableResourceComponent = "LoadableResourceComponent"
    static let loadableResourceComponentTests = "LoadableResourceComponentTests"
    
    static let paymentSticker = "PaymentSticker"
    static let paymentStickerTests = "PaymentStickerTests"
    
    static let phoneNumberWrapper = "PhoneNumberWrapper"
    static let phoneNumberWrapperTests = "PhoneNumberWrapperTests"
    
    static let productProfile = "ProductProfile"
    static let productProfileTests = "ProductProfileTests"
    
    static let sberQR = "SberQR"
    static let sberQRTests = "SberQRTests"
    
    static let sharedAPIInfra = "SharedAPIInfra"
    static let sharedAPIInfraTests = "SharedAPIInfraTests"
    
    static let textFieldComponent = "TextFieldComponent"
    static let textFieldComponentTests = "TextFieldComponentTests"
    
    static let textFieldDomain = "TextFieldDomain"
    static let textFieldDomainTests = "TextFieldDomainTests"
    
    static let textFieldModel = "TextFieldModel"
    static let textFieldModelTests = "TextFieldModelTests"
    
    static let wipTests = "WIPTests"
    
    static let userModel = "UserModel"
    static let userModelTests = "UserModelTests"
    
    // MARK: - Landing
    
    static let codableLanding = "CodableLanding"
    
    static let landingMapping = "LandingMapping"
    static let landingMappingTests = "LandingMappingTests"
    
    static let landingUIComponent = "LandingUIComponent"
    static let landingUIComponentTests = "LandingUIComponentTests"

    // MARK: - Collateral loan landing
    
    static let collateralLoanLandingGetShowcaseName = "GetShowcase"
    static let collateralLoanLandingGetShowcaseBackend = "CollateralLoanLandingGetShowcaseBackend"
    static let collateralLoanLandingGetShowcaseBackendTests = "CollateralLoanLandingGetShowcaseBackendTests"
    
    static let collateralLoanLandingGetShowcaseUI = "CollateralLoanLandingGetShowcaseUI"
    static let collateralLoanLandingGetShowcaseUITests = "CollateralLoanLandingGetShowcaseUITests"

    static let collateralLoanLandingGetConsentsBackend = "CollateralLoanLandingGetConsentsBackend"
    static let collateralLoanLandingGetConsentsName = "GetConsents"
    static let collateralLoanLandingGetConsentsBackendTests = "CollateralLoanLandingGetConsentsBackendTests"

    static let collateralLoanLandingCreateDraftCollateralLoanApplicationName = "CreateDraftCollateralLoanApplication"
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationBackend = "CollateralLoanLandingCreateDraftCollateralLoanApplicationBackend"
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationBackendTests = "CollateralLoanLandingCreateDraftCollateralLoanApplicationBackendTests"
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationUI = "CollateralLoanLandingCreateDraftCollateralLoanApplicationUI"
    static let collateralLoanLandingCreateDraftCollateralLoanApplicationUITests = "CollateralLoanLandingCreateDraftCollateralLoanApplicationUITests"
    
    static let collateralLoan = "CollateralLoan"
    static let collateralLoanTests = "CollateralLoanTests"

    static let GetCollateralLanding = "GetCollateralLanding"
    static let collateralLoanLandingGetCollateralLandingBackend = "CollateralLoanLandingGetCollateralLandingBackend"
    static let collateralLoanLandingGetCollateralLandingBackendTests = "CollateralLoanLandingGetCollateralLandingBackendTests"

    static let collateralLoanLandingGetCollateralLandingUI = "CollateralLoanLandingGetCollateralLandingUI"
    static let collateralLoanLandingGetCollateralLandingUITests = "CollateralLoanLandingGetCollateralLandingUITests"

    static let SaveConsents = "SaveConsents"
    static let collateralLoanLandingSaveConsentsBackend = "CollateralLoanLandingSaveConsentsBackend"
    static let collateralLoanLandingSaveConsentsBackendTests = "CollateralLoanLandingSaveConsentsBackendTests"
    
    // MARK: - UI
    
    static let activateSlider = "ActivateSlider"
    static let activateSliderTests = "ActivateSliderTests"
    
    static let accountInfoPanel = "AccountInfoPanel"
    static let accountInfoPanelTests = "AccountInfoPanelTests"
    
    static let calendarUI = "CalendarUI"
    static let calendarUITests = "CalendarUITests"
    
    static let cardUI = "CardUI"
    static let cardUITests = "CardUITests"
    
    static let clientInformList = "ClientInformList"
    static let clientInformListTests = "ClientInformListTests"

    static let productDetailsUI = "ProductDetailsUI"
    static let productDetailsUITests = "ProductDetailsUITests"
    
    static let buttonWithSheet = "ButtonWithSheet"
    
    static let c2bSubscriptionUI = "C2BSubscriptionUI"
    
    static let cardGuardianUI = "CardGuardianUI"
    static let cardGuardianUITests = "CardGuardianUITests"
    
    static let linkableText = "LinkableText"
    static let linkableTextTests = "LinkableTextTests"
    
    static let flowCore = "FlowCore"
    static let flowCoreTests = "FlowCoreTests"
    
    static let manageSubscriptionsUI = "ManageSubscriptionsUI"
    
    static let otpInputComponent = "OTPInputComponent"
    static let otpInputComponentTests = "OTPInputComponentTests"
    
    static let orderCard = "OrderCard"
    
    static let paymentCompletionUI = "PaymentCompletionUI"
    
    static let pickerWithPreviewComponent = "PickerWithPreviewComponent"
    static let pickerWithPreviewComponentTests = "PickerWithPreviewComponentTests"
    
    static let pinCodeUI = "PinCodeUI"
    static let pinCodeUITests = "PinCodeUITests"
    
    static let productUI = "ProductUI"
    
    static let prePaymentPicker = "PrePaymentPicker"
    static let prePaymentPickerTests = "PrePaymentPickerTests"
    
    static let rxViewModel = "RxViewModel"
    static let rxViewModelTests = "RxViewModelTests"
    
    static let savingsAccount = "SavingsAccount"
    static let savingsAccountTests = "SavingsAccountTests"

    static let searchBarComponent = "SearchBarComponent"
    
    static let textFieldUI = "TextFieldUI"
    static let textFieldUITests = "TextFieldUITests"
    
    static let topUpCardUI = "TopUpCardUI"
    static let topUpCardUITests = "TopUpCardUITests"
    
    static let uiKitHelpers = "UIKitHelpers"
    
    static let uiPrimitives = "UIPrimitives"
    static let uiPrimitivesTests = "UIPrimitivesTests"
    
    static let userAccountNavigationComponent = "UserAccountNavigationComponent"
    static let userAccountNavigationComponentTests = "UserAccountNavigationComponentTests"

    // MARK: - UI Components
    
    static let amountComponent = "AmountComponent"
    static let amountComponentTests = "AmountComponentTests"
    
    static let bottomSheetComponent = "BottomSheetComponent"
    
    static let buttonComponent = "ButtonComponent"
    
    static let infoComponent = "InfoComponent"
    
    static let checkBoxComponent = "CheckBoxComponent"

    static let dropDownTextListComponent = "DropDownTextListComponent"
    
    static let footerComponent = "FooterComponent"
    
    static let nameComponent = "NameComponent"
    
    static let openNewProductComponent = "OpenNewProductComponent"
    
    static let optionalSelectorComponent = "OptionalSelectorComponent"
    static let optionalSelectorComponentTests = "OptionalSelectorComponentTests"
    
    static let selectComponent = "SelectComponent"
    static let selectComponentTests = "SelectComponentTests"
    
    static let selectorComponents = "SelectorComponents"
    
    static let selectorComponent = "SelectorComponent"
    static let selectorComponentTests = "SelectorComponentTests"
    
    static let toggleComponent = "ToggleComponent"
    
    static let inputComponent = "InputComponent"
    static let inputComponentTests = "InputComponentTests"
    
    static let inputPhoneComponent = "InputPhoneComponent"
    
    static let paymentComponents = "PaymentComponents"
    
    static let productProfileComponents = "ProductProfileComponents"
    
    static let productSelectComponent = "ProductSelectComponent"
    static let productSelectComponentTests = "ProductSelectComponentTests"
    
    static let sharedConfigs = "SharedConfigs"
    
    static let carouselComponent = "CarouselComponent"
    static let carouselComponentTests = "CarouselComponentTests"
    
    // MARK: - Utilities
    
    static let remoteServices = "RemoteServices"
    static let remoteServicesTests = "RemoteServicesTests"
    
    static let operatorsListComponents = "OperatorsListComponents"
    static let operatorsListComponentsTests = "OperatorsListComponentsTests"
    
    // MARK: - Infra
    
    static let ephemeralStores = "EphemeralStores"
    static let ephemeralStoresTests = "EphemeralStoresTests"
    
    static let fetcher = "Fetcher"
    static let fetcherTests = "FetcherTests"
    
    static let genericLoader = "GenericLoader"
    static let genericLoaderTests = "GenericLoaderTests"
    
    static let keyChainStore = "KeyChainStore"
    static let keyChainStoreTests = "KeyChainStoreTests"
    
    static let serialComponents = "SerialComponents"
    static let serialComponentsTests = "SerialComponentsTests"
    
    // MARK: - Payments
    
    static let anywayPayment = "AnywayPayment"
    static let anywayPaymentAdapters = "AnywayPaymentAdapters"
    static let anywayPaymentAdaptersTests = "AnywayPaymentAdaptersTests"
    static let anywayPaymentBackend = "AnywayPaymentBackend"
    static let anywayPaymentBackendTests = "AnywayPaymentBackendTests"
    static let anywayPaymentCore = "AnywayPaymentCore"
    static let anywayPaymentCoreTests = "AnywayPaymentCoreTests"
    static let anywayPaymentDomain = "AnywayPaymentDomain"
    static let anywayPaymentUI = "AnywayPaymentUI"
    static let anywayPaymentUITests = "AnywayPaymentUITests"
    
    static let latestPaymentsBackendV2 = "LatestPaymentsBackendV2"
    static let latestPaymentsBackendV2Tests = "LatestPaymentsBackendV2Tests"
    
    static let latestPaymentsBackendV3 = "LatestPaymentsBackendV3"
    static let latestPaymentsBackendV3Tests = "LatestPaymentsBackendV3Tests"
    
    static let operatorsListBackendV0 = "OperatorsListBackendV0"
    static let operatorsListBackendV0Tests = "OperatorsListBackendV0Tests"
    
    static let serviceCategoriesBackendV0 = "ServiceCategoriesBackendV0"
    static let serviceCategoriesBackendV0Tests = "ServiceCategoriesBackendV0Tests"
    
    static let paymentTemplateBackendV3 = "PaymentTemplateBackendV3"
    static let paymentTemplateBackendV3Tests = "PaymentTemplateBackendV3Tests"
    
    static let payHub = "PayHub"
    static let payHubTests = "PayHubTests"
    
    static let payHubUI = "PayHubUI"
    static let payHubUITests = "PayHubUITests"
    
    static let utilityPayment = "UtilityPayment"
    static let utilityPaymentTests = "UtilityPaymentTests"
    
    static let utilityServicePrepayment = "UtilityServicePrepayment"
    static let utilityServicePrepaymentCore = "UtilityServicePrepaymentCore"
    static let utilityServicePrepaymentDomain = "UtilityServicePrepaymentDomain"
    static let utilityServicePrepaymentUI = "UtilityServicePrepaymentUI"
    static let utilityServicePrepaymentCoreTests = "UtilityServicePrepaymentCoreTests"
    
    // MARK: - Banners
    
    static let banners = "Banners"
    
    // MARK: - MarketShowcase
    
    static let marketShowcase = "MarketShowcase"
    static let marketShowcaseTests = "MarketShowcaseTests"

    static let modifyC2BSubscriptionService = "ModifyC2BSubscriptionService"

    // MARK: - Services
    
    static let cardStatementAPI = "CardStatementAPI"
    static let cardStatementAPITests = "CardStatementAPITests"
    
    static let svCardLimitAPI = "SVCardLimitAPI"
    static let svCardLimitAPITests = "SVCardLimitAPITests"
    
    static let getBannerCatalogListAPI = "GetBannerCatalogListAPI"
    static let getBannerCatalogListAPITests = "GetBannerCatalogListAPITests"
    
    static let getBannersMyProductListService = "GetBannersMyProductListService"
    static let getBannersMyProductListServiceTests = "GetBannersMyProductListServiceTests"
    
    static let cryptoSwaddler = "CryptoSwaddler"
    static let cryptoSwaddlerTests = "CryptoSwaddlerTests"
    
    static let cvvPin = "CvvPin"
    static let cvvPinTests = "CvvPinTests"
    
    static let cvvPIN_Services = "CVVPIN_Services"
    static let cvvPIN_ServicesTests = "CVVPIN_ServicesTests"
    
    static let cvvPINServices = "CVVPINServices"
    static let cvvPINServicesTests = "CVVPINServicesTests"
    
    static let vortexCrypto = "VortexCrypto"
    static let vortexCryptoTests = "VortexCryptoTests"
    
    static let genericRemoteService = "GenericRemoteService"
    static let genericRemoteServiceTests = "GenericRemoteServiceTests"
    
    static let getProcessingSessionCodeService = "GetProcessingSessionCodeService"
    static let getProcessingSessionCodeServiceTests = "GetProcessingSessionCodeServiceTests"
    
    static let getInfoRepeatPaymentService = "GetInfoRepeatPaymentService"
    static let getInfoRepeatPaymentServiceTests = "GetInfoRepeatPaymentServiceTests"
    
    static let serverAgent = "ServerAgent"
    static let serverAgentTests = "ServerAgentTests"
    
    static let symmetricEncryption = "SymmetricEncryption"
    static let symmetricEncryptionTests = "SymmetricEncryptionTests"
    
    static let transferPublicKey = "TransferPublicKey"
    static let transferPublicKeyTests = "TransferPublicKeyTests"
    
    static let urlRequestFactory = "URLRequestFactory"
    static let urlRequestFactoryTests = "URLRequestFactoryTests"
    
    static let getProductListByTypeService = "GetProductListByTypeService"
    static let getProductListByTypeServiceTests = "GetProductListByTypeServiceTests"
    
    static let getProductListByTypeV6Service = "GetProductListByTypeV6Service"
    static let getProductListByTypeV6ServiceTests = "GetProductListByTypeV6ServiceTests"
    
    static let getProductListByTypeV7Service = "GetProductListByTypeV7Service"
    static let getProductListByTypeV7ServiceTests = "GetProductListByTypeV7ServiceTests"

    static let getClientInformDataServices = "GetClientInformDataServices"
    static let getClientInformDataServicesTests = "GetClientInformDataServicesTests"
    
    static let savingsServices = "SavingsServices"
    static let savingsServicesTests = "SavingsServicesTests"

    
    // MARK: - Tools
    
    static let vortexTools = "VortexTools"
    static let vortexToolsTests = "VortexToolsTests"
}

// MARK: - Third-Party Packages

private extension Package.Dependency {
    
    static let svgKit = Package.Dependency.package(
        url: .svg_kit,
        .upToNextMajor(from: .init(3, 0, 0))
    )
}

private extension Target.Dependency {
    
    static let svgKit = product(
        name: .svgKit,
        package: .svgKit
    )
}

private extension String {
    
    static let svgKit = "SVGKit"
    static let svg_kit = "https://github.com/\(svgKit)/\(svgKit)"
}

// MARK: - Point-Free

private extension Package.Dependency {
    
    static let casePaths = Package.Dependency.package(
        url: .pointFreeGitHub + .case_paths,
        from: .init(0, 10, 1)
    )
    static let combineSchedulers = Package.Dependency.package(
        url: .pointFreeGitHub + .combine_schedulers,
        from: .init(0, 9, 1)
    )
    static let customDump = Package.Dependency.package(
        url: .pointFreeGitHub + .swift_custom_dump,
        from: .init(0, 10, 2)
    )
    static let identifiedCollections = Package.Dependency.package(
        url: .pointFreeGitHub + .swift_identified_collections,
        from: .init(0, 4, 1)
    )
    static let nonEmpty = Package.Dependency.package(
        url: .pointFreeGitHub + .swift_nonempty,
        from: .init(0, 5, 0)
    )
    static let snapshotTesting = Package.Dependency.package(
        url: .pointFreeGitHub + .swift_snapshot_testing,
        from: .init(1, 10, 0)
    )
    static let swiftUINavigation = Package.Dependency.package(
        url: .pointFreeGitHub + .swiftui_navigation,
        from: .init(0, 4, 5)
    )
    static let tagged = Package.Dependency.package(
        url: .pointFreeGitHub + .swift_tagged,
        from: .init(0, 7, 0)
    )
    static let shimmer = Package.Dependency.package(
        url: .swift_shimmer_path,
        exact: .init(1, 5, 0)
    )
    static let phoneNumberKit = Package.Dependency.package(
        url: .phoneNumberKit_path,
        exact: .init(3, 5, 8)
    )
}

private extension Target.Dependency {
    
    static let casePaths = product(
        name: .casePaths,
        package: .case_paths
    )
    static let combineSchedulers = product(
        name: .combineSchedulers,
        package: .combine_schedulers
    )
    static let customDump = product(
        name: .customDump,
        package: .swift_custom_dump
    )
    static let identifiedCollections = product(
        name: .identifiedCollections,
        package: .swift_identified_collections
    )
    static let nonEmpty = product(
        name: .nonEmpty,
        package: .swift_nonempty
    )
    static let snapshotTesting = product(
        name: .snapshotTesting,
        package: .swift_snapshot_testing
    )
    static let swiftUINavigation = product(
        name: .swiftUINavigation,
        package: .swiftui_navigation
    )
    static let tagged = product(
        name: .tagged,
        package: .swift_tagged
    )
    static let shimmer = product(
        name: .shimmer,
        package: .swift_shimmer
    )
    static let phoneNumberKit = product(
        name: .phoneNumberKit,
        package: .phoneNumberKit
    )
}

private extension String {
    
    static let pointFreeGitHub = "https://github.com/pointfreeco/"
    
    static let casePaths = "CasePaths"
    static let case_paths = "swift-case-paths"
    
    static let combineSchedulers = "CombineSchedulers"
    static let combine_schedulers = "combine-schedulers"
    
    static let customDump = "CustomDump"
    static let swift_custom_dump = "swift-custom-dump"
    
    static let identifiedCollections = "IdentifiedCollections"
    static let swift_identified_collections = "swift-identified-collections"
    
    static let nonEmpty = "NonEmpty"
    static let swift_nonempty = "swift-nonempty"
    
    static let snapshotTesting = "SnapshotTesting"
    static let swift_snapshot_testing = "swift-snapshot-testing"
    
    static let swiftUINavigation = "SwiftUINavigation"
    static let swiftui_navigation = "swiftui-navigation"
    
    static let tagged = "Tagged"
    static let swift_tagged = "swift-tagged"
    
    static let shimmer = "Shimmer"
    static let swift_shimmer = "SwiftUI-Shimmer"
    static let swift_shimmer_path = "https://github.com/markiv/SwiftUI-Shimmer"
    
    static let phoneNumberKit = "PhoneNumberKit"
    static let phoneNumberKit_path = "https://github.com/marmelroy/PhoneNumberKit"
}

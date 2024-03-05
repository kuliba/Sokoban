// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-forabank",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
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
        // Infra
        .fetcher,
        .keyChainStore,
        // Payments
        .utilityPayment,
        // Services
        .cardStatementAPI,
        .cryptoSwaddler,
        .cvvPin,
        .cvvPIN_Services,
        .cvvPINServices,
        .foraCrypto,
        .genericRemoteService,
        .getProcessingSessionCodeService,
        .serverAgent,
        .symmetricEncryption,
        .transferPublicKey,
        .urlRequestFactory,
        // UI
        .buttonWithSheet,
        .c2bSubscriptionUI,
        .linkableText,
        .manageSubscriptionsUI,
        .otpInputComponent,
        .pickerWithPreviewComponent,
        .pinCodeUI,
        .prePaymentPicker,
        .productUI,
        .rxViewModel,
        .searchBarComponent,
        .textFieldComponent,
        .uiKitHelpers,
        .uiPrimitives,
        .userAccountNavigationComponent,
        // UI Components
        .paymentComponents,
        .productProfileComponents,
        .carouselComponent,
        // Utilities
        .services,
        // tools
        .foraTools,
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
        // Infra
        .fetcher,
        .fetcherTests,
        .keyChainStore,
        .keyChainStoreTests,
        // Payments
        .utilityPayment,
        .utilityPaymentTests,
        // Services
        .cardStatementAPI,
        .cardStatementAPITests,
        .cryptoSwaddler,
        .cryptoSwaddlerTests,
        .cvvPin,
        .cvvPinTests,
        .cvvPIN_Services,
        .cvvPIN_ServicesTests,
        .cvvPINServices,
        .cvvPINServicesTests,
        .foraCrypto,
        .foraCryptoTests,
        .genericRemoteService,
        .genericRemoteServiceTests,
        .getProcessingSessionCodeService,
        .getProcessingSessionCodeServiceTests,
        .serverAgent,
        .serverAgentTests,
        .symmetricEncryption,
        .symmetricEncryptionTests,
        .transferPublicKey,
        .transferPublicKeyTests,
        .urlRequestFactory,
        .urlRequestFactoryTests,
        // UI
        .activateSlider,
        .activateSliderTests,
        .accountInfoPanel,
        .accountInfoPanelTests,
        .buttonWithSheet,
        .c2bSubscriptionUI,
        .cardGuardianUI,
        .cardGuardianUITests,
        .linkableText,
        .linkableTextTests,
        .manageSubscriptionsUI,
        .otpInputComponent,
        .otpInputComponentTests,
        .operatorsListComponents,
        .operatorsListComponentsTests,
        .pickerWithPreviewComponent,
        .pickerWithPreviewComponentTests,
        .pinCodeUI,
        .pinCodeUITests,
        .prePaymentPicker,
        .prePaymentPickerTests,
        .productUI,
        .rxViewModel,
        .rxViewModelTests,
        .searchBarComponent,
        .textFieldComponent,
        .textFieldComponentTests,
        .textFieldUI,
        .textFieldUITests,
        .topUpCardUI,
        .topUpCardUITests,
        .uiKitHelpers,
        .uiPrimitives,
        .userAccountNavigationComponent,
        .userAccountNavigationComponentTests,
        // UI Components
        .amountComponent,
        .buttonComponent,
        .infoComponent,
        .paymentComponents,
        .productProfileComponents,
        .productSelectComponent,
        .productSelectComponentTests,
        .sharedConfigs,
        .carouselComponent,
        .carouselComponentTests,
        // Utilities
        .services,
        // tools
        .foraTools,
        .foraToolsTests,
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
        ]
    )
    
    // MARK: - UI Components
    
    static let paymentComponents = library(
        name: .paymentComponents,
        targets: [
            .amountComponent,
            .buttonComponent,
            .infoComponent,
            .paymentComponents,
            .productSelectComponent,
            .sharedConfigs,
        ]
    )
    
    static let productProfileComponents = library(
        name: .productProfileComponents,
        targets: [
            .activateSlider,
            .accountInfoPanel,
            .cardGuardianUI,
            .productProfileComponents,
            .topUpCardUI,
        ]
    )

    static let carouselComponent = library(
        name: .carouselComponent,
        targets: [
            .carouselComponent
        ]
    )
    
    // MARK: - Utilities
    
    static let services = library(
        name: .services,
        targets: [
            .services
        ]
    )

    // MARK: - Infra
    
    static let fetcher = library(
        name: .fetcher,
        targets: [
            .fetcher
        ]
    )
    
    static let keyChainStore = library(
        name: .keyChainStore,
        targets: [
            .keyChainStore
        ]
    )
    
    // MARK: - Payments
    
    static let utilityPayment = library(
        name: .utilityPayment,
        targets: [
            .utilityPayment,
        ]
    )

    // MARK: - Services
    
    static let cardStatementAPI = library(
        name: .cardStatementAPI,
        targets: [
            .cardStatementAPI,
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
    
    static let foraCrypto = library(
        name: .foraCrypto,
        targets: [
            .foraCrypto,
        ]
    )
    
    static let getProcessingSessionCodeService = library(
        name: .getProcessingSessionCodeService,
        targets: [
            .getProcessingSessionCodeService,
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
    
    // MARK: - Tools
    
    static let foraTools = library(
        name: .foraTools,
        targets: [
            .foraTools,
        ]
    )
}

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
            .services
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
            .services,
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
            .foraTools,
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
            .combineSchedulers,
            .tagged,
            .shimmer,
        ],
        path: "Sources/Landing/\(String.landingUIComponent)"
    )
    static let landingUIComponentTests = testTarget(
        name: .landingUIComponentTests,
        dependencies: [
            // internal modules
            .landingUIComponent,
        ],
        path: "Tests/Landing/\(String.landingUIComponentTests)"
    )
    
    // MARK: - Infra
    
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
    
    // MARK: - Payments
    
    static let utilityPayment = target(
        name: .utilityPayment,
        dependencies: [
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

    static let cryptoSwaddler = target(
        name: .cryptoSwaddler,
        dependencies: [
            .foraCrypto,
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
            .foraCrypto,
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
            .prePaymentPicker,
            .services
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
    
    static let foraCrypto = target(
        name: .foraCrypto,
        resources: [
            .copy("Resources/public.crt"),
            .copy("Resources/der.crt"),
            .copy("Resources/publicCert.pem"),
            .copy("Resources/generatepin.pem"),
        ]
    )
    
    static let foraCryptoTests = testTarget(
        name: .foraCryptoTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .foraCrypto,
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
        path: "Sources/Services/\(String.transferPublicKey)"
    )
    static let transferPublicKeyTests = testTarget(
        name: .transferPublicKeyTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .transferPublicKey,
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
        ],
        path: "Tests/UI/ProductProfileTests/\(String.accountInfoPanelTests)"
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
    
    static let manageSubscriptionsUI = target(
        name: .manageSubscriptionsUI
    )
    
    static let otpInputComponent = target(
        name: .otpInputComponent,
        dependencies: [
            // external packages
            .combineSchedulers,
            .tagged,
            // internal modules
            .paymentComponents,
            .rxViewModel,
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
            // external packages
            .combineSchedulers,
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
            .foraTools,
            .sharedConfigs,
        ],
        path: "Sources/UI/\(String.uiPrimitives)"
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
            .foraTools,
            .textFieldComponent,
            .sharedConfigs,
        ],
        path: "Sources/UI/Components/\(String.amountComponent)"
    )
    
    static let buttonComponent = target(
        name: .buttonComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.buttonComponent)"
    )
    
    static let infoComponent = target(
        name: .infoComponent,
        dependencies: [
            .sharedConfigs
        ],
        path: "Sources/UI/Components/\(String.infoComponent)"
    )
    
    static let paymentComponents = target(
        name: .paymentComponents,
        dependencies: [
            .amountComponent,
            .buttonComponent,
            .infoComponent,
            .productSelectComponent,
            .sharedConfigs,
        ],
        path: "Sources/UI/Components/\(String.paymentComponents)"
    )
    
    static let productProfileComponents = target(
        name: .productProfileComponents,
        dependencies: [
            .activateSlider,
            .accountInfoPanel,
            .cardGuardianUI,
            .topUpCardUI,
        ],
        path: "Sources/UI/ProductProfile/\(String.productProfileComponents)"
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
            .carouselComponent
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
            .foraTools,
            .paymentComponents,
            .productSelectComponent,
            .prePaymentPicker
        ]
    )
    
    static let operatorsListComponentsTests = testTarget(
        name: .operatorsListComponentsTests,
        dependencies: [
            .customDump,
            .operatorsListComponents
        ],
        path: "Tests/\(String.operatorsListComponentsTests)"
    )
    
    static let productSelectComponent = target(
        name: .productSelectComponent,
        dependencies: [
            .foraTools,
            .sharedConfigs,
            .tagged,
            .uiPrimitives,
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
            .foraTools,
            .tagged,
        ],
        path: "Sources/UI/Components/\(String.sharedConfigs)"
    )
    
    // MARK: - Utilities
    
    static let services = target(
        name: .services,
        dependencies: [
            // external packages
            .tagged,
            // internal modules
        ],
        path: "Sources/Utilities/\(String.services)"
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
            .cvvPin,
            .genericRemoteService,
            .getProcessingSessionCodeService,
            .transferPublicKey,
            .textFieldDomain,
            .textFieldModel,
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
    
    static let foraTools = target(
        name: .foraTools,
        dependencies: [
            .svgKit
        ]
    )
    static let foraToolsTests = testTarget(
        name: .foraToolsTests,
        dependencies: [
            .customDump,
            .foraTools
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
    
    static let buttonWithSheet = byName(
        name: .buttonWithSheet
    )
    
    static let c2bSubscriptionUI = byName(
        name: .c2bSubscriptionUI
    )
    
    static let cardGuardianUI = byName(
        name: .cardGuardianUI
    )
    
    static let linkableText = byName(
        name: .linkableText
    )
    
    static let otpInputComponent = byName(
        name: .otpInputComponent
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
    
    // MARK: - UI Components

    static let amountComponent = byName(
        name: .amountComponent
    )
    
    static let buttonComponent = byName(
        name: .buttonComponent
    )
    
    static let infoComponent = byName(
        name: .infoComponent
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
    
    static let services = byName(
        name: .services
    )

    // MARK: - Infra
    
    static let fetcher = byName(
        name: .fetcher
    )
    
    static let keyChainStore = byName(
        name: .keyChainStore
    )
    
    // MARK: - Payments

    static let utilityPayment = byName(
        name: .utilityPayment
    )

    // MARK: - Services
    
    static let cardStatementAPI = byName(
        name: .cardStatementAPI
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
    
    static let foraCrypto = byName(
        name: .foraCrypto
    )
    
    static let genericRemoteService = byName(
        name: .genericRemoteService
    )
    
    static let getProcessingSessionCodeService = byName(
        name: .getProcessingSessionCodeService
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
    
    // MARK: - Tools
    
    static let foraTools = byName(
        name: .foraTools
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
    
    // MARK: - UI
    
    static let activateSlider = "ActivateSlider"
    static let activateSliderTests = "ActivateSliderTests"

    static let accountInfoPanel = "AccountInfoPanel"
    static let accountInfoPanelTests = "AccountInfoPanelTests"

    static let buttonWithSheet = "ButtonWithSheet"
    
    static let c2bSubscriptionUI = "C2BSubscriptionUI"

    static let cardGuardianUI = "CardGuardianUI"
    static let cardGuardianUITests = "CardGuardianUITests"
    
    static let linkableText = "LinkableText"
    static let linkableTextTests = "LinkableTextTests"
    
    static let manageSubscriptionsUI = "ManageSubscriptionsUI"
    
    static let otpInputComponent = "OTPInputComponent"
    static let otpInputComponentTests = "OTPInputComponentTests"
    
    static let pickerWithPreviewComponent = "PickerWithPreviewComponent"
    static let pickerWithPreviewComponentTests = "PickerWithPreviewComponentTests"
    
    static let pinCodeUI = "PinCodeUI"
    static let pinCodeUITests = "PinCodeUITests"
    
    static let productUI = "ProductUI"
    
    static let prePaymentPicker = "PrePaymentPicker"
    static let prePaymentPickerTests = "PrePaymentPickerTests"
    
    static let rxViewModel = "RxViewModel"
    static let rxViewModelTests = "RxViewModelTests"
    
    static let searchBarComponent = "SearchBarComponent"
    
    static let textFieldUI = "TextFieldUI"
    static let textFieldUITests = "TextFieldUITests"
    
    static let topUpCardUI = "TopUpCardUI"
    static let topUpCardUITests = "TopUpCardUITests"

    static let uiKitHelpers = "UIKitHelpers"
    
    static let uiPrimitives = "UIPrimitives"
    
    static let userAccountNavigationComponent = "UserAccountNavigationComponent"
    static let userAccountNavigationComponentTests = "UserAccountNavigationComponentTests"
    
    // MARK: - UI Components

    static let amountComponent = "AmountComponent"
    
    static let buttonComponent = "ButtonComponent"
    
    static let infoComponent = "InfoComponent"
    
    static let paymentComponents = "PaymentComponents"
    
    static let productProfileComponents = "ProductProfileComponents"

    static let productSelectComponent = "ProductSelectComponent"
    static let productSelectComponentTests = "ProductSelectComponentTests"

    static let sharedConfigs = "SharedConfigs"
    
    static let carouselComponent = "CarouselComponent"
    static let carouselComponentTests = "CarouselComponentTests"
    
    // MARK: - Utilities
    
    static let services = "Services"
    
    static let operatorsListComponents = "OperatorsListComponents"
    static let operatorsListComponentsTests = "OperatorsListComponentsTests"
    
    // MARK: - Infra
    
    static let fetcher = "Fetcher"
    static let fetcherTests = "FetcherTests"
    
    static let keyChainStore = "KeyChainStore"
    static let keyChainStoreTests = "KeyChainStoreTests"
    
    // MARK: - Payments
    
    static let utilityPayment = "UtilityPayment"
    static let utilityPaymentTests = "UtilityPaymentTests"

    // MARK: - Services
    
    static let cardStatementAPI = "CardStatementAPI"
    static let cardStatementAPITests = "CardStatementAPITests"

    static let cryptoSwaddler = "CryptoSwaddler"
    static let cryptoSwaddlerTests = "CryptoSwaddlerTests"
    
    static let cvvPin = "CvvPin"
    static let cvvPinTests = "CvvPinTests"
    
    static let cvvPIN_Services = "CVVPIN_Services"
    static let cvvPIN_ServicesTests = "CVVPIN_ServicesTests"
    
    static let cvvPINServices = "CVVPINServices"
    static let cvvPINServicesTests = "CVVPINServicesTests"
    
    static let foraCrypto = "ForaCrypto"
    static let foraCryptoTests = "ForaCryptoTests"
    
    static let genericRemoteService = "GenericRemoteService"
    static let genericRemoteServiceTests = "GenericRemoteServiceTests"
    
    static let getProcessingSessionCodeService = "GetProcessingSessionCodeService"
    static let getProcessingSessionCodeServiceTests = "GetProcessingSessionCodeServiceTests"
    
    static let serverAgent = "ServerAgent"
    static let serverAgentTests = "ServerAgentTests"
    
    static let symmetricEncryption = "SymmetricEncryption"
    static let symmetricEncryptionTests = "SymmetricEncryptionTests"
    
    static let transferPublicKey = "TransferPublicKey"
    static let transferPublicKeyTests = "TransferPublicKeyTests"
    
    static let urlRequestFactory = "URLRequestFactory"
    static let urlRequestFactoryTests = "URLRequestFactoryTests"

    // MARK: - Tools
    
    static let foraTools = "ForaTools"
    static let foraToolsTests = "ForaToolsTests"
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
        exact: .init(1, 0, 1)
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

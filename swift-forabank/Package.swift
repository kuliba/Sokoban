// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-forabank",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .cryptoSwaddler,
        .cvvPin,
        .foraCrypto,
        .landingComponentsOld,
        .landingEngineOld,
        .loadableResourceComponent,
        .manageSubscriptionsUI,
        .pickerWithPreviewComponent,
        .pinCodeUI,
        .productUI,
        .searchBarComponent,
        .sharedAPIInfra,
        .symmetricEncryption,
        .textFieldComponent,
        .textFieldModel,
        .uiKitHelpers,
        .userModel,
        // services
        .genericRemoteService,
        .getProcessingSessionCodeService,
        // landing
        .landingMapping,
        .landingUICompoment,
        .landingUpdater,
        .transferPublicKey,
        // UI
        .linkableText
    ],
    dependencies: [
        .combineSchedulers,
        .customDump,
        .tagged
    ],
    targets: [
        .cryptoSwaddler,
        .cryptoSwaddlerTests,
        .cvvPin,
        .cvvPinTests,
        .landingComponentsOld,
        .landingEngineOld,
        .foraCrypto,
        .foraCryptoTests,
        .loadableResourceComponent,
        .loadableResourceComponentTests,
        .manageSubscriptionsUI,
        .pickerWithPreviewComponent,
        .pickerWithPreviewComponentTests,
        .pinCodeUI,
        .pinCodeUITests,
        .productUI,
        .searchBarComponent,
        .sharedAPIInfra,
        .sharedAPIInfraTests,
        .symmetricEncryption,
        .symmetricEncryptionTests,
        .textFieldComponent,
        .textFieldComponentTests,
        .textFieldDomain,
        .textFieldDomainTests,
        .textFieldModel,
        .textFieldModelTests,
        .textFieldUI,
        .textFieldUITests,
        .uiKitHelpers,
        .wipTests,
        .userModel,
        .userModelTests,
        // services
        .genericRemoteService,
        .genericRemoteServiceTests,
        .getProcessingSessionCodeService,
        .getProcessingSessionCodeServiceTests,
        // landing
        .landingMapping,
        .landingMappingTests,
        .landingUICompoment,
        .landingUICompomentTests,
        .landingUpdater,
        .transferPublicKey,
        .transferPublicKeyTests,
        // UI
        .linkableText,
        .linkableTextTests,
    ]
)

private extension Product {
    
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
    
    static let landingComponentsOld = library(
        name: .landingComponentsOld,
        targets: [
            .landingComponentsOld,
        ]
    )
    
    static let landingEngineOld = library(
        name: .landingEngineOld,
        targets: [
            .landingEngineOld,
        ]
    )
    
    static let loadableResourceComponent = library(
        name: .loadableResourceComponent,
        targets: [
            .loadableResourceComponent,
        ]
    )
    
    static let manageSubscriptionsUI = library(
        name: .manageSubscriptionsUI,
        targets: [
            .manageSubscriptionsUI,
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
    
    static let productUI = library(
        name: .productUI,
        targets: [
            .productUI,
        ]
    )
    
    static let searchBarComponent = library(
        name: .searchBarComponent,
        targets: [
            .searchBarComponent,
        ]
    )
    
    static let sharedAPIInfra = library(
        name: .sharedAPIInfra,
        targets: [
            .sharedAPIInfra,
        ]
    )
    
    static let symmetricEncryption = library(
        name: .symmetricEncryption,
        targets: [
            .symmetricEncryption,
        ]
    )
    
    static let textFieldComponent = library(
        name: .textFieldComponent,
        targets: [
            .textFieldComponent,
        ]
    )
    
    static let textFieldModel = library(
        name: .textFieldModel,
        targets: [
            .textFieldModel,
        ]
    )
    
    static let transferPublicKey = library(
        name: .transferPublicKey,
        targets: [
            .transferPublicKey,
        ]
    )
    
    static let uiKitHelpers = library(
        name: .uiKitHelpers,
        targets: [
            .uiKitHelpers,
        ]
    )
    
    static let userModel = library(
        name: .userModel,
        targets: [
            .userModel
        ]
    )
    
    // landing
    
    static let landingMapping = library(
        name: .landingMapping,
        targets: [
            .landingMapping
        ]
    )

    static let landingUICompoment = library(
        name: .landingUICompoment,
        targets: [
            .landingUICompoment
        ]
    )

    static let landingUpdater = library(
        name: .landingUpdater,
        targets: [
            .landingUpdater
        ]
    )
    
    // MARK: - UI
    
    static let linkableText = library(
        name: .linkableText,
        targets: [
            .linkableText
        ]
    )
    
}

private extension Target {
    
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
    
    static let foraCrypto = target(
        name: .foraCrypto,
        resources: [
            .copy("Resources/public.crt"),
            .copy("Resources/der.crt"),
            .copy("Resources/publicCert.pem"),
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
    
    static let landingComponentsOld = target(
        name: .landingComponentsOld,
        dependencies: [],
        resources: [.process("Preview")]
    )
    
    static let landingEngineOld = target(
        name: .landingEngineOld,
        dependencies: [
            .landingComponentsOld
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
    
    static let manageSubscriptionsUI = target(
        name: .manageSubscriptionsUI
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
    
    static let productUI = target(
        name: .productUI
    )
    static let searchBarComponent = target(
        name: .searchBarComponent,
        dependencies: [
            .textFieldComponent,
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
    
    static let symmetricEncryption = target(
        name: .symmetricEncryption
    )
    
    static let symmetricEncryptionTests = testTarget(
        name: .symmetricEncryptionTests,
        dependencies: [
            .symmetricEncryption,
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
    
    static let uiKitHelpers = target(name: .uiKitHelpers)
    
    static let wipTests = testTarget(
        name: .wipTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
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
    
    // landing
    
    static let landingMapping = target(
        name: .landingMapping,
        path: "Sources/Landing/\(String.landingMapping)"
    )
    static let landingMappingTests = testTarget(
        name: .landingMappingTests,
        dependencies: [
            // external
            .customDump,
            // internal modules
            .landingMapping,
        ],
        path: "Tests/Landing/\(String.landingMappingTests)"
    )
    static let landingUpdater = target(
        name: .landingUpdater,
        path: "Sources/Landing/\(String.landingUpdater)"
    )
    static let landingUICompoment = target(
        name: .landingUICompoment,
        path: "Sources/Landing/\(String.landingUICompoment)"
    )
    static let landingUICompomentTests = testTarget(
        name: .landingUICompomentTests,
        dependencies: [
            // internal modules
            .landingUICompoment,
        ],
        path: "Tests/Landing/\(String.landingUICompomentTests)"
    )
    
    // MARK: - UI
    
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
}

private extension Target.Dependency {
    
    static let cryptoSwaddler = byName(
        name: .cryptoSwaddler
    )
    
    static let cvvPin = byName(
        name: .cvvPin
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
    
    static let landingComponentsOld = byName(
        name: .landingComponentsOld
    )
    
    static let loadableResourceComponent = byName(
        name: .loadableResourceComponent
    )
    
    static let pickerWithPreviewComponent = byName(
        name: .pickerWithPreviewComponent
    )
    
    static let pinCodeUI = byName(
        name: .pinCodeUI
    )
    
    static let sharedAPIInfra = byName(
        name: .sharedAPIInfra
    )
    
    static let symmetricEncryption = byName(
        name: .symmetricEncryption
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
    
    static let textFieldUI = byName(
        name: .textFieldUI
    )
    
    static let transferPublicKey = byName(
        name: .transferPublicKey
    )
    
    static let uiKitHelpers = byName(
        name: .uiKitHelpers
    )
    
    static let userModel = byName(
        name: .userModel
    )
    
    // landing
    static let landingMapping = byName(
        name: .landingMapping
    )
    static let landingUICompoment = byName(
        name: .landingUICompoment
    )
    static let landingUpdater = byName(
        name: .landingUpdater
    )
    
    // MARK: - UI
    
    static let linkableText = byName(
        name: .linkableText
    )
}

private extension String {
    
    static let cryptoSwaddler = "CryptoSwaddler"
    static let cryptoSwaddlerTests = "CryptoSwaddlerTests"
    
    static let cvvPin = "CvvPin"
    static let cvvPinTests = "CvvPinTests"
    
    static let foraCrypto = "ForaCrypto"
    static let foraCryptoTests = "ForaCryptoTests"
    
    static let genericRemoteService = "GenericRemoteService"
    static let genericRemoteServiceTests = "GenericRemoteServiceTests"
    
    static let getProcessingSessionCodeService = "GetProcessingSessionCodeService"
    static let getProcessingSessionCodeServiceTests = "GetProcessingSessionCodeServiceTests"
    
    static let landingComponentsOld = "LandingComponentsOld"
    static let landingEngineOld = "LandingEngineOld"
    
    static let loadableResourceComponent = "LoadableResourceComponent"
    static let loadableResourceComponentTests = "LoadableResourceComponentTests"
    
    static let manageSubscriptionsUI = "ManageSubscriptionsUI"
    
    static let pickerWithPreviewComponent = "PickerWithPreviewComponent"
    static let pickerWithPreviewComponentTests = "PickerWithPreviewComponentTests"
    
    static let pinCodeUI = "PinCodeUI"
    static let pinCodeUITests = "PinCodeUITests"
    
    static let productUI = "ProductUI"
    
    static let searchBarComponent = "SearchBarComponent"
    
    static let sharedAPIInfra = "SharedAPIInfra"
    static let sharedAPIInfraTests = "SharedAPIInfraTests"
    
    static let symmetricEncryption = "SymmetricEncryption"
    static let symmetricEncryptionTests = "SymmetricEncryptionTests"
    
    static let textFieldComponent = "TextFieldComponent"
    static let textFieldComponentTests = "TextFieldComponentTests"
    
    static let textFieldDomain = "TextFieldDomain"
    static let textFieldDomainTests = "TextFieldDomainTests"
    
    static let textFieldModel = "TextFieldModel"
    static let textFieldModelTests = "TextFieldModelTests"
    
    static let textFieldUI = "TextFieldUI"
    static let textFieldUITests = "TextFieldUITests"
    
    static let transferPublicKey = "TransferPublicKey"
    static let transferPublicKeyTests = "TransferPublicKeyTests"
    
    static let uiKitHelpers = "UIKitHelpers"
    
    static let wipTests = "WIPTests"
    
    static let userModel = "UserModel"
    static let userModelTests = "UserModelTests"
    
    // landing
    static let landingMapping = "LandingMapping"
    static let landingMappingTests = "LandingMappingTests"
    static let landingUICompoment = "LandingUICompoment"
    static let landingUICompomentTests = "LandingUICompomentTests"
    static let landingUpdater = "LandingUpdater"

    // MARK: - UI
    
    static let linkableText = "LinkableText"
    static let linkableTextTests = "LinkableTextTests"
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
}

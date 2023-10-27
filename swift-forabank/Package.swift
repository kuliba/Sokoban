// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-forabank",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .loadableModel,
        .loadableResourceComponent,
        .paymentSticker,
        .phoneNumberWrapper,
        .sharedAPIInfra,
        .textFieldModel,
        .userModel,
        // MARK: - Landing
        .codableLanding,
        .landingMapping,
        .landingUIComponent,
        // MARK: - PaymentsComponents
        .paymentsComponents,
        // MARK: - Services
        .bindPublicKeyWithEventID,
        .cvvPin,
        .genericRemoteService,
        .getProcessingSessionCodeService,
        .serverAgent,
        .symmetricEncryption,
        // MARK: - UI
        .linkableText,
        .manageSubscriptionsUI,
        .pickerWithPreviewComponent,
        .pinCodeUI,
        .productUI,
        .searchBarComponent,
        .textFieldComponent,
        .uiKitHelpers,
    ],
    dependencies: [
        .combineSchedulers,
        .customDump,
        .tagged,
        .shimmer,
        .phoneNumberKit,
    ],
    targets: [
        .loadableModel,
        .loadableModelTests,
        .loadableResourceComponent,
        .loadableResourceComponentTests,
        .paymentSticker,
        .paymentStickerTests,
        .phoneNumberWrapper,
        .phoneNumberWrapperTests,
        .sharedAPIInfra,
        .sharedAPIInfraTests,
        .textFieldDomain,
        .textFieldDomainTests,
        .textFieldModel,
        .textFieldModelTests,
        .userModel,
        .userModelTests,
        // MARK: - Landing
        .codableLanding,
        .landingMapping,
        .landingMappingTests,
        .landingUIComponent,
        .landingUIComponentTests,
        // MARK: - PaymentsComponents
        .paymentsComponents,
        .paymentsComponentsTests,
        // MARK: - Services
        .bindPublicKeyWithEventID,
        .bindPublicKeyWithEventIDTests,
        .cvvPin,
        .cvvPinTests,
        .genericRemoteService,
        .genericRemoteServiceTests,
        .getProcessingSessionCodeService,
        .getProcessingSessionCodeServiceTests,
        .serverAgent,
        .serverAgentTests,
        .symmetricEncryption,
        .symmetricEncryptionTests,
        // MARK: - UI
        .linkableText,
        .linkableTextTests,
        .manageSubscriptionsUI,
        .pickerWithPreviewComponent,
        .pickerWithPreviewComponentTests,
        .pinCodeUI,
        .productUI,
        .searchBarComponent,
        .textFieldComponent,
        .textFieldComponentTests,
        .textFieldUI,
        .textFieldUITests,
        .uiKitHelpers,
        // MARK: - WIP: Explorations
        .wipTests,
    ]
)

private extension Product {
    
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
    
    // MARK: - PaymentsComponents
    static let paymentsComponents = library(
        name: .paymentsComponents,
        targets: [
            .paymentsComponents,
        ]
    )
    
    // MARK: - Services
    
    static let bindPublicKeyWithEventID = library(
        name: .bindPublicKeyWithEventID,
        targets: [
            .bindPublicKeyWithEventID,
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
    
    // MARK: - UI
    
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
    
    static let textFieldComponent = library(
        name: .textFieldComponent,
        targets: [
            .textFieldComponent,
        ]
    )
    
    static let uiKitHelpers = library(
        name: .uiKitHelpers,
        targets: [
            .uiKitHelpers,
        ]
    )
}

private extension Target {
    
        
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
        name: .paymentSticker
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
    
    static let userModel = target(name: .userModel)
    static let userModelTests = testTarget(
        name: .userModelTests,
        dependencies: [
            .userModel
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
            // external
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
    
    //MARK: - PaymentsComponents
    
    static let paymentsComponents = target(
        name: .paymentsComponents,
        dependencies: [
            .textFieldComponent,
        ],
        path: "Sources/\(String.paymentsComponents)"
    )
    
    static let paymentsComponentsTests = testTarget(
        name: .paymentsComponentsTests,
        dependencies: [
            // internal modules
            .paymentsComponents,
        ],
        path: "Tests/\(String.paymentsComponentsTests)"
    )
    
    // MARK: - Services
    
    static let bindPublicKeyWithEventID = target(
        name: .bindPublicKeyWithEventID,
        path: "Sources/Services/\(String.bindPublicKeyWithEventID)"
    )
    static let bindPublicKeyWithEventIDTests = testTarget(
        name: .bindPublicKeyWithEventIDTests,
        dependencies: [
            // external packages
            .customDump,
            // internal modules
            .bindPublicKeyWithEventID,
        ],
        path: "Tests/Services/\(String.bindPublicKeyWithEventIDTests)"
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
        name: .pinCodeUI
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
    
    static let uiKitHelpers = target(name: .uiKitHelpers)
    
    // MARK: - WIP: Explorations
    
    static let wipTests = testTarget(
        name: .wipTests,
        dependencies: [
            // external packages
            .combineSchedulers,
            .customDump,
            // internal modules
            .textFieldDomain,
            .textFieldModel,
        ]
    )
}

private extension Target.Dependency {
    
    static let loadableModel = byName(
        name: .loadableModel
    )
    
    static let loadableResourceComponent = byName(
        name: .loadableResourceComponent
    )
    
    static let paymentSticker = byName(
        name: .paymentSticker
    )

    static let phoneNumberWrapper = byName(
        name: .phoneNumberWrapper
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
    
    // MARK: - PaymentsComponents
    
    static let paymentsComponents = byName(
        name: .paymentsComponents
    )

    static let serverAgent = byName(
        name: .serverAgent
    )
    
    // MARK: - Services
    
    static let bindPublicKeyWithEventID = byName(
        name: .bindPublicKeyWithEventID
    )
    
    static let cvvPin = byName(
        name: .cvvPin
    )
    
    static let genericRemoteService = byName(
        name: .genericRemoteService
    )
    
    static let getProcessingSessionCodeService = byName(
        name: .getProcessingSessionCodeService
    )
    
    static let symmetricEncryption = byName(
        name: .symmetricEncryption
    )
    
    // MARK: - UI
    
    static let linkableText = byName(
        name: .linkableText
    )
    
    static let pickerWithPreviewComponent = byName(
        name: .pickerWithPreviewComponent
    )
    
    static let textFieldUI = byName(
        name: .textFieldUI
    )
    
    static let uiKitHelpers = byName(
        name: .uiKitHelpers
    )
}

private extension String {
    
    static let loadableModel = "LoadableModel"
    static let loadableModelTests = "LoadableModelTests"
    
    static let loadableResourceComponent = "LoadableResourceComponent"
    static let loadableResourceComponentTests = "LoadableResourceComponentTests"
    
    static let paymentSticker = "PaymentSticker"
    static let paymentStickerTests = "PaymentStickerTests"
    
    static let phoneNumberWrapper = "PhoneNumberWrapper"
    static let phoneNumberWrapperTests = "PhoneNumberWrapperTests"
    
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
    
    // MARK: - PaymentsComponents
    static let paymentsComponents = "PaymentsComponents"
    static let paymentsComponentsTests = "PaymentsComponentsTests"

    // MARK: - Services
    
    static let bindPublicKeyWithEventID = "BindPublicKeyWithEventID"
    static let bindPublicKeyWithEventIDTests = "BindPublicKeyWithEventIDTests"
    
    static let cvvPin = "CvvPin"
    static let cvvPinTests = "CvvPinTests"
    
    static let genericRemoteService = "GenericRemoteService"
    static let genericRemoteServiceTests = "GenericRemoteServiceTests"
    
    static let getProcessingSessionCodeService = "GetProcessingSessionCodeService"
    static let getProcessingSessionCodeServiceTests = "GetProcessingSessionCodeServiceTests"

    static let serverAgent = "ServerAgent"
    static let serverAgentTests = "ServerAgentTests"
    
    static let symmetricEncryption = "SymmetricEncryption"
    static let symmetricEncryptionTests = "SymmetricEncryptionTests"
    
    // MARK: - UI
    
    static let linkableText = "LinkableText"
    static let linkableTextTests = "LinkableTextTests"
    
    static let manageSubscriptionsUI = "ManageSubscriptionsUI"
    
    static let pickerWithPreviewComponent = "PickerWithPreviewComponent"
    static let pickerWithPreviewComponentTests = "PickerWithPreviewComponentTests"
    
    static let pinCodeUI = "PinCodeUI"
    
    static let productUI = "ProductUI"
    
    static let searchBarComponent = "SearchBarComponent"
    
    static let textFieldUI = "TextFieldUI"
    static let textFieldUITests = "TextFieldUITests"
    
    static let uiKitHelpers = "UIKitHelpers"
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

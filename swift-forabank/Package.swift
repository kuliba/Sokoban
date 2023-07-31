// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-forabank",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .cvvPin,
        .landingComponents,
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
        .getProcessingSessionCodeService,
    ],
    dependencies: [
        .combineSchedulers,
        .customDump,
    ],
    targets: [
        .cvvPin,
        .cvvPinTests,
        .landingComponents,
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
        .getProcessingSessionCodeService,
        .getProcessingSessionCodeServiceTests,
    ]
)

private extension Product {
    
    static let cvvPin = library(
        name: .cvvPin,
        targets: [
            .cvvPin,
        ]
    )

    static let getProcessingSessionCodeService = library(
        name: .getProcessingSessionCodeService,
        targets: [
            .getProcessingSessionCodeService,
        ]
    )

    static let landingComponents = library(
        name: .landingComponents,
        targets: [
            .landingComponents,
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
}

private extension Target {
    
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

    static let landingComponents = target(
        name: .landingComponents,
        dependencies: []
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
        name: .pinCodeUI
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
    
    static let uiKitHelpers = target(name: .uiKitHelpers)
    
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
    
    static let userModel = target(name: .userModel)
    static let userModelTests = testTarget(
        name: .userModelTests,
        dependencies: [
            .userModel
        ]
    )
}

private extension Target.Dependency {
    
    static let cvvPin = byName(
        name: .cvvPin
    )
    
    static let getProcessingSessionCodeService = byName(
        name: .getProcessingSessionCodeService
    )
    
    static let landingComponents = byName(
        name: .landingComponents
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
    
    static let uiKitHelpers = byName(
        name: .uiKitHelpers
    )
    
    static let userModel = byName(
        name: .userModel
    )
}

private extension String {
    
    static let cvvPin = "CvvPin"
    static let cvvPinTests = "CvvPinTests"
    
    static let getProcessingSessionCodeService = "GetProcessingSessionCodeService"
    static let getProcessingSessionCodeServiceTests = "GetProcessingSessionCodeServiceTests"
    
    static let landingComponents = "LandingComponents"
    
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
    
    static let uiKitHelpers = "UIKitHelpers"
    
    static let wipTests = "WIPTests"
    
    static let userModel = "UserModel"
    static let userModelTests = "UserModelTests"
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

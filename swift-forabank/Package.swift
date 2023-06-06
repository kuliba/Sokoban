// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-forabank",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .searchBarComponent,
        .textFieldComponent,
        .textFieldModel,
        .uiKitHelpers,
    ],
    dependencies: [
        .combineSchedulers,
        .customDump,
    ],
    targets: [
        .searchBarComponent,
        .textFieldComponent,
        .textFieldComponentTests,
        .textFieldDomain,
        .textFieldDomainTests,
        .textFieldModel,
        .textFieldModelTests,
        .textFieldUI,
        .uiKitHelpers,
        .wipTests,
    ]
)

private extension Product {
    
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
}

private extension Target {
    
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
    static let textFieldUITests = target(
        name: .textFieldUITests,
        dependencies: [
            .customDump,
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
}

private extension Target.Dependency {
    
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
}

private extension String {
    
    static let searchBarComponent = "SearchBarComponent"
    
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

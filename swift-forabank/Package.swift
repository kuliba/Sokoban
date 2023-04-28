// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-forabank",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .textFieldRegularComponent,
        .uiKitHelpers,
    ],
    dependencies: [
        .combineSchedulers,
    ],
    targets: [
        .textFieldRegularComponent,
        .textFieldRegularComponentTests,
        .uiKitHelpers,
    ]
)

private extension Product {
    
    static let textFieldRegularComponent = library(
        name: .textFieldRegularComponent,
        targets: [
            .textFieldRegularComponent,
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
    
    static let textFieldRegularComponent = target(
        name: .textFieldRegularComponent,
        dependencies: [
            .combineSchedulers,
            .uiKitHelpers,
        ]
    )
    static let textFieldRegularComponentTests = testTarget(
        name: .textFieldRegularComponentTests,
        dependencies: [
            .combineSchedulers,
            .textFieldRegularComponent,
        ]
    )
    
    static let uiKitHelpers = target(name: .uiKitHelpers)
}

private extension Target.Dependency {
    
    static let textFieldRegularComponent = byName(
        name: .textFieldRegularComponent
    )
    
    static let uiKitHelpers = byName(
        name: .uiKitHelpers
    )
}

private extension String {
    
    static let textFieldRegularComponent = "TextFieldRegularComponent"
    static let textFieldRegularComponentTests = "TextFieldRegularComponentTests"
    
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
    
    static let identifiedCollections = "IdentifiedCollections"
    static let swift_identified_collections = "swift-identified-collections"
    
    static let snapshotTesting = "SnapshotTesting"
    static let swift_snapshot_testing = "swift-snapshot-testing"
    
    static let swiftUINavigation = "SwiftUINavigation"
    static let swiftui_navigation = "swiftui-navigation"
    
    static let tagged = "Tagged"
    static let swift_tagged = "swift-tagged"
}

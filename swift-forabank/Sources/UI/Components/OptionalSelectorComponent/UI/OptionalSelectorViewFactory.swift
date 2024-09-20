//
//  OptionalSelectorViewFactory.swift
//
//
//  Created by Igor Malyarov on 23.05.2024.
//

public struct OptionalSelectorViewFactory<Item, IconView, ItemLabel, SelectedItemLabel, ToggleLabel> {
    
    public let makeIconView: MakeIconView
    public let makeItemLabel: MakeItemLabel
    public let makeSelectedItemLabel: MakeSelectedItemLabel
    public let makeToggleLabel: MakeToggleLabel
    
    public init(
        makeIconView: @escaping MakeIconView,
        makeItemLabel: @escaping MakeItemLabel,
        makeSelectedItemLabel: @escaping MakeSelectedItemLabel,
        makeToggleLabel: @escaping MakeToggleLabel
    ) {
        self.makeIconView = makeIconView
        self.makeItemLabel = makeItemLabel
        self.makeSelectedItemLabel = makeSelectedItemLabel
        self.makeToggleLabel = makeToggleLabel
    }
}

public extension OptionalSelectorViewFactory {
    
    typealias MakeIconView = () -> IconView
    typealias MakeItemLabel = (Item) -> ItemLabel
    typealias MakeSelectedItemLabel = (Item) -> SelectedItemLabel
    typealias MakeToggleLabel = (Bool) -> ToggleLabel
}

//
//  SelectorViewFactory.swift
//  
//
//  Created by Igor Malyarov on 23.05.2024.
//

public struct SelectorViewFactory<Option, OptionView, SelectedOptionView, ToggleLabel> {
    
    public let makeOptionView: MakeOptionView
    public let makeSelectedOptionView: MakeSelectedOptionView
    public let makeToggleLabel: MakeToggleLabel
    
    public init(
        makeOptionView: @escaping MakeOptionView,
        makeSelectedOptionView: @escaping MakeSelectedOptionView,
        makeToggleLabel: @escaping MakeToggleLabel
    ) {
        self.makeOptionView = makeOptionView
        self.makeSelectedOptionView = makeSelectedOptionView
        self.makeToggleLabel = makeToggleLabel
    }
}

public extension SelectorViewFactory {
    
    typealias MakeOptionView = (Option) -> OptionView
    typealias MakeSelectedOptionView = (Option) -> SelectedOptionView
    typealias MakeToggleLabel = (Bool) -> ToggleLabel
}

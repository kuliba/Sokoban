//
//  SelectorViewFactory.swift
//  
//
//  Created by Igor Malyarov on 23.05.2024.
//

public struct SelectorViewFactory<Option, OptionLabel, SelectedOptionLabel, ToggleLabel> {
    
    public let makeOptionLabel: MakeOptionLabel
    public let makeSelectedOptionLabel: MakeSelectedOptionLabel
    public let makeToggleLabel: MakeToggleLabel
    
    public init(
        makeOptionLabel: @escaping MakeOptionLabel,
        makeSelectedOptionLabel: @escaping MakeSelectedOptionLabel,
        makeToggleLabel: @escaping MakeToggleLabel
    ) {
        self.makeOptionLabel = makeOptionLabel
        self.makeSelectedOptionLabel = makeSelectedOptionLabel
        self.makeToggleLabel = makeToggleLabel
    }
}

public extension SelectorViewFactory {
    
    typealias MakeOptionLabel = (Option) -> OptionLabel
    typealias MakeSelectedOptionLabel = (Option) -> SelectedOptionLabel
    typealias MakeToggleLabel = (Bool) -> ToggleLabel
}

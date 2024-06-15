//
//  SelectorViewFactory.swift
//  
//
//  Created by Igor Malyarov on 23.05.2024.
//

public struct SelectorViewFactory<Option, OptionView, SelectedOptionView> {
    
    public let createOptionView: CreateOptionView
    public let createSelectedOptionView: CreateSelectedOptionView
    
    public init(
        createOptionView: @escaping CreateOptionView, 
        createSelectedOptionView: @escaping CreateSelectedOptionView
    ) {
        self.createOptionView = createOptionView
        self.createSelectedOptionView = createSelectedOptionView
    }
}

public extension SelectorViewFactory {
    
    typealias CreateOptionView = (Option) -> OptionView
    typealias CreateSelectedOptionView = (Option) -> SelectedOptionView
}

//
//  SelectorViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

struct SelectorViewFactory<Option, OptionView, SelectedOptionView> {
    
    let createOptionView: CreateOptionView
    let createSelectedOptionView: CreateSelectedOptionView
}

extension SelectorViewFactory {
    
    typealias CreateOptionView = (Option) -> OptionView
    typealias CreateSelectedOptionView = (Option) -> SelectedOptionView
}

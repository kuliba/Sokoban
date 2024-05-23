//
//  SelectorViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

struct SelectorViewFactory<T, OptionView, SelectedOptionView> {
    
    let createOptionView: CreateOptionView
    let createSelectedOptionView: CreateSelectedOptionView
}

extension SelectorViewFactory {
    
    typealias CreateOptionView = (T) -> OptionView
    typealias CreateSelectedOptionView = (T) -> SelectedOptionView
}

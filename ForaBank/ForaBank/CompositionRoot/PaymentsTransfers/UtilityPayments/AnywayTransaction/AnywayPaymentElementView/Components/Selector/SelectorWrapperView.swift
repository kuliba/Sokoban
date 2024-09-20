//
//  SelectorWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RxViewModel
import OptionalSelectorComponent
import SwiftUI
import UIPrimitives

struct SelectorWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let factory: Factory
    private let config: Config
    
    init(
        viewModel: ViewModel,
        factory: Factory,
        config: Config
    ) {
        self.viewModel = viewModel
        self.factory = factory
        self.config = config
    }
    
    var body: some View {
        
        OptionalSelectorView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory,
            config: config
        )
    }
}

extension AnywayElement.UIComponent.Parameter.ParameterType.Option: Identifiable {
    
    public var id: String { key }
}

extension SelectorWrapperView {
    
    typealias ViewModel = ObservingSelectorViewModel
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
    typealias IconView = UIPrimitives.AsyncImage
    typealias Factory = OptionalSelectorViewFactory<Option, IconView, SimpleLabel<Image>, SelectedOptionView, ChevronView>
    typealias Config = OptionalSelectorViewConfig
}

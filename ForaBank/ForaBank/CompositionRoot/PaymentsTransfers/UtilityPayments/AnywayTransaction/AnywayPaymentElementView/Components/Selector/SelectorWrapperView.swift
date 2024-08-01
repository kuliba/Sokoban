//
//  SelectorWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import RxViewModel
import SelectorComponent
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
        
        SelectorView(
            state: viewModel.state.selector,
            event: viewModel.event(_:),
            factory: factory,
            idKeyPath: \.key,
            config: config
        )
    }
}

extension SelectorWrapperView {
    
    typealias ViewModel = ObservingSelectorViewModel
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
    typealias IconView = UIPrimitives.AsyncImage
    typealias Factory = SelectorViewFactory<Option, IconView, SimpleLabel<Image>, SelectedOptionView, ChevronView>
    typealias Config = SelectorViewConfig
}

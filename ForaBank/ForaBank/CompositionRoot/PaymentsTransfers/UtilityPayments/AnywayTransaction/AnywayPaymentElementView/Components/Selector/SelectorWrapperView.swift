//
//  SelectorWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import RxViewModel
import SwiftUI
import Tagged

struct SelectorWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let factory: Factory
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        SelectorView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory,
            idKeyPath: \.key
        )
    }
}

extension SelectorWrapperView {
    
    typealias ViewModel = ObservingSelectorViewModel<Option>
    typealias Factory = SelectorViewFactory<Option, OptionView, SelectedOptionView>
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
}

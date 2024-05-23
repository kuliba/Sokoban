//
//  SelectorWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import RxViewModel
import SwiftUI
import Tagged

typealias ObservingSelectorViewModel<T> = RxObservingViewModel<Selector<T>, SelectorEvent<T>, Never>

struct SelectorWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
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
    typealias Option = AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option
}

// MARK: - Previews

//#Preview {
//    
//    ScrollView {
//        
//        SelectorWrapperView(viewModel: .preview(), factory: .preview)
//    }
//}

extension SelectorViewFactory<String, OptionView, SelectedOptionView> {
    
    static var preview: Self {
        
        return .init(
            createOptionView: { .init(option: .init(key: .init($0), value: .init($0))) },
            createSelectedOptionView: { .init(option: .init(key: .init($0), value: .init($0))) })
    }
}


extension RxObservingViewModel
where State == Selector<String>,
      Event == SelectorEvent<String>,
      Effect == Never {
    
    static func preview(
        initialState: Selector<String> = .preview
    ) -> Self {
        
        .init(
            observable: .preview(initialState: initialState), 
            observe: { _,_ in }
        )
    }
}

extension RxViewModel
where State == Selector<String>,
      Event == SelectorEvent<String>,
      Effect == Never {
    
    static func preview(
        initialState: Selector<String> = .preview
    ) -> Self {
        
        let reducer = SelectorReducer<String>()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
    }
}

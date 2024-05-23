//
//  SelectorWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import RxViewModel
import SwiftUI

typealias ObservingSelectorViewModel<T> = RxObservingViewModel<Selector<T>, SelectorEvent<T>, Never>

struct SelectorWrapperView<T, ID, OptionView, SelectedOptionView>: View
where ID: Hashable,
      OptionView: View,
      SelectedOptionView: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let idKeyPath: KeyPath<T, ID>
    private let factory: Factory
    
    init(
        viewModel: ViewModel,
        idKeyPath: KeyPath<T, ID>,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.idKeyPath = idKeyPath
        self.factory = factory
    }
    
    var body: some View {
        
        SelectorView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory,
            idKeyPath: idKeyPath
        )
    }
}

extension SelectorWrapperView {
    
    typealias ViewModel = ObservingSelectorViewModel<T>
    typealias Factory = SelectorViewFactory<T, OptionView, SelectedOptionView>
}

extension SelectorWrapperView where T: Hashable, T == ID {
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self.init(
            viewModel: viewModel,
            idKeyPath: \.self,
            factory: factory
        )
    }
}

extension SelectorWrapperView where T: Identifiable, T.ID == ID {
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self.init(
            viewModel: viewModel,
            idKeyPath: \.id,
            factory: factory
        )
    }
}

#Preview {
    
    ScrollView {
        
        SelectorWrapperView(viewModel: .preview(), factory: .preview)
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

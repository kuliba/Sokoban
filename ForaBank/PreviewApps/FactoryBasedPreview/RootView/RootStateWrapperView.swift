//
//  RootStateWrapperView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import RxViewModel
import SwiftUI

typealias RootViewModel = RxViewModel<RootState, RootEvent, RootEffect>

struct RootStateWrapperView<Content, Spinner>: View
where Content: View,
      Spinner: View {
    
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
        
        RootView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory
        )
    }
}

extension RootStateWrapperView {
    
    typealias ViewModel = RootViewModel
    typealias Factory = RootViewFactory<Content, Spinner>
}

struct RootStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.off)
            preview(.on)
        }
    }
    
    static func preview(
        _ spinner: SpinnerState,
        _ tab: MainTabState = .chat
    ) -> some View {
        
        RootStateWrapperView(
            viewModel: .preview(initialState: .init(
                spinner: spinner,
                tab: tab
            )),
            factory: makeFactory()
        )
    }
    
    private static func makeFactory(
    ) -> RootViewFactory<Text, SpinnerView> {
        
        .init(
            makeContent: { _,_ in Text("RootView Content") },
            makeSpinner: SpinnerView.init
        )
    }
}

private extension RootViewModel {
    
    static func preview(
        initialState: RootState
    ) -> Self {
        
        .init(
            initialState: initialState,
            reduce: RootReducer().reduce(_:_:),
            handleEffect: { _,_ in }
        )
    }
}

//
//  ProductPickerStateWrapperView.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import CombineSchedulers
import Foundation
import RxViewModel
import SwiftUI

struct ProductPickerStateWrapperView: View {
    
    typealias ViewModel = RxObservingViewModel<State, Event, Effect>
    
    @StateObject private var viewModel: ViewModel
    
    let config: ProductPickerConfig
    
    init(
        selected: Product,
        onProductSelect: @escaping (Product) -> Void,
        config: ProductPickerConfig,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self._viewModel = .init(wrappedValue: .init(
            selected: selected,
            onProductSelect: onProductSelect,
            scheduler: scheduler
        ))
        self.config = config
    }
    
    var body: some View {
        
        ProductPicker(
            state: viewModel.state,
            event: viewModel.event,
            config: config
        )
    }
}
extension ProductPickerStateWrapperView {
    
    typealias State = ProductPickerState
    typealias Event = ProductPickerEvent
    typealias Effect = Never
}

private extension RxObservingViewModel
where State == ProductPickerState,
      Event == ProductPickerEvent,
      Effect == Never {
    
    convenience init(
        selected: Product,
        onProductSelect: @escaping (Product) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        let reducer = ProductPickerReducer()
        self.init(
            observable: .init(
                initialState: .init(selection: selected),
                reduce: reducer.reduce(_:_:),
                handleEffect: { _,_ in },
                scheduler: scheduler),
            observe: { $0.selection.map(onProductSelect) },
            scheduler: scheduler
        )
    }
}

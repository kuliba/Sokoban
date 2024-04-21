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
    
    typealias ViewModel = RxViewModel<State, Event, Effect>
    
    @StateObject private var viewModel: ViewModel
    
    let config: ProductPickerConfig
    
    init(
        selected: Product,
        onProductSelect: @escaping (Product) -> Void,
        config: ProductPickerConfig,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self._viewModel = .init(wrappedValue: .decorated(
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

extension ProductPickerStateWrapperView.ViewModel {
    
    static func decorated(
        selected: Product,
        onProductSelect: @escaping (Product) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> ProductPickerStateWrapperView.ViewModel {
        
        let reducer = ProductPickerReducer()
        let decorated: Reduce = { state, event in
            
            if case let .select(product) = event {
                
                onProductSelect(product)
            }
            
            return reducer.reduce(state, event)
        }
        
        return .init(
            initialState: .init(selection: selected),
            reduce: decorated,
            handleEffect: { _,_ in },
            scheduler: scheduler
        )
    }
}

//
//  MosParkingPicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.06.2023.
//

import Combine
import PickerWithPreviewComponent
import SwiftUI
import TextFieldModel

// MARK: - ViewModel

extension MosParkingPicker {
    
    final class ViewModel: ObservableObject {
        
        typealias State = PickerWithPreviewComponent.ComponentState
        typealias Action = PickerWithPreviewComponent.ComponentAction
        typealias Options = [SubscriptionType: [OptionWithMapImage]]
        typealias RefillID = String
        typealias ID = String
        
        @Published private(set) var state: State
        
        private let options: Options
        private let refillID: RefillID
        private let reducer: SelectingReducer
        private let select: (ID) -> Void
        private let stateSubject = PassthroughSubject<State, Never>()
        
        init(
            initialState state: State,
            options: Options,
            refillID: RefillID,
            select: @escaping (ID) -> Void,
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) {
            self.state = state
            self.options = options
            self.refillID = refillID
            self.reducer = .init(options: options)
            self.select = select
            
            stateSubject
                .removeDuplicates()
                .receive(on: scheduler)
                .assign(to: &$state)
        }
    }
}

extension MosParkingPicker.ViewModel {
    
    func send(_ action: Action) {
        
        let state = reducer.reduce(state, action: action)
        stateSubject.send(state)
    }
    
    func refill() {
        
        select(refillID)
    }
    
    func `continue`() {
        
        select(state.selectionID)
    }
}

extension PickerWithPreviewComponent.ComponentState {
    
    var selectionID: String {
        
        switch self {
        case let .monthly(selectionWithOptions):
            return selectionWithOptions.selection.value
        case let .yearly(selectionWithOptions):
            return selectionWithOptions.selection.value
        }
    }
}

// MARK: - View

struct MosParkingPicker: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        PickerWithPreviewView(
            state: viewModel.state,
            send: viewModel.send,
            paymentAction: viewModel.refill,
            continueAction: viewModel.continue,
            checkUncheckImage: .default,
            viewConfig: .defaulf
        )
        .animation(.default, value: viewModel.state)
        .padding(.bottom)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Previews

struct MosParkingPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MosParkingPicker(
            viewModel: .init(
                initialState: .yearlyOne,
                options: .all,
                refillID: "56",
                select: { _ in }
            )
        )
    }
}

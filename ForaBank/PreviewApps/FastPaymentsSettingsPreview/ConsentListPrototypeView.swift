//
//  ConsentListPrototypeView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ConsentListPrototypeView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(initialState: ConsentListState) {
        
        let reducer = ConsentListReducer(availableBanks: .preview)
        
        let viewModel = ViewModel(
            state: initialState,
            reduce: reducer.reduce
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ConsentListView(
            state: viewModel.state,
            event: viewModel.event(_:)
        )
    }
}

extension ConsentListPrototypeView {
    
    typealias ViewModel = ConsentListViewModel<ConsentListState, ConsentListEvent>
}

struct ConsentListPrototypeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 16) {
                
                consentListPrototypeView(.collapsed(.empty))
                consentListPrototypeView(.collapsed(.preview))
            }
            
            consentListPrototypeView(.expanded)
            consentListPrototypeView(.collapsedError)
            consentListPrototypeView(.expandedError)
        }
    }
    
    private static func consentListPrototypeView(
        _ state: ConsentListState
    ) -> some View {
        
        ConsentListPrototypeView(initialState: state)
    }
}

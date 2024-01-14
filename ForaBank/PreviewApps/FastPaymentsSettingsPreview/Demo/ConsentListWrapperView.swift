//
//  ConsentListWrapperView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ConsentListWrapperView: View {
    
    @ObservedObject var viewModel: ConsentListViewModel
    
    var body: some View {
        
        ScrollView {
            
            ConsentListView(
                state: viewModel.state.uiState,
                event: viewModel.event(_:)
            )
        }
    }
}

extension ConsentListWrapperView {
    
    typealias ConsentListViewModel = ViewModel<ConsentListState, ConsentListEvent>
}

struct ConsentListPrototypeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 16) {
                
                consentListPrototypeView(.collapsedEmpty)
                consentListPrototypeView(.collapsedPreview)
            }
            
            consentListPrototypeView(.expanded(.preview))
            consentListPrototypeView(.failure(.collapsedError))
            consentListPrototypeView(.failure(.expandedError))
        }
    }
    
    private static func consentListPrototypeView(
        _ state: ConsentListState
    ) -> some View {
        
        ConsentListWrapperView(viewModel: .init(
            state: state,
            reduce: { _,_,_ in }
        ))
    }
}

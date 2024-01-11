//
//  FastPaymentsSettingsWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.01.2024.
//

import SwiftUI

struct FastPaymentsSettingsWrapperView: View {
    
    @ObservedObject var viewModel: FastPaymentsSettingsViewModel
    let navigationBarViewModel: NavigationBarView.ViewModel

    var body: some View {
        
        #warning("replace with implementation from module")
        VStack(spacing: 64) {
            
            Text(viewModel.isLoading ? "isLoading" : "not loading")
            
            Text("TBD: FastPaymentsSettingsView with \(String(describing: viewModel))")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBar(with: navigationBarViewModel)
        .loader(isLoading: viewModel.isLoading)
    }
}

private extension FastPaymentsSettingsViewModel {
    
    var isLoading: Bool { state }
}

struct FastPaymentsSettingsWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FastPaymentsSettingsWrapperView(
            viewModel: .init(reduce: { state, event, completion in
                
                completion(state)
            }), 
            navigationBarViewModel: .init(action: {})
        )
    }
}

//
//  FastPaymentsSettingsWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.01.2024.
//

import FastPaymentsSettings
import SwiftUI
import UserAccountNavigationComponent

struct FastPaymentsSettingsWrapperView: View {
    
    @ObservedObject var viewModel: FastPaymentsSettingsViewModel
    
    let config: FastPaymentsSettingsConfig
    
    var body: some View {
         
        FastPaymentsSettingsView(
            settingsResult: viewModel.state.settingsResult,
            event: viewModel.event(_:),
            config: config
        )
    }
}

struct FastPaymentsSettingsWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FastPaymentsSettingsWrapperView(
            viewModel: .init(
                initialState: .init(),
                reduce: { state, _ in (state, nil) },
                handleEffect: { _,_ in }),
            config: .preview
        )
    }
}

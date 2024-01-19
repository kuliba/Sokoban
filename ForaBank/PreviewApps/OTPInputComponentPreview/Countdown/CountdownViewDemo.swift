//
//  CountdownViewDemo.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct CountdownViewDemo: View {
    
    @State private var settings: CountdownDemoSettings = .shortSuccess
    @State private var isShowingSettingsOptions = false
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            OTPInputView(viewModel: .default())
            
            CountdownView(settings: settings)
        }
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing, content: optionsButton)
        .fullScreenCover(isPresented: $isShowingSettingsOptions) {
            
            NavigationView {
                
                CountdownDemoSettingsView(
                    settings: settings,
                    apply: {
                        
                        settings = $0
                        isShowingSettingsOptions = false
                    }
                )
                .navigationTitle("Countdown Options")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func optionsButton() -> some View {
        
        Button("Options") { isShowingSettingsOptions = true }
            .padding(.horizontal)
    }
}

extension OTPInputViewModel {
    
    static func `default`(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
        
        let reducer = OTPInputReducer()
        let effectHandler = OTPInputEffectHandler()
        
        return .init(
            initialState: .init(text: ""),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

struct CountdownViewDemo_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CountdownViewDemo()
    }
}

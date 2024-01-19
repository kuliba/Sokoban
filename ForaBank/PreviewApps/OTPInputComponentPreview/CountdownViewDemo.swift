//
//  CountdownViewDemo.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

struct CountdownViewDemo: View {
    
    @State private var settings: CountdownDemoSettings = .fiveSuccess
    @State private var isShowingSettingsOptions = true
    
    var body: some View {
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct CountdownViewDemo_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CountdownViewDemo()
    }
}

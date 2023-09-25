//
//  ContentView.swift
//  LandingPreview
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import LandingUIComponent
import SwiftUI

struct ContentView: View {
    
    @Environment(\.openURL) var openURL
    
    let landing: UILanding
    let action: (LandingAction) -> Void
    
    var body: some View {
        
        VStack {
            
            GroupBox {
                
                VStack(spacing: 24) {
                    
                    Button("Go to Main") { action(.goToMain) }
                    
                    Button("Wanna Card?") { action(.orderCard(cardTarif: 11, cardType: 77)) }
                }
                .frame(maxWidth: .infinity)
            } label: {
                Text("Not yet a part of landing components, just a demo of wiring actions")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .padding(.horizontal)
            
            LandingView(
                viewModel: .init(),
                landing: landing,
                images: [:],
                action: action,
                openURL: { openURL($0) }
            )
        }
    }
}

/*struct ContentView_Previews: PreviewProvider {
 static var previews: some View {
 
 ContentView()
 }
 }*/

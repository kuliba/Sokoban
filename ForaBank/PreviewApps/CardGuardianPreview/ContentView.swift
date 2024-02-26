//
//  ContentView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule
import ProductProfile
import RxViewModel

typealias ProductProfileViewModel = RxViewModel<ProductProfileNavigation.State, ProductProfileNavigation.Event, ProductProfileNavigation.Effect>

struct ContentView: View {
    
    @StateObject private var viewModel: ProductProfileViewModel = .preview(buttons: .preview)
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                NavigationLink(destination: destination()) {
                    
                    Image(systemName: "person.text.rectangle.fill")
                        .renderingMode(.original)
                        .foregroundColor(Color(.systemMint))
                        .font(.system(size: 120))
                }
                
                CvvButtonView(
                    state: viewModel.state.alert,
                    event: {
                        
                        switch $0 {
                        case let .open(open):
                            viewModel.event(.open(open))
                            
                        case let .productProfile(productProfile):
                            viewModel.event(.productProfile(productProfile))

                        }
                    }
                )
                    .offset(x: 40, y: 30)
                
                CvvCardBlocked(
                    
                )
                    .offset(x: -40, y: 30)
            }
        }
    }
    
    private func destination() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Aктивна, на главном")
                    .lineLimit(2)
                Spacer()
                ControlButtonView.cardUnblokedOnMain
            }
            
            HStack {
                Text("Заблокирована (можно разблокировать)")
                    .lineLimit(2)
                Spacer()
                ControlButtonView.cardBlockedHideOnMain
            }
            
            HStack {
                Text("Заблокирована (нельзя разблокировать)")
                    .lineLimit(2)
                Spacer()
                ControlButtonView.cardBlockedUnlockNotAvailable
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

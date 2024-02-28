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
    
    @StateObject private var viewModel: ProductProfileViewModel = .preview(
        buttons: .preview,
        activateResult: .success(()))
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                VStack {
                    
                    CardSliderView()
                    .alert(
                        item: .init(
                            get: { viewModel.state.alert },
                            // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                            set: { _ in }
                        ),
                        content: { .init(with: $0, event: viewModel.event) }
                    )
                }
                .background(.gray)
                
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
                            case .showAlert:
                                viewModel.event(.showAlert(.alertCVV()))
                                
                            case .closeAlert:
                                viewModel.event(.closeAlert)
                            }
                        }
                    )
                    .offset(x: 40, y: 30)
                    
                    CvvCardBlockedView(
                        state: viewModel.state.alert,
                        event: {
                            
                            switch $0 {
                            case .showAlert:
                                viewModel.event(.showAlert(.alertCardBlocked()))
                                
                            case .closeAlert:
                                viewModel.event(.closeAlert)
                            }
                        }
                    )
                    .offset(x: -40, y: 30)
                }
            }
        }
    }
    
    private func destination() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Aктивна, на главном")
                    .lineLimit(2)
                Spacer()
                ControlButtonView.init(
                    state: viewModel.state,
                    event: viewModel.event
                )
            }
            
            HStack {
                Text("Заблокирована (можно разблокировать)")
                    .lineLimit(2)
                Spacer()
                ControlButtonView.init(
                    state: viewModel.state,
                    event: viewModel.event
                )
            }
            
            HStack {
                Text("Заблокирована (нельзя разблокировать)")
                    .lineLimit(2)
                Spacer()
                ControlButtonView.init(
                    state: viewModel.state,
                    event: viewModel.event
                )
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

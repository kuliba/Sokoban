//
//  OpenSavingsAccountBinderView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives
import SavingsAccount

struct OpenSavingsAccountBinderView: View {
        
    let binder: SavingsAccountDomain.OpenAccountBinder
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(model: binder.content) { contentState, contentEvent in
            
            RxWrapperView(model: binder.flow) { flowState, flowEvent in
                
                SavingsAccountDomain.FlowView(
                    state: flowState,
                    event: flowEvent,
                    contentView: {
                        
                        RefreshableScrollView(
                            action: { contentEvent(.load) },
                            showsIndicators: false,
                            coordinateSpaceName: "openSavingsAccountScroll"
                        ) {
                            SavingsAccountDomain.OpenAccountContentView(
                                state: contentState,
                                event: contentEvent,
                                config: config,
                                factory: factory
                            )
                        }
                    }
                )
                .onFirstAppear {
                    contentEvent(.load)
                }
                .navigationDestination(
                    destination: flowState.navigation?.destination,
                    content: makeDestinationView
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
            }
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeDestinationView(
        destination: SavingsAccountDomain.Navigation.Destination
    ) -> some View {
        
        EmptyView() // TODO: add success view
    }
        
    @inlinable
    @ViewBuilder
    func makeOpenSavingsAccountView(
        destination: SavingsAccountDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case .openSavingsAccount:
            Text("openSavingsAccount")
        }
    }
}

extension OpenSavingsAccountBinderView {
    
    typealias Config = SavingsAccountContentConfig
    typealias Factory = SavingsAccountDomain.OpenAccountLandingViewFactory
}

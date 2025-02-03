//
//  OpenSavingsAccountBinderView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives

struct OpenSavingsAccountBinderView: View {
        
    private let binder: SavingsAccountDomain.OpenAccountBinder
    private let config: Config
    private let factory: Factory
    
    init(
        binder: SavingsAccountDomain.OpenAccountBinder,
        config: Config,
        factory: Factory
    ) {
        self.binder = binder
        self.config = config
        self.factory = factory
    }
    
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
                                config: .prod,
                                factory: factory
                            )
                        }
                    },
                    informerView: informerView
                )
                .padding(.bottom)
                .navigationBarWithBack(
                    title: "Оформление накопительного счета",
                    subtitle: nil,
                    dismiss: { flowEvent(.dismiss) }
                )
                .navigationDestination(
                    destination: flowState.navigation?.destination,
                    content: makeDestinationView
                )
               /* .safeAreaInset(edge: .bottom, spacing: 8) {
                    if contentState.status.needContinueButton {
                        continueButton({ flowEvent(.select(.openSavingsAccount)) })
                    }
                }*/
            }
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeDestinationView(
        destination: SavingsAccountDomain.Navigation.Destination
    ) -> some View {
        
        EmptyView()
    }

    
    private func informerView(
        _ informerData: InformerData
    ) -> InformerView {
        
        .init(
            viewModel: .init(
                message: informerData.message,
                icon: informerData.icon.image,
                color: informerData.color)
        )
    }
    
    private func continueButton(
        _ action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action, label: {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: config.continueButton.cornerRadius)
                    .foregroundColor(config.continueButton.background)
                config.continueButton.label.text(withConfig: config.continueButton.title)
            }
        })
        .padding(.horizontal)
        .frame(height: config.continueButton.height)
        .frame(maxWidth: .infinity)
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
    
    typealias Config = SavingsAccountDomain.Config
    typealias Factory = SavingsAccountDomain.OpenAccountViewFactory
}

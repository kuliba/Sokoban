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
                                config: config,
                                factory: factory
                            )
                        }
                    },
                    informerView: informerView
                )
                .padding(.bottom)
                .onFirstAppear {
                    contentEvent(.load)
                }
                .navigationBarWithBack(
                    title: "Оформление накопительного счета",
                    subtitle: nil,
                    dismiss: { flowEvent(.dismiss) }
                )
                .navigationDestination(
                    destination: flowState.navigation?.destination,
                    content: makeDestinationView
                )
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
        
    private func backButton(
        _ back: @escaping () -> Void
    ) -> some View {
        Button(action: back) { Image.ic24ChevronLeft }
    }
    
    private func header() -> some View {
        "Оформление накопительного счета".text(withConfig: .init(textFont: .textH3M18240(), textColor: .textSecondary), alignment: .center)
    }

}

extension OpenSavingsAccountBinderView {
    
    typealias Config = SavingsAccountContentConfig
    typealias Factory = SavingsAccountDomain.OpenAccountLandingViewFactory
}

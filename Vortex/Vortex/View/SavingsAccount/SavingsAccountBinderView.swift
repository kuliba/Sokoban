//
//  SavingsAccountBinderView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 31.01.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives

struct SavingsAccountBinderView: View {
        
    private let binder: SavingsAccountDomain.Binder
    private let openAccountBinder: SavingsAccountDomain.OpenAccountBinder

    private let config: Config
    private let factory: Factory
    private let openAccountFactory: OpenAccountFactory

    init(
        binders: MakeSavingsAccountBinders,
        config: Config,
        factory: Factory,
        openAccountFactory: OpenAccountFactory
    ) {
        self.binder = binders.makeSavingsAccountBinder()
        self.openAccountBinder = binders.makeOpenSavingsAccountBinder()
        self.config = config
        self.factory = factory
        self.openAccountFactory = openAccountFactory
    }
    
    var body: some View {
        
        RxWrapperView(model: binder.content) { contentState, contentEvent in
            
            RxWrapperView(model: binder.flow) { flowState, flowEvent in
                
                SavingsAccountDomain.FlowView(
                    state: flowState,
                    event: flowEvent,
                    contentView: {
                        
                        OffsetObservingScrollView(
                            axes: .vertical,
                            showsIndicators: false,
                            offset: .init(
                                get: { .zero },
                                set: { contentEvent(.offset($0.y)) }),
                            coordinateSpaceName: "savingsAccountScroll"
                        ) {
                            SavingsAccountDomain.ContentView(
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
                    title: contentState.navTitle.title,
                    subtitle: contentState.navTitle.subtitle,
                    dismiss: { flowEvent(.dismiss) }
                )
                .navigationDestination(
                    destination: flowState.navigation?.destination,
                    content: makeOpenSavingsAccountView
                )
                .safeAreaInset(edge: .bottom, spacing: 8) {
                    if contentState.status.needContinueButton {
                        continueButton({ flowEvent(.select(.openSavingsAccount)) })
                    }
                }
            }
        }
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
            OpenSavingsAccountBinderView(binder: openAccountBinder, config: .prod, factory: openAccountFactory)
        }
    }
}

extension SavingsAccountBinderView {
    
    typealias Config = SavingsAccountDomain.Config
    typealias Factory = SavingsAccountDomain.ViewFactory
    typealias OpenAccountFactory = SavingsAccountDomain.OpenAccountLandingViewFactory

}

extension SavingsAccountDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case .failure:
            return nil
            
        case .main:
            return nil
            
        case .openSavingsAccount:
            return .openSavingsAccount
        }
    }
    
    enum Destination {
        
        case openSavingsAccount
    }
}

extension SavingsAccountDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .openSavingsAccount:
            return .openSavingsAccount
        }
    }
    
    enum ID: Hashable {
        
        case openSavingsAccount
    }
}

//
//  SavingsAccountBinderView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 31.01.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives

struct SavingsAccountBinderView<OpenSavingsAccountView>: View
where OpenSavingsAccountView: View
{
        
    let binder: SavingsAccountDomain.Binder
    let openAccountBinder: OpenSavingsAccountDomain.Binder
    
    let config: Config

    let factory: Factory
    let makeOpenBinder: (OpenSavingsAccountDomain.Binder) -> OpenSavingsAccountView
    
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
                            .onFirstAppear { contentEvent(.load) }
                            .onAppear { flowEvent(.dismiss) }
                        }
                    },
                    informerView: informerView
                )
                .padding(.bottom)
                .navigationBarWithBack(
                    title: contentState.navTitle.title,
                    subtitle: contentState.navTitle.subtitle,
                    subtitleForegroundColor: .textPlaceholder,
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
            
            makeOpenBinder(openAccountBinder)
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
            
        case .loaded:
            return nil
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

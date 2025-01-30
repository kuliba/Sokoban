//
//  SavingsAccountFullView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 31.01.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives

struct SavingsAccountFullView: View {
        
    private let binder: SavingsAccountDomain.Binder
    private let config: Config
    private let factory: Factory
    
    init(
        binder: SavingsAccountDomain.Binder,
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
                .padding(.bottom)
                /* navTitle: .init(
                     title: .init(text: "Накопительный счет", config: .init(textFont: .textH3M18240(), textColor: .textSecondary)),
                     subtitle: .init(text: "Накопительный в рублях", config: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder))),
                 */

                .navigationBarWithBack(
                    title: contentState.navTitle.title,
                    subtitle: contentState.navTitle.subtitle,
                    dismiss: { flowEvent(.dismiss) }
                )
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    continueButton({ contentEvent(.openSavingsAccount) })
                }
                
//                        .navigationDestination(
//                            destination: flowState.,
//                            content: <#T##(Destination) -> Content#>)
            }
        }
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
}

extension SavingsAccountFullView {
    
    typealias Config = SavingsAccountDomain.Config
    typealias Factory = SavingsAccountDomain.ViewFactory
}

//
//  ViewComponents+makeSavingsAccountView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.02.2025.
//

import Foundation
import SavingsAccount
import SavingsServices
import RxViewModel
import SwiftUI
import OTPInputComponent
import UIPrimitives

extension ViewComponents {
        
    func makeSavingsAccountBinderView(
        binder: SavingsAccountDomain.Binder,
        openAccountBinder: OpenSavingsAccountDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
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
                                factory: makeFactory()
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
                    dismiss: dismiss
                )
                .navigationDestination(
                    destination: flowState.navigation?.destination,
                    content: { makeOpenSavingsAccountView(destination: $0, openAccountBinder: openAccountBinder) }
                )
                .safeAreaInset(edge: .bottom, spacing: 8) {
                    if contentState.status.needContinueButton {
                        continueButton({ flowEvent(.select(.openSavingsAccount)) }, .iVortex)
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
        _ action: @escaping () -> Void,
        _ config: SavingsAccountDomain.Config
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
        destination: SavingsAccountDomain.Navigation.Destination,
        openAccountBinder: OpenSavingsAccountDomain.Binder
    ) -> some View {
        
        switch destination {
        case .openSavingsAccount:
            
            makeOpenSavingsAccountView(openAccountBinder, dismiss: {})
        }
    }

    
    func makeFactory(
    ) -> SavingsAccountDomain.ViewFactory {
        .init(
            refreshView: makeSpinnerRefreshView(),
            makeLandingView: {
                SavingsAccountView(
                    state: .init($0?.list.first),
                    config: .iVortex,
                    factory: makeImageViewFactory()
                )
            }
        )
    }
    
    func makeImageViewFactory() -> ImageViewFactory {
        
        .init(makeIconView: makeIconView, makeBannerImageView: makeGeneralIconView(md5Hash:))
    }
       
    func makeSpinnerRefreshView(
    ) -> SpinnerRefreshView {
            .init(icon: .init("Logo Fora Bank"))
    }
                        
    func makeAmountToString(
        _ amount: Decimal,
        _ currencyCode: String
    ) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""
        
        return (formatter.string(for: amount) ?? "") + " " + currencyCode
    }
    
    func makeAmountInfoView(
    ) -> AmountInfoView {
        .init()
    }
}

private extension OTPInputState {
    
    var warning: String? {
        
        guard case let .input(input) = status,
              case let .failure(.serverError(warning)) = input.otpField.status
        else { return nil }
        
        return warning
    }
}

extension OrderSavingsAccount {
    
    init?(_ data: SavingsAccountDomain.OpenAccountLandingItem?) {
        
        guard let data else { return nil }
        
        self.init(currency: .init(code: data.currency.code, symbol: data.currency.symbol), designMd5hash: data.design, fee: .init(open: data.fee.open, subscription: .init(period: "period", value: 1000)), header: .init(title: data.title, subtitle: ""), hint: data.hint, income: data.income, links: .init(conditions: data.conditionsLink, tariff: data.tariffLink))
    }
    
}

extension SavingsAccountDomain.OpenAccountLandingItem {
    
    static let empty: Self = .init(conditionsLink: "", currency: .init(code: 0, symbol: ""), description: "", design: "", fee: .init(open: 0, maintenance: .init(period: "", value: 0)), hint: "", productId: 0, income: "", tariffLink: "", title: "")
}

extension SavingsAccountDomain.LandingItem {
    
    static let empty: Self = .init(
        theme: "",
        name: "",
        marketing: nil,
        advantages: nil,
        basicConditions: nil,
        questions: nil
    )
}

extension SavingsAccountState {
    
    init?(_ data: SavingsAccountDomain.LandingItem?) {
        
        guard let data else { return nil }
        
        let titles = SavingsAccountDomain.Titles.iVortex
        self.init(
            advantages: .init(
                title: titles.advantages,
                list: data.advantages?.advantages ?? []),
            basicConditions: .init(
                title: titles.conditions,
                list: data.basicConditions?.basicConditions ?? []),
            imageLink: data.marketing?.imageLink ?? "",
            questions: .init(title: titles.questions, questions: data.questions?.questions ?? []),
            subtitle: data.marketing?.labelTag,
            title: data.name)
    }
}

private extension SavingsAccountState.Items.Item {
    
    init(_ data: SavingsAccountDomain.LandingItem.Advantage) {
        self.init(md5hash: data.iconMd5hash, title: data.title, subtitle: data.subtitle)
    }
}

private extension SavingsAccountState.Items.Item {
    
    init(_ data: SavingsAccountDomain.LandingItem.BasicCondition) {
        self.init(md5hash: data.iconMd5hash, title: data.title, subtitle: nil)
    }
}

private extension SavingsAccountState.Question {
    
    init(_ data: SavingsAccountDomain.LandingItem.Question) {
        self.init(answer: data.answer, question: data.question)
    }
}

private extension Array where Element == SavingsAccountDomain.LandingItem.Advantage {
    
    var advantages: [SavingsAccountState.Items.Item]? {
        map { .init($0) }
    }
}

private extension Array where Element == SavingsAccountDomain.LandingItem.BasicCondition {
    
    var basicConditions: [SavingsAccountState.Items.Item]? {
        map { .init($0) }
    }
}

private extension Array where Element == SavingsAccountDomain.LandingItem.Question {
    
    var questions: [SavingsAccountState.Question]? {
        map { .init($0) }
    }
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

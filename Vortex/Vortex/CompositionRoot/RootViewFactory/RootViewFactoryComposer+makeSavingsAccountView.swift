//
//  RootViewFactoryComposer+makeSavingsAccountView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 15.01.2025.
//

import Foundation
import SavingsAccount
import SavingsServices
import RxViewModel
import SwiftUI
import OTPInputComponent

extension RootViewFactoryComposer {
    
    func makeSavingsAccountBinderView(
        binders: MakeSavingsAccountBinders
    ) -> SavingsAccountBinderView? {
        
        return .init(
            binders: binders,
            config: .iVortex,
            factory: makeFactory(),
            openAccountFactory: makeOpenSavingsAccountLandingViewFactory()
        )
    }
    
    func makeFactory(
    ) -> SavingsAccountDomain.ViewFactory {
        .init(
            makeRefreshView: makeSpinnerRefreshView(),
            makeLandingView: {
                SavingsAccountView(
                    state: .init($0.list.first ?? .empty),
                    config: .iVortex,
                    factory: self.makeImageViewFactory()
                )
            }
        )
    }
       
    func makeSpinnerRefreshView(
    ) -> () -> SpinnerRefreshView {
        {
            .init(icon: .init("Logo Fora Bank"))
        }
    }
        
    func makeOpenSavingsAccountView(
        _ data: SavingsAccountDomain.OpenAccountLanding
    ) -> OrderSavingsAccountWrapperView {
        
        let reducer = OrderSavingsAccountReducer(openURL: { url in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        return OrderSavingsAccountWrapperView(
            viewModel: .init(
                initialState: .init(status: .result(.init(data.list.first ?? .empty))),
                reduce: reducer.reduce(_:_:),
                handleEffect: {_,_ in } // TODO: add handler
            ),
            amountToString: makeAmountToString,
            config: .prod,
            imageFactory: makeImageViewFactory(),
            viewFactory: makeOpenSavingsAccountViewFactory()
        )
    }
    
    func makeOpenSavingsAccountLandingViewFactory() -> SavingsAccountDomain.OpenAccountLandingViewFactory {
        
        .init(
            makeRefreshView: makeSpinnerRefreshView(),
            makeLandingView: makeOpenSavingsAccountView
        )
    }
    
    func makeOpenSavingsAccountViewFactory() -> SavingsAccountDomain.OpenAccountViewFactory {
        
        .init(
            makeAmountInfoView: makeAmountInfoView(),
            makeOTPView: { [makeOTPView] in
                
                let model = TimedOTPInputViewModel(
                    otpText: "",
                    initiateOTP: { _ in },
                    submitOTP: { _,_ in }
                   // observe: {  }
                )

                return makeOTPView(model)
            },
            makeProductPickerView:  { Text("productPicker") })
    }
    
    private func makeOTPView(
       _ viewModel: TimedOTPInputViewModel
    ) -> SavingsAccountDomain.OTPView {
        
        return .init(
            viewModel: viewModel,
            config: .iVortex,
            iconView: OTPInfoView.init,
            warningView: {
                
                OTPWarningView(text: viewModel.state.warning, config: .iVortex)
            }
        )
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
    ) -> () -> AmountInfoView {
        { .init() }
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
    
    init(_ data: SavingsAccountDomain.OpenAccountLandingItem) {
        
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
    
    init(_ data: SavingsAccountDomain.LandingItem) {
        
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

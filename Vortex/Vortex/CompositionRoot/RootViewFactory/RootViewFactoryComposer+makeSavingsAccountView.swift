//
//  RootViewFactoryComposer+makeSavingsAccountView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 15.01.2025.
//

import Foundation
import SavingsAccount
import SavingsServices

extension RootViewFactoryComposer {
    
    func makeSavingsAccountView(
        binder: SavingsAccountDomain.Binder,
        model: Model,
        isActive: Bool
    ) -> SavingsAccountDomain.WrapperView? {
        
        if isActive {
            return .init(
                model: binder.flow,
                makeContentView: { [makeFlowView] in makeFlowView(binder, $0, $1) })
        } else {
            return nil
        }
    }
    
    func makeFlowView(
        _ binder: SavingsAccountDomain.Binder,
        _ flowState: SavingsAccountDomain.FlowState,
        _ flowEvent: @escaping (SavingsAccountDomain.FlowEvent) -> Void
    ) -> SavingsAccountDomain.FlowView<SavingsAccountDomain.ContentWrapperView, InformerView> {
        
        .init(
            state: flowState,
            event: flowEvent,
            contentView: { [makeContentWrapperView] in makeContentWrapperView(binder) },
            informerView: makeInformerView
        )
    }
    
    func makeContentWrapperView(
        _ binder: SavingsAccountDomain.Binder
    ) -> SavingsAccountDomain.ContentWrapperView {
        .init(
            model: binder.content,
            makeContentView: makeContentView(_:_:)
        )
    }
    
    func makeContentView(
        _ state: SavingsAccountDomain.ContentState,
        _ event: @escaping (SavingsAccountDomain.ContentEvent) -> Void
    ) -> SavingsAccountDomain.ContentView {
        .init(
            state: state,
            event: event,
            config: .prod,
            factory: makeFactory()
        )
    }
    
    func makeFactory(
    ) -> SavingsAccountDomain.ViewFactory {
        .init(
            makeRefreshView: { SpinnerRefreshView(icon: .init("Logo Fora Bank")) },
            makeLandingView: makeLandingView
        )
    }
    
    func makeLandingView(
        _ viewModel: SavingsAccountDomain.Landing
    ) -> SavingsAccountWrapperView {
        .init(
            viewModel: .init(
                initialState: .init(viewModel.list.first ?? .empty),
                reduce: { state,_ in (state, .none)} , // TODO: - add reduce
                handleEffect: {_,_ in } // TODO: - add handleEffect
            ),
            config: .iVortex,
            imageViewFactory: makeImageViewFactory()
        )
    }
    
    func makeInformerView(
        _ payload: SavingsAccountDomain.InformerPayload
    ) -> InformerView {
        .init(viewModel: .init(message: payload.message, icon: payload.icon.image, color: payload.color))
    }
}

private extension SavingsAccountDomain.LandingItem {
    
    static let empty: Self = .init(
        theme: "",
        name: "",
        marketing: nil,
        advantages: nil,
        basicConditions: nil,
        questions: nil
    )
}

private extension SavingsAccountState {
    
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

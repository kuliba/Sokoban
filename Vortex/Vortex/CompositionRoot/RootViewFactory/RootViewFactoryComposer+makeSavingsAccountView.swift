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

extension RootViewFactoryComposer {
    
    func makeSavingsAccountView(
        binder: SavingsAccountDomain.Binder,
        dismiss: @escaping SavingsAccountDismiss,
        model: Model,
        isActive: Bool
    ) -> SavingsAccountDomain.WrapperView? {
        
        guard isActive else { return nil }
        
        return RxWrapperView(model: binder.flow) {
            
            self.makeFlowView(
                { self.makeContentWrapperView(binder.content, dismiss) },
                $0,
                $1,
                dismiss
            )
        }
    }
    
    func makeFlowView(
        _ contentView: @escaping () -> SavingsAccountDomain.ContentWrapperView,
        _ flowState: SavingsAccountDomain.FlowState,
        _ flowEvent: @escaping (SavingsAccountDomain.FlowEvent) -> Void,
        _ dismiss: @escaping SavingsAccountDismiss
    ) -> SavingsAccountDomain.FlowView<SavingsAccountDomain.ContentWrapperView, InformerView> {
        
        .init(
            state: flowState,
            event: flowEvent,
            contentView: contentView,
            informerView: makeInformerView
        )
    }
    
    func makeContentWrapperView(
        _ content: SavingsAccountDomain.Content,
        _ dismiss: @escaping SavingsAccountDismiss
    ) -> SavingsAccountDomain.ContentWrapperView {
        
        RxWrapperView(model: content) {
            
            SavingsAccountDomain.ContentView(
                state: $0,
                event: $1,
                config: .prod,
                factory: self.makeFactory(dismiss)
            )
        }
    }
        
    func makeFactory(
        _ dismiss: @escaping SavingsAccountDismiss
    ) -> SavingsAccountDomain.ViewFactory {
        .init(
            makeRefreshView: { SpinnerRefreshView(icon: .init("Logo Fora Bank")) },
            makeLandingView: { [makeLandingView] in makeLandingView($0, dismiss) }
        )
    }
    
    func makeLandingView(
        _ viewModel: SavingsAccountDomain.Landing,
        _ dismiss: @escaping SavingsAccountDismiss
    ) -> SavingsAccountWrapperView {
        .init(
            viewModel: .init(
                initialState: .init(viewModel.list.first ?? .empty),
                reduce: { state, event in
                    
                    switch event {
                    case .dismiss:
                        dismiss()
                        
                    case .continue:
                        break
                    }
                    return (state, .none)
                } , // TODO: - add reduce
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

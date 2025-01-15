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
                makeContentView: { flowState, flowEvent in
                    SavingsAccountDomain.FlowView(
                        state: flowState,
                        event: flowEvent,
                        contentView: {
                            SavingsAccountDomain.ContentWrapperView(
                                model: binder.content,
                                makeContentView: { contentState, contentEvent in
                                    SavingsAccountDomain.ContentView(
                                        state: contentState,
                                        event: contentEvent,
                                        config: .prod,
                                        factory: .init(
                                            makeRefreshView: { SpinnerRefreshView(icon: .init("Logo Fora Bank")) },
                                            makeLandingView: { viewModel in
                                                    .init(
                                                        viewModel: .init(
                                                            initialState: .init(viewModel.list.first ?? .empty),
                                                            reduce: { state,_ in (state, .none)} , // TODO: - add reduce
                                                            handleEffect: {_,_ in } // TODO: - add handleEffect
                                                        ),
                                                        config: .iVortex,
                                                        imageViewFactory: .init(
                                                            makeIconView: model.imageCache().makeIconView(for:),
                                                            makeBannerImageView: model.generalImageCache().makeIconView(for:))
                                                    )
                                            }
                                        ))
                                })
                        },
                        informerView: {
                            InformerView(viewModel: .init(message: $0.message, icon: $0.icon.image, color: $0.color))
                        })
                })
        } else {
            return nil
        }
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

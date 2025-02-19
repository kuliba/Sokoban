//
//  BindersFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 16.01.2025.
//

import Foundation
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

typealias MakeCollateralLoanShowcaseBinder = () -> GetShowcaseDomain.Binder
typealias MakeCollateralLoanLandingBinder = (String) -> GetCollateralLandingDomain.Binder
typealias MakeSavingsAccountBinder = () -> SavingsAccountDomain.Binder
typealias MakeCreateDraftCollateralLoanApplicationBinder = (CreateDraftCollateralLoanApplication)
    -> CreateDraftCollateralLoanApplicationDomain.Binder
typealias MakeSavingsAccountNodes = (@escaping () -> Void) -> SavingsAccountNodes

struct SavingsAccountNodes {
    
    let openSavingsAccountNode: Node<SavingsAccountDomain.OpenAccountBinder>
    let savingsAccountNode: Node<SavingsAccountDomain.Binder>
}

extension SavingsAccountNodes {
    
    static let preview: Self = .init(
        openSavingsAccountNode: { fatalError() }(),
        savingsAccountNode: { fatalError() }()
    )
}
struct BindersFactory {
    
    let bannersBinder: BannersBinder
    let makeCollateralLoanShowcaseBinder: MakeCollateralLoanShowcaseBinder
    let makeCollateralLoanLandingBinder: MakeCollateralLoanLandingBinder
    let makeCreateDraftCollateralLoanApplicationBinder: MakeCreateDraftCollateralLoanApplicationBinder
    let makeSavingsAccountNodes: MakeSavingsAccountNodes
}

extension BindersFactory {
    
    static let preview: Self = .init(
        bannersBinder: .preview,
        makeCollateralLoanShowcaseBinder: { .preview },
        makeCollateralLoanLandingBinder: { _ in .preview },
        makeCreateDraftCollateralLoanApplicationBinder: { _ in .preview },
        makeSavingsAccountNodes: { _ in .preview }
    )
}

// MARK: - GetCollateralLandingDomain.Binder preview

private extension GetCollateralLandingDomain.Binder {
    
    static let preview = GetCollateralLandingDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension GetCollateralLandingDomain.Content {
    
    static let preview = GetCollateralLandingDomain.Content(
        initialState: .init(landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

private extension GetCollateralLandingDomain.Flow {
    
    static let preview = GetCollateralLandingDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

// MARK: - CreateDraftCollateralLoanApplicationDomain.Binder preview

private extension CreateDraftCollateralLoanApplicationDomain.Binder {
    
    static var preview: CreateDraftCollateralLoanApplicationDomain.Binder {
     
        .init(
            content: .contentPreview,
            flow: .flowPreview,
            bind: { _,_ in [] }
        )
    }
}

private extension CreateDraftCollateralLoanApplicationDomain.Content {
    
    static var contentPreview: CreateDraftCollateralLoanApplicationDomain.Content {
     
        .init(
            initialState: .init(
                application: .preview,
                stage: .correctParameters
            ),
            reduce: { state,_ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}

private extension CreateDraftCollateralLoanApplicationDomain.Flow {
    
    static var flowPreview: CreateDraftCollateralLoanApplicationDomain.Flow {
        
        .init(
            initialState: .init(),
            reduce: { state,_ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}

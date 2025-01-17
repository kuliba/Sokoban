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
typealias MakeCreateDraftCollateralLoanApplicationBinder = (String) -> CreateDraftCollateralLoanApplicationDomain.Binder
typealias MakeSavingsAccountBinder = () -> SavingsAccountDomain.Binder

struct BindersFactory {
    
    let bannersBinder: BannersBinder
    let makeCollateralLoanShowcaseBinder: MakeCollateralLoanShowcaseBinder
    let makeCollateralLoanLandingBinder: MakeCollateralLoanLandingBinder
    let makeCreateDraftCollateralLoanApplicationBinder: MakeCreateDraftCollateralLoanApplicationBinder
    let makeSavingsAccountBinder: MakeSavingsAccountBinder
}

extension BindersFactory {
    
    static let preview: Self = .init(
        bannersBinder: .preview,
        makeCollateralLoanShowcaseBinder: { .preview },
        makeCollateralLoanLandingBinder: { _ in .preview },
        makeCreateDraftCollateralLoanApplicationBinder: { _ in .preview },
        makeSavingsAccountBinder: { fatalError() }
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

// MARK: - GetShowcaseDomain.Binder preview

private extension GetShowcaseDomain.Binder {
    
    static let preview = GetShowcaseDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension GetShowcaseDomain.Flow {
    
    static let preview = GetShowcaseDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

private extension GetShowcaseDomain.Content {
    
    static let preview: GetShowcaseDomain.Content = .init(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

// MARK: - CreateDraftCollateralLoanApplicationDomain.Binder preview

private extension CreateDraftCollateralLoanApplicationDomain.Binder {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension CreateDraftCollateralLoanApplicationDomain.Content {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Content(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

private extension CreateDraftCollateralLoanApplicationDomain.Flow {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

//
//  GetCollateralLandingDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.01.2025.
//

import RxViewModel
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

extension GetCollateralLandingDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State<InformerPayload>, Event<InformerPayload>, Effect>
    typealias ContentError = CollateralLoanLandingGetCollateralLandingUI.BackendFailure<InformerPayload>
    typealias Domain = GetCollateralLandingDomain
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    typealias InformerPayload = InformerData
    
    enum Select: Equatable {
        
        case createDraft(Payload)
        case showCaseList(State<InformerPayload>.BottomSheet.SheetType)
        case failure(Failure)
    }
    
    enum Navigation {

        case createDraft(DraftDomain.Binder)
        case showBottomSheet(State<InformerPayload>.BottomSheet.SheetType)
        case failure(Failure)
    }

    enum Failure: Equatable {
        
        case alert(String)
        case informer(InformerData)
        case none
    }

    typealias DraftDomain = CreateDraftCollateralLoanApplicationDomain
}

extension GetCollateralLandingDomain.State {
    
    public func payload(_ product: GetCollateralLandingProduct) -> CreateDraftCollateralLoanApplication {
        
        return .init(
            amount: desiredAmount,
            cities: product.cities,
            consents: product.consents.map { .init(name: $0.name, link: $0.link) },
            icons: .init(
                productName: product.icons.productName,
                amount: product.icons.amount,
                term: product.icons.term,
                rate: product.icons.rate,
                city: product.icons.city
            ),
            maxAmount: product.calc.amount.maxIntValue,
            minAmount: product.calc.amount.minIntValue,
            name: product.name,
            percent: selectedPercentDouble,
            periods: product.calc.rates.map { .init(title: $0.termStringValue, months: $0.termMonth) },
            selectedMonths: selectedMonthPeriod,
            payrollClient: payrollClient,
            collateralType: selectedCollateralType
        )
    }
}

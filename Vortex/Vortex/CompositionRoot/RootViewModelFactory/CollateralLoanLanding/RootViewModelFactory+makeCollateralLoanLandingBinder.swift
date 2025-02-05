//
//  RootViewModelFactory+makeCollateralLoanLandingBinder.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.01.2025.
//

import CollateralLoanLandingGetCollateralLandingUI
import RemoteServices
import Foundation
import Combine

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingBinder(landingID: String) -> GetCollateralLandingDomain.Binder {
        
        let content = makeContent(landingID: landingID)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
    }

    // MARK: - Content
    
    private func makeContent(landingID: String) -> GetCollateralLandingDomain.Content {
        
        let reducer = GetCollateralLandingDomain.Reducer()
        let effectHandler = GetCollateralLandingDomain.EffectHandler(
            landingID: landingID,
            load: loadCollateralLoanLanding
        )
                    
        return .init(
            initialState: .init(landingID: landingID),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    private func loadCollateralLoanLanding(
        landingId: String,
        completion: @escaping(GetCollateralLandingDomain.Result) -> Void
    ) {
        let load = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetCollateralLandingRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateGetCollateralLandingResponse(_:_:)
        )
            
        load((nil, landingId)) { [load] in
            
            completion(.init(result: $0))
            _ = load
        }
    }
    
    // MARK: - Flow
    
    private func getNavigation(
        select: GetCollateralLandingDomain.Select,
        notify: @escaping GetCollateralLandingDomain.Notify,
        completion: @escaping (GetCollateralLandingDomain.Navigation) -> Void
    ) {
        switch select {
        case let .createDraftCollateralLoanApplication(payload):
            let binder = makeCreateDraftCollateralLoanApplicationBinder(payload: payload)
            completion(.createDraftCollateralLoanApplication(binder))

        case let .showCaseList(id):
            completion(.showBottomSheet(id))
        }
    }

    private func delayProvider(
        navigation: GetCollateralLandingDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .createDraftCollateralLoanApplication:
            return .milliseconds(100)
        case .showBottomSheet:
            return .milliseconds(100)
        }
    }
}

private extension GetCollateralLandingDomain.Result {
    
    init(result: Result<RemoteServices.ResponseMapper.GetCollateralLandingResponse, Error>) {
        
        self = result.map(\.product).mapError { _ in .init() }
    }
}

private extension RemoteServices.ResponseMapper.GetCollateralLandingResponse {
    
    var product: GetCollateralLandingProduct {
        
        return .init(
            theme: _theme,
            name: _name,
            marketing: _marketing,
            conditions: _conditions,
            calc: _calc,
            faq: _faq,
            documents: _documents,
            consents: _consents,
            cities: _cities,
            icons: _icons
        )
    }
    
    var _theme: GetCollateralLandingProduct.Theme {

        switch theme {
        case .gray:
            return .gray
        case .white:
            return .white
        case .unknown:
            return .unknown
        }
    }
    
    var _name: String {
        
        name
    }
    
    var _marketing: GetCollateralLandingProduct.Marketing {
        
        .init(
            labelTag: marketing.labelTag,
            image: marketing.image,
            params: marketing.params
        )
    }
    
    var _conditions: [GetCollateralLandingProduct.Condition] {
        
        conditions.map {
            .init(
                icon: $0.icon,
                title: $0.title,
                subTitle: $0.subTitle
            )
        }
    }
    
    var _calc: GetCollateralLandingProduct.Calc {
        
        .init(
            amount: .init(
                minIntValue: calc.amount.minIntValue,
                maxIntValue: calc.amount.maxIntValue,
                maxStringValue: calc.amount.maxStringValue
            ),
            collaterals: calc.collateral.map {
                .init(
                    icon: $0.icon,
                    name: $0.name,
                    type: $0.type
                )
            },
            rates: calc.rates.map {
                .init(
                    rateBase: $0.rateBase,
                    ratePayrollClient: $0.ratePayrollClient,
                    termMonth: $0.termMonth,
                    termStringValue: $0.termStringValue
                )
            }
        )
    }
    
    var _faq: [GetCollateralLandingProduct.Faq] {
        
        frequentlyAskedQuestions.map {
            .init(
                question: $0.question,
                answer: $0.answer
            )
        }
    }
    
    var _documents: [GetCollateralLandingProduct.Document] {
        
        documents.map {
            .init(
                title: $0.title,
                icon: $0.icon,
                link: $0.link
            )
        }
    }
    
    var _consents: [GetCollateralLandingProduct.Consent] {
        
        consents.map {
            .init(
                name: $0.name,
                link: $0.link
            )
        }
    }
    
    var _cities: [String] {
        
        cities
    }
    
    var _icons: GetCollateralLandingProduct.Icons {
        
        .init(
            productName: icons.productName,
            amount: icons.amount,
            term: icons.term,
            rate: icons.rate,
            city: icons.city
        )
    }
}

extension String {
    
    func addingPercentEncoding() -> Self {
        addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

//
//  RootViewModelFactory+makeGetCollateralLandingViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.01.2025.
//

import CollateralLoanLandingGetCollateralLandingUI
import RemoteServices
import Foundation
import Combine

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingBinder(landingId: String) -> GetCollateralLandingDomain.Binder {
        
        let content = makeContent(landingId: landingId)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses()
        )
    }

    // MARK: - Content
    
    private func makeContent(landingId: String) -> GetCollateralLandingDomain.Content {
        
        let reducer = GetCollateralLandingDomain.Reducer()
        let effectHandler = GetCollateralLandingDomain.EffectHandler(
            landingId: landingId,
            load: loadCollateralLoanLanding
        )
                    
        return .init(
            initialState: .init(),
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
            // TODO: replace productID to binder in the future
            completion(.createDraftCollateralLoanApplication(payload))
        }
    }

    private func delayProvider(
        navigation: GetCollateralLandingDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .createDraftCollateralLoanApplication:
            return .milliseconds(100)
        }
    }

    // Управление производится через Flow напрямую
    private func witnesses() -> ContentWitnesses<
        GetCollateralLandingDomain.Content,
        FlowEvent<Domain.Select, Never>
    > {
        .init(
            emitting: { _ in Empty() },
            dismissing: { _ in {} }
        )
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
}

//private extension RemoteServices.ResponseMapper.GetCollateralLandingResponse {
//    
//    var product: GetCollateralLandingProduct {
//        
//        .init(
//            theme: product.theme.getCollateralLandingProductTheme,
//            name: product.name,
//            marketing: GetCollateralLandingProduct.Marketing.init(
//                labelTag: product.marketing.labelTag,
//                image: product.marketing.image,
//                params: product.marketing.params
//            ),
//            conditions: product.conditions.map { $0.getCollateralLandingProductCondition },
//            calc: product.calc.getCollateralLandingProductCalc,
//            faq: product.frequentlyAskedQuestions.map { $0.getCollateralLandingProductFaq },
//            documents: product.documents.map { $0.getCollateralLandingProductDocument },
//            consents: product.consents.map { $0.getCollateralLandingProductConsent },
//            cities: product.cities,
//            icons: product.icons.getCollateralLandingProductConsent
//        )
//    }
//}

private extension GetCollateralLandingProduct.Theme {
    
    var getCollateralLandingProductTheme: RemoteServices.ResponseMapper.CollateralLandingProduct.Theme {
        
        switch self {
        case .gray:
            return .gray
        case .white:
            return .white
        case .unknown:
            return .unknown
        }
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Condition {
    
    var getCollateralLandingProductCondition: GetCollateralLandingProduct.Condition {
        
        .init(
            icon: icon,
            title: title,
            subTitle: subTitle
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Calc {
    
    var getCollateralLandingProductCalc: GetCollateralLandingProduct.Calc {
        
        .init(
            amount: amount.getCollateralLandingProductCalcAmount,
            collaterals: collateral.map { $0.getCollateralLandingProductCalcCollateral },
            rates: rates.map { $0.getCollateralLandingProductCalcRate }
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Calc.Amount {
    
    var getCollateralLandingProductCalcAmount: GetCollateralLandingProduct.Calc.Amount {
        
        .init(
            minIntValue: minIntValue,
            maxIntValue: maxIntValue,
            maxStringValue: maxStringValue
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Calc.Collateral {
    
    var getCollateralLandingProductCalcCollateral: GetCollateralLandingProduct.Calc.Collateral {
        
        .init(
            icon: icon,
            name: name,
            type: type
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Calc.Rate {
    
    var getCollateralLandingProductCalcRate: GetCollateralLandingProduct.Calc.Rate {
        
        .init(
            rateBase: rateBase,
            ratePayrollClient: ratePayrollClient,
            termMonth: termMonth,
            termStringValue: termStringValue
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.FrequentlyAskedQuestion {
    
    var getCollateralLandingProductFaq: GetCollateralLandingProduct.Faq {
        
        .init(
            question: question,
            answer: answer
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Document {
    
    var getCollateralLandingProductDocument: GetCollateralLandingProduct.Document {
        
        .init(
            title: title,
            icon: icon,
            link: link
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Consent {
    
    var getCollateralLandingProductConsent: GetCollateralLandingProduct.Consent {
        
        .init(
            name: name,
            link: link
        )
    }
}

private extension RemoteServices.ResponseMapper.CollateralLandingProduct.Icons {
    
    var getCollateralLandingProductConsent: GetCollateralLandingProduct.Icons {
        
        .init(
            productName: productName,
            amount: amount,
            term: term,
            rate: rate,
            city: city
        )
    }
}

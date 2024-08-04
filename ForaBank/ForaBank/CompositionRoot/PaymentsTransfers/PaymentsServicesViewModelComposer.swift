//
//  PaymentsServicesViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import Foundation

final class PaymentsServicesViewModelComposer {
    
    private let model: Model
    
    init(model: Model) {
        self.model = model
    }
}

extension PaymentsServicesViewModelComposer {
    
    func compose(
        payload: Payload
    ) -> PaymentsServicesViewModel {
        
        let operators = model.operators(for: payload.type) ?? []
        
        let navigationBarViewModel = NavigationBarView.ViewModel.allRegions(
            titleButtonAction: { [weak model] in
                
                model?.action.send(PaymentsServicesViewModelWithNavBarAction.OpenCityView())
            },
            navLeadingAction: payload.navLeadingAction,
            navTrailingAction: payload.navTrailingAction
        )
        
        let lastPaymentsKind: LatestPaymentData.Kind = .init(rawValue: payload.type.rawValue) ?? .unknown
        let latestPayments = PaymentsServicesLatestPaymentsSectionViewModel(model: model, including: [lastPaymentsKind])
        
        return .init(
            searchBar: .withText("Наименование или ИНН"),
            navigationBar: navigationBarViewModel,
            model: model,
            latestPayments: latestPayments,
            allOperators: operators,
            addCompanyAction: payload.addCompany,
            requisitesAction: payload.requisites
        )
    }
    
    typealias Payload = PrepaymentEffect.LegacyPaymentPayload
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService>
}

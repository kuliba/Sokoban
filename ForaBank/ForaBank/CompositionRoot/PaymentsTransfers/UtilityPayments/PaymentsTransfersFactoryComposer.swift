//
//  PaymentsTransfersFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import SwiftUI

final class PaymentsTransfersFactoryComposer {
    
    private let model: Model
    
    init(model: Model) {
        
        self.model = model
    }
}

extension PaymentsTransfersFactoryComposer {
    
    func makeUtilitiesViewModel(
        log: @escaping (String, StaticString, UInt) -> Void,
        isActive: Bool
    ) -> MakeUtilitiesViewModel {
        
        return { [self] payload, completion in
            
            switch payload.type {
            case .internet:
                makeLegacyUtilitiesViewModel(payload, model)
                    .map(PaymentsTransfersFactory.UtilitiesVM.legacy)
                    .map(completion)
                
            case .service:
                if isActive {
                    completion(.utilities)
                } else {
                    makeLegacyUtilitiesViewModel(payload, model)
                        .map(PaymentsTransfersFactory.UtilitiesVM.legacy)
                        .map(completion)
                }
                
            default:
                return
            }
        }
    }
}

extension PaymentsTransfersFactoryComposer {
    
    typealias MakeUtilitiesViewModel = PaymentsTransfersFactory.MakeUtilitiesViewModel
}

private extension PaymentsTransfersFactoryComposer {
    
    func makeLegacyUtilitiesViewModel(
        _ payload: PaymentsTransfersFactory.MakeUtilitiesPayload,
        _ model: Model
    ) -> PaymentsServicesViewModel? {
        
        guard let operators = model.operators(for: payload.type)
        else { return nil }
        
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
}

private extension Model {
    
    func operators(
        for type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) -> [OperatorGroupData.OperatorData]? {
        
        guard let dictionaryAnywayOperators = dictionaryAnywayOperators(),
              let operatorValue = Payments.operatorByPaymentsType(type)
        else { return nil }
        #warning("suboptimal sort + missing sort condition")
        // TODO: fix sorting: remove excessive iterations
        // TODO: fix sorting according to https://shorturl.at/ehxIQ
        return  dictionaryAnywayOperators
            .filter { $0.parentCode == operatorValue.rawValue }
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })
    }
}

private extension NavigationBarView.ViewModel {
    
    static func allRegions(
        titleButtonAction: @escaping () -> Void,
        navLeadingAction: @escaping () -> Void,
        navTrailingAction: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        .init(
            title: PaymentsServicesViewModel.allRegion,
            titleButton: .init(
                icon: .ic24ChevronDown,
                action: titleButtonAction
            ),
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(
                    icon: .ic24ChevronLeft,
                    action: navLeadingAction
                )
            ],
            rightItems: [
                NavigationBarView.ViewModel.ButtonItemViewModel(
                    icon: Image("qr_Icon"),
                    action: navTrailingAction
                )
            ]
        )
    }
}

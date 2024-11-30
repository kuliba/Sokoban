//
//  AuthLoginViewModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.11.2023.
//

import Foundation
import Combine

extension AuthLoginViewModel {
    
    convenience init(
        _ model: Model,
        buttons: [ButtonAuthView.ViewModel] = [],
        rootActions: RootViewModel.RootActions,
        onRegister: @escaping () -> Void
    ) {
        self.init(
            clientInformAlertsManager: model.clientInformAlertManager,
            eventPublishers: model.eventPublishers,
            eventHandlers: .init(
                onRegisterCardNumber: model.register(cardNumber:),
                catalogProduct: model.catalogProduct,
                showSpinner: rootActions.spinner.show,
                hideSpinner: rootActions.spinner.hide
            ),
            factory: model.authLoginViewModelFactory(
                rootActions: rootActions
            ),
            onRegister: onRegister
        )
    }
}

private extension Model {

    var clientInformAlertsManager: AuthLoginViewModel.ClientInformAlertsManager {
        
        .init(clientInformAlertsManager: clientInformAlertManager)
    }
    
    var eventPublishers: AuthLoginViewModel.EventPublishers {
        
        .init(
            checkClientResponse: action
                .compactMap { $0 as? ModelAction.Auth.CheckClient.Response }
                .eraseToAnyPublisher(),
            
            catalogProducts: catalogProducts
                .eraseToAnyPublisher(),
            
            sessionStateFcmToken: sessionState
                .combineLatest(fcmToken)
                .eraseToAnyPublisher()
        )
    }
    
    func register(cardNumber: String) -> Void {
        
        LoggerAgent.shared.log(category: .ui, message: "send ModelAction.Auth.CheckClient.Request number: ...\(cardNumber.suffix(4))")
        
        action.send(ModelAction.Auth.CheckClient.Request(number: cardNumber))
    }
    
    func catalogProduct(
        for request: AuthLoginViewModel.EventHandlers.Request
    ) -> CatalogProductData? {
        
        switch request {
        case let .id(id):
            return catalogProducts.value.first {
                $0.id == id
            }
            
        case let .tarif(tarif, type: type):
            return catalogProducts.value.first {
                $0.tariff == tarif &&
                $0.productType == type
            }
        }
    }
}

//
//  MicroServices.Facade+stub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Foundation

extension MicroServices.Facade {
    
    static func stub(
        _ getProducts: @escaping GetProducts,
        _ getBanks: @escaping GetBanks
    ) -> Self {
        
        .init(
            createFastContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.success(()))
                }
            },
            getBankDefaultResponse: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.init(bankDefault: .onDisabled))
                }
            },
            getClientConsent: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.preview)
                }
            },
            getFastContract: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.success(.stub))
                }
            },
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.success(()))
                }
            }
        )
    }
}

private extension UserPaymentSettings.PaymentContract {
    
    static let stub: Self = .init(
        id: 10002076204,
        accountID: 10004203497,
        contractStatus: .active,
        phoneNumber: "79171044913",
        phoneNumberMasked: "+7 ... ... 49 13"
    )
}

//
//  UserAccountViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

extension UserAccountViewModel {
    
    static func preview(
        route: Route = .init(),
        getUserPaymentSettings: @escaping FastPaymentsSettingsReducer.GetUserPaymentSettings = { $0(.active()) },
        updateContract: @escaping FastPaymentsSettingsReducer.UpdateContract = { _, completion in completion(.success(.active)) },
        getProduct: @escaping FastPaymentsSettingsReducer.GetProduct = { .init(id: UUID().uuidString) },
        createContract: @escaping FastPaymentsSettingsReducer.CreateContract = { _, completion in completion(.success(.active)) },
        prepareSetBankDefault: @escaping FastPaymentsSettingsReducer.PrepareSetBankDefault = { $0(.success) }
    ) -> UserAccountViewModel {
        
        let reducer = FastPaymentsSettingsReducer(
            
            getUserPaymentSettings: getUserPaymentSettings,
            updateContract: updateContract,
            getProduct: getProduct,
            createContract: createContract,
            prepareSetBankDefault: prepareSetBankDefault
        )
        
        return .init(
            route: route,
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    
                    .init(reducer: reducer)
                }
            )
        )
    }
}

private extension FastPaymentsSettingsViewModel {
    
    convenience init(reducer: FastPaymentsSettingsReducer) {
        
        self.init(reduce: reducer.reduce(_:_:_:))
    }
}

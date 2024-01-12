//
//  UserAccountViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension UserAccountViewModel {
    
    static func preview(
        route: Route = .init(),
        getContractConsentAndDefault: @escaping FastPaymentsSettingsReducer.GetContractConsentAndDefault = { $0(.active()) }
    ) -> UserAccountViewModel {
        
        let reducer = FastPaymentsSettingsReducer(
            
            getContractConsentAndDefault: getContractConsentAndDefault
        )
        
        return .init(
            route: route,
            factory: .init(
                makeFastPaymentsSettingsViewModel: { .init(reducer: reducer) }
            )
        )
    }
}

private extension FastPaymentsSettingsViewModel {
    
    convenience init(reducer: FastPaymentsSettingsReducer) {
        
        self.init(reduce: reducer.reduce(_:_:_:))
    }
}

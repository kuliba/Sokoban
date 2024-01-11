//
//  ViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension ViewModel {
    
    static func preview(
        route: Route = .init(),
        getContractConsentAndDefaultStub: ContractConsentAndDefault = .active()
    ) -> ViewModel {
        
        let reducer = FastPaymentsSettingsReducer(
            
            getContractConsentAndDefault: { $0(getContractConsentAndDefaultStub) }
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

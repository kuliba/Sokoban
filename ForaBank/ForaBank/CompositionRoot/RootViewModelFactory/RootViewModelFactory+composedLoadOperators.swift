//
//  RootViewModelFactory+composedLoadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

extension RootViewModelFactory {
    
    func composedLoadOperators(
        payload: UtilityPaymentOperatorLoaderComposerPayload<UtilityPaymentOperator>,
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        let composer = UtilityPaymentOperatorLoaderComposer(
            model: model,
            pageSize: settings.pageSize
        )
        let loadOperators = composer.compose()
        
        loadOperators(payload) { completion($0); _ = composer }
    }
    
    func composedLoadOperators(
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        composedLoadOperators(payload: .init(), completion: completion)
    }
}

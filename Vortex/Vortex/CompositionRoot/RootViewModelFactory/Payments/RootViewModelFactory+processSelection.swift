//
//  RootViewModelFactory+processSelection.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.12.2024.
//

extension RootViewModelFactory {
    
    typealias PrepaymentSelect = InitiateAnywayPaymentDomain.Select
    typealias ProcessSelectionResult = InitiateAnywayPaymentDomain.Result
    typealias OperatorServices = Vortex.OperatorServices<UtilityPaymentProvider, UtilityService>
    typealias InitiateAnywayPaymentDomain = Vortex.InitiateAnywayPaymentDomain<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService, OperatorServices, AnywayTransactionState.Transaction>
    
    @inlinable
    func processSelection(
        select: (PrepaymentSelect, ServiceCategory.CategoryType),
        completion: @escaping (ProcessSelectionResult) -> Void
    ) {
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: infra.httpClient,
            log: log,
            loadOperators: { $1([]) } // not used in this case of ...!!!!!!!
        )
        let composer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let servicesComposer = PaymentsServicesViewModelComposer(
            model: model
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            composer: composer,
            nanoServices: nanoComposer.compose(categoryType: select.1),
            makeLegacyPaymentsServicesViewModel: {
                
                // also not used
                return servicesComposer.compose(payload: $0)
            }
        )
        
        let processSelection = microComposer.compose().processSelection
        
        processSelection(select.0) { completion($0); _ = microComposer }
    }
    
    func processSelection(
        select: PrepaymentSelect,
        completion: @escaping (ProcessSelectionResult) -> Void
    ) {
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: infra.httpClient,
            log: log,
            loadOperators: { $1([]) } // not used in this case of ...!!!!!!!
        )
        let composer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let servicesComposer = PaymentsServicesViewModelComposer(
            model: model
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            composer: composer,
            nanoServices: nanoComposer.compose(),
            makeLegacyPaymentsServicesViewModel: {
                
                // also not used
                return servicesComposer.compose(payload: $0)
            }
        )
        
        let processSelection = microComposer.compose().processSelection
        
        processSelection(select) { completion($0); _ = microComposer }
    }
}

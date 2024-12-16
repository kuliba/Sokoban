//
//  RootViewModelFactory+processSelection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.12.2024.
//

extension RootViewModelFactory {
    
    typealias PrepaymentSelect = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService>.Select
    typealias ProcessSelectionResult = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService>.ProcessSelectionResult
    
    @inlinable
    func processSelection(
        select: PrepaymentSelect,
        completion: @escaping (ProcessSelectionResult) -> Void
    ) {
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            loadOperators: { $0([]) } // not used in this case of ...!!!!!!!
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

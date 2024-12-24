//
//  RootViewModelFactory+processSelection.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.12.2024.
//

extension RootViewModelFactory {
    
    typealias PrepaymentSelect = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>.Select
    typealias ProcessSelectionResult = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>.ProcessSelectionResult
    
    @inlinable
    func processSelection(
        select: (PrepaymentSelect, ServiceCategory.CategoryType),
        completion: @escaping (ProcessSelectionResult) -> Void
    ) {
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
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
    
    @inlinable
    func processPayments(
        lastPayment: UtilityPaymentLastPayment,
        getCategoryType: @escaping (String) -> ServiceCategory.CategoryType?,
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        guard let categoryType = getCategoryType(lastPayment.type)
        else { return completion(nil) }
        
        let anywayFlowComposer = makeAnywayFlowComposer()
        
        processSelection(
            select: (.lastPayment(lastPayment), categoryType)
        ) {
            guard case let .success(.startPayment(transaction)) = $0
            else { return completion(nil) }
                        
            let flowModel = anywayFlowComposer.compose(transaction: transaction)
            let cancellable = flowModel.$state.compactMap(\.outside)
                .sink { notify($0) }
            
            completion(
                .anywayPayment(.init(
                    model: flowModel,
                    cancellable: cancellable
                ))
            )
        }
    }
}

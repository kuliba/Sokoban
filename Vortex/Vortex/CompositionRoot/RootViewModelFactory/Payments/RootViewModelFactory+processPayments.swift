//
//  RootViewModelFactory+processPayments.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.12.2024.
//

extension RootViewModelFactory {
    
    typealias GetCategoryTypeCompletion = (ServiceCategory.CategoryType?) -> Void
    typealias GetCategoryType = (String, @escaping GetCategoryTypeCompletion) -> Void
    
    @inlinable
    func processPayments(
        lastPayment: UtilityPaymentLastPayment,
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        getServiceCategoryType(ofType: lastPayment.type) { [weak self] categoryType in
            
            guard let self, let categoryType
            else { return completion(nil) }
            
            processSelection(
                select: (.lastPayment(lastPayment), categoryType)
            ) { [weak self] in
                
                guard let self,
                      case let .success(.startPayment(transaction)) = $0
                else { return completion(nil) }
                
                let flowModel = makeAnywayFlowModel(transaction: transaction)
                let cancellable = flowModel.$state.compactMap(\.outside)
                    .sink { notify($0) }
                
                completion(.anywayPayment(.init(
                    model: flowModel,
                    cancellable: cancellable
                )))
            }
        }
    }
}

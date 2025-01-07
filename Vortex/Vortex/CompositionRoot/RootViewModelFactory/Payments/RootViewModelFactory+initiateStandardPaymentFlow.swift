//
//  RootViewModelFactory+initiateStandardPaymentFlow.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func initiateStandardPaymentFlow(
        ofType type: ServiceCategory.CategoryType,
        completion: @escaping (StandardPaymentResult) -> Void
    ) {
        loadServiceCategory(ofType: type) { [weak self] in
            
            guard let self else { return }
            
            guard let category = $0
            else {

                logger.log(level: .error, category: .cache, message: "Missing category \(type).", file: #file, line: #line)
                return completion(.failure(.missingCategoryOfType(type)))
            }
            
            makePaymentProviderPicker(for: category) { [weak self] in
                
                guard let self else { return }
                
                switch $0 {
                case .failure:
                    let binder = makeServiceCategoryFailure(
                        category: category
                    )
                    completion(.failure(.makeStandardPaymentFailure(binder)))
                    
                case let .success(binder):
                    completion(.success(binder))
                }
            }
        }
    }
    
    typealias StandardPaymentResult = Result<PaymentProviderPickerDomain.Binder, StandardPaymentFailure>
    
    enum StandardPaymentFailure: Error {
        
        case makeStandardPaymentFailure(ServiceCategoryFailureDomain.Binder)
        case missingCategoryOfType(ServiceCategory.CategoryType)
    }
}

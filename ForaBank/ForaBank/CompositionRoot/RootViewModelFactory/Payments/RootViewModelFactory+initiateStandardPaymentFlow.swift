//
//  RootViewModelFactory+initiateStandardPaymentFlow.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func initiateStandardPaymentFlow(
        ofType type: ServiceCategory.CategoryType,
        completion: @escaping (StandardPaymentResult) -> Void
    ) {
        loadCategory(type: type) {
            
            guard let category = $0
            else { return completion(.failure(.missingCategoryOfType(type))) }
            
            self.makeStandard(category) {
                
                switch $0 {
                case .failure:
                    completion(.failure(.makeStandardPaymentFailure))
                    
                case let .success(binder):
                    completion(.success(binder))
                }
            }
        }
    }
    
    typealias StandardPaymentResult = Result<PaymentProviderPickerDomain.Binder, StandardPaymentFailure>
    
    enum StandardPaymentFailure: Error {
        
        case makeStandardPaymentFailure
        case missingCategoryOfType(ServiceCategory.CategoryType)
    }
}

//
//  RootViewModelFactory+makeUtilityPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeUtilityPayment(
        completion: @escaping (UtilityPaymentResult) -> Void
    ) {
        loadCategory(type: .housingAndCommunalService) {
            
            guard let category = $0 else { return completion(.missingUtility) }
            
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
    
    typealias UtilityPaymentResult = Result<PaymentProviderPicker.Binder, UtilityPaymentFailure>
    
    enum UtilityPaymentFailure: Error {
        
        case makeStandardPaymentFailure
        case missingCategoryOfType(ServiceCategory.CategoryType)
    }
}

private extension RootViewModelFactory.UtilityPaymentResult {
    
    static let missingUtility: Self = .failure(.missingCategoryOfType(.housingAndCommunalService))
}

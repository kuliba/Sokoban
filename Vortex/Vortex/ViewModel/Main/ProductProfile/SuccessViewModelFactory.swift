//
//  SuccessViewModelFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 18.03.2025.
//


struct SuccessViewModelFactory {
    
    typealias MakeSuccessViewModel = (PaymentsSuccessViewModel.Mode) -> PaymentsSuccessViewModel?
    
    let makeSuccessViewModel: MakeSuccessViewModel
}

extension SuccessViewModelFactory{
    
    static func makeSuccessViewModel(
        _ model: Model
    ) -> SuccessViewModelFactory {
        
        .init(makeSuccessViewModel: {
            
            if let success = Payments.Success(
                model: model,
                mode: $0,
                amountFormatter: model.amountFormatted(amount:currencyCode:style:)
            ) {
                
                return .init(paymentSuccess: success, model)
            }
            return nil
        })
    }
}

//
//  SuccessViewModelMode+ParameterReducerCase.swift
//  ForaBank
//
//  Created by Max Gribov on 24.06.2023.
//

import Foundation

extension PaymentsSuccessViewModel.Mode: PaymentsParametersReducerCase {
    
    var parametersOrder: [Payments.Parameter.Identifier]? {
        
        switch self {
        case .meToMe, .makePaymentToDeposit, .makePaymentFromDeposit:
            return [.successStatus,
                    .successTitle,
                    .successAmount,
                    .successOptionButtons,
                    .successActionButton]
            
        default:
            return nil
        }
    }
}

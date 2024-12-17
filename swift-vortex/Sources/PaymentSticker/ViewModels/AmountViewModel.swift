//
//  ParameterAmountViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import Foundation

public struct AmountViewModel {
    
    typealias Parameter = Operation.Parameter.Amount
    
    let parameter: Parameter
    let isCompleteOperation: Bool
    let continueButtonTapped: () -> Void
    
    func reduceState(
        state: Operation.Parameter.Amount.State,
        isCompleteOperation: Bool,
        action: @escaping () -> Void
    ) -> AmountView.TransferButtonView.TransferButtonViewModel {
        
        if !isCompleteOperation {
            return .inactive
        }
        
        switch state {
        case .loading:
            return .loading
            
        case .userInteraction:
            return .active(action: action)
        }
    }
}

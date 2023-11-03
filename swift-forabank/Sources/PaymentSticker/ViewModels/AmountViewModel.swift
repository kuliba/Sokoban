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
    let continueButtonTapped: () -> Void
}

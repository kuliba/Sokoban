//
//  PaymentsParameterViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 19.02.2022.
//

import Foundation

class PaymentsParameterViewModel: Identifiable, ObservableObject {
    
    var id: Payments.Parameter.ID { parameter.id }
    let parameter: Payments.Parameter
    
    init(parameter: Payments.Parameter) {
        
        self.parameter = parameter
    }
}

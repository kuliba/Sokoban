//
//  PaymentsParameter.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

protocol PaymentsParameter: Identifiable {
    
    associatedtype Value

    var id: Payments.Parameter.Identifier { get }
    var name: String { get }
    var icon: Data { get }
    var value: Value { get }
}

protocol PaymentsParameterValidatable: PaymentsParameter {
    
    associatedtype Validator: ValidatorProtocol
    
    var validator: Validator { get }
}

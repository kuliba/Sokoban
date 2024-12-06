//
//  PaymentsValidationRulesSystemRule.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.05.2023.
//

import Foundation

protocol PaymentsValidationRulesSystemRule {
    
    var actions: [Payments.Validation.Stage: Payments.Validation.Action] { get }
    func grade(_ value: Payments.Parameter.Value) -> Bool
}


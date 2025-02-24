//
//  RootViewModelFactory+formatAmount.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func format(
        amount: Decimal?,
        currencyCode: String?,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        return format(
            amount: amount?.doubleValue,
            currencyCode: currencyCode,
            style: style
        )
    }
    
    @inlinable
    func format(
        amount: Double?,
        currencyCode: String?,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        guard let amount else { return nil }
        
        return model.amountFormatted(
            amount: amount,
            currencyCode: currencyCode,
            style: style
        )
    }
    
    @inlinable
    func format(
        amount: Decimal?,
        currencyCodeNumeric: Int,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        return format(
            amount: amount?.doubleValue,
            currencyCodeNumeric: currencyCodeNumeric,
            style: style
        )
    }
    
    @inlinable
    func format(
        amount: Double?,
        currencyCodeNumeric: Int,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        guard let amount else { return nil }
        
        return model.amountFormatted(
            amount: amount,
            currencyCodeNumeric: currencyCodeNumeric,
            style: .normal
        )
    }
}

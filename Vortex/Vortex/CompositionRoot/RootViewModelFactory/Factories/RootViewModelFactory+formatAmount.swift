//
//  RootViewModelFactory+formatAmount.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func formatAmount(
        value: Decimal?,
        currencyCode: String?,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        return formatAmount(
            value: value?.doubleValue,
            currencyCode: currencyCode,
            style: style
        )
    }
    
    @inlinable
    func formatAmount(
        value: Double?,
        currencyCode: String?,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        guard let value else { return nil }
        
        return model.amountFormatted(
            amount: value,
            currencyCode: currencyCode,
            style: style
        )
    }
    
    @inlinable
    func formatAmount(
        value: Decimal?,
        currencyCodeNumeric: Int,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        return formatAmount(
            value: value?.doubleValue,
            currencyCodeNumeric: currencyCodeNumeric,
            style: style
        )
    }
    
    @inlinable
    func formatAmount(
        value: Double?,
        currencyCodeNumeric: Int,
        style: Model.AmountFormatStyle = .normal
    ) -> String? {
        
        guard let value else { return nil }
        
        return model.amountFormatted(
            amount: value,
            currencyCodeNumeric: currencyCodeNumeric,
            style: .normal
        )
    }
}

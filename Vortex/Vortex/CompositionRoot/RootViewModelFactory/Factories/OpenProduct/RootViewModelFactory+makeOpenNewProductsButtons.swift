//
//  RootViewModelFactory+makeOpenNewProductsButtons.swift
//  Vortex
//
//  Created by Andryusina Nataly on 16.01.2025.
//

import Foundation
import SwiftUI

extension RootViewModelFactory {
    
    func makeOpenNewProductButtons(
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        action: @escaping (OpenProductType) -> Void
    ) -> [NewProductButton.ViewModel] {
        
        let displayButtons = displayButtons(collateralLoanLandingFlag: collateralLoanLandingFlag)
        
        return displayButtons.compactMap {
            
            guard let tapAction = tapAction(type: $0, collateralLoanLandingFlag: collateralLoanLandingFlag, action: action)
            else { return nil }
            
            return .init(
                openProductType: $0,
                subTitle: description(for: $0),
                action: tapAction
            )
        }
    }
    
    private func depositDescription(with deposits: [DepositProductData]) -> String {
        
        guard let maxRate = deposits.map({ $0.generalСondition.maxRate }).max(),
              let maxRateString = NumberFormatter.persent.string(from: NSNumber(value: maxRate / 100))
        else { return "..." }
        
        return "\(maxRateString)"
    }
    
    private func description(for type: OpenProductType) -> String {
        
        switch type {
        case .account:          return "Бесплатно"
        case .card:             return "С кешбэком"
        case .deposit:          return depositDescription(with: model.deposits.value)
        case .insurance:        return "Надежно"
        case .collateralLoan:   return "Выгодно"
        case .mortgage:         return "Удобно"
        case .savingsAccount:   return "% на остаток"
        case .sticker:          return "Быстро"
        }
    }
    
    private func displayButtons(
        collateralLoanLandingFlag: CollateralLoanLandingFlag
    ) -> [OpenProductType] {
        
        let displayButtonsTypes: [OpenProductType] = [.card(.landing), .deposit, .account, .sticker, .collateralLoan(.showcase)]
        let additionalItems: [OpenProductType] = [.savingsAccount, .insurance, .mortgage]
        return (displayButtonsTypes + additionalItems)
    }
    
    private func tapAction(
        type: OpenProductType,
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        action: @escaping (OpenProductType) -> Void
    ) -> NewProductButton.ViewModel.TapActionType? {
        
        switch type {
        case .collateralLoan:
            return collateralLoanLandingFlag.isActive
            ? .action({ action(type) })
            : .url(model.productsOpenLoanURL)
            
        case .savingsAccount:
            return .action({ action(type) })
            
        case .insurance:
            return .url(model.productsOpenInsuranceURL)
            
        case .mortgage:
            return .url(model.productsOpenMortgageURL)
            
        case .card:
            if model.onlyCorporateCards {
                return .url(model.productsOpenAccountURL)
            } else {
                return .action { action(.card(.landing)) }
            }
            
        default:
            return .action({ action(type) })
        }
    }
}

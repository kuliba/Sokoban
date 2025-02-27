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
        savingsAccountFlag: SavingsAccountFlag,
        action: @escaping (OpenProductType) -> Void
    ) -> [NewProductButton.ViewModel] {
        
        let displayButtons = displayButtons(collateralLoanLandingFlag: collateralLoanLandingFlag, savingsAccountFlag: savingsAccountFlag)
        
        return displayButtons.compactMap {
            
            guard let tapAction = tapAction(type: $0, collateralLoanLandingFlag: collateralLoanLandingFlag, savingsAccountFlag: savingsAccountFlag, action: action)
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
        case .creditCardMVP:    return ""
        case .deposit:          return depositDescription(with: model.deposits.value)
        case .insurance:        return "Надежно"
        case .loan:             return "Выгодно"
        case .mortgage:         return "Удобно"
        case .savingsAccount:   return "% на остаток"
        case .sticker:          return "Быстро"
        }
    }
    
    private func displayButtons(
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        savingsAccountFlag: SavingsAccountFlag
    ) -> [OpenProductType] {
        
        let displayButtonsTypes: [OpenProductType] = [.card, .deposit, .account, .sticker, .loan]
        let additionalItems: [OpenProductType] = savingsAccountFlag.isActive
        ? [.savingsAccount, .insurance, .mortgage]
        : [.insurance, .mortgage]
        return (displayButtonsTypes + additionalItems)
    }
    
    private func tapAction(
        type: OpenProductType,
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        savingsAccountFlag: SavingsAccountFlag,
        action: @escaping (OpenProductType) -> Void
    ) -> NewProductButton.ViewModel.TapActionType? {
        
        switch type {
        case .loan:
            return collateralLoanLandingFlag.isActive
            ? .action({ action(type) })
            : .url(model.productsOpenLoanURL)
            
        case .savingsAccount:
            return savingsAccountFlag.isActive
            ? .action({ action(type) })
            : nil
            
        case .insurance:
            return .url(model.productsOpenInsuranceURL)
            
        case .mortgage:
            return .url(model.productsOpenMortgageURL)
            
        case .card:
            if model.onlyCorporateCards {
                return .url(model.productsOpenAccountURL)
            } else {
                return .action { action(.card) }
            }
            
        default:
            return .action({ action(type) })
        }
    }
}

//
//  RootViewModelFactory+makeOpenNewProductsButtons.swift
//  Vortex
//
//  Created by Andryusina Nataly on 16.01.2025.
//

import Foundation
import SwiftUI

enum OpenProductType: String, Equatable, CaseIterable, Hashable {
    
    case account =          "ACCOUNT"
    case card =             "CARD"
    case deposit =          "DEPOSIT"
    case insurance =        "INSURANCE"
    case loan =             "LOAN"
    case mortgage =         "MORTGAGE"
    case savingsAccount =   "SAVINGSACCOUNT"
    case sticker =          "STICKER"
}

extension OpenProductType {
    
    var openButtonIcon: Image {
        
        switch self {
        case .account:          return .ic24FilePluseColor
        case .card:             return .ic24NewCardColor
        case .deposit:          return .ic24DepositPlusColor
        case .insurance:        return .ic24InsuranceColor
        case .loan:             return .ic24CreditColor
        case .mortgage:         return .ic24Mortgage
        case .savingsAccount:   return .ic24FilePluseColorProcent
        case .sticker:          return .ic24Sticker
        }
    }
    
    var openButtonTitle: String {
        
        switch self {
        case .account:          return "Счет"
        case .card:             return "Карту"
        case .deposit:          return "Вклад"
        case .insurance:        return "Страховку"
        case .loan:             return "Кредит"
        case .mortgage:         return "Ипотеку"
        case .savingsAccount:   return "Счет накопительный"
        case .sticker:          return "Стикер"
        }
    }
}

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
            
        default:
            return .action({ action(type) })
        }
    }
}

//
//  UpdateInfo.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.05.2024.
//

import Foundation

struct UpdateInfo: Equatable {
    
    var isCardsUpdated: Bool
    var isLoansUpdated: Bool
    var isDepositsUpdated: Bool
    var isAccountsUpdated: Bool
    
    var isProductsUpdated: Bool {
        return isCardsUpdated && isLoansUpdated && isDepositsUpdated && isAccountsUpdated
    }
    
    init(
        isCardsUpdated: Bool = true,
        isLoansUpdated: Bool = true,
        isDepositsUpdated: Bool = true,
        isAccountsUpdated: Bool = true
    ) {
        self.isCardsUpdated = isCardsUpdated
        self.isLoansUpdated = isLoansUpdated
        self.isDepositsUpdated = isDepositsUpdated
        self.isAccountsUpdated = isAccountsUpdated
    }
    
    mutating func updateValueBy(type: ProductType, with newValue: Bool) {
        switch type {
        case .card:
            isCardsUpdated = newValue
        case .account:
            isAccountsUpdated = newValue
        case .deposit:
            isDepositsUpdated = newValue
        case .loan:
            isLoansUpdated = newValue
        }
    }
}

class UpdateInfoViewModel: MainSectionViewModel {
    
    override var type: MainSectionType { .updateInfo }
    let content: String
    
    internal init(content: String) {
        
        self.content = content
    }
}

typealias MakeUpdateInfoView = (String) -> UpdateInfoView

extension String {
  
    static let updateInfoText: Self = "Мы не смогли загрузить ваши продукты. Попробуйте позже."
}

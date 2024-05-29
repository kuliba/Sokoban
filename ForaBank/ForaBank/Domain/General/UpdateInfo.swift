//
//  UpdateInfo.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.05.2024.
//

import Foundation

struct UpdateInfo: Equatable {
    
    var areCardsUpdated: Bool
    var areLoansUpdated: Bool
    var areDepositsUpdated: Bool
    var areAccountsUpdated: Bool
    
    var areProductsUpdated: Bool {
        return areCardsUpdated && areLoansUpdated && areDepositsUpdated && areAccountsUpdated
    }
    
    init(
        areCardsUpdated: Bool = true,
        areLoansUpdated: Bool = true,
        areDepositsUpdated: Bool = true,
        areAccountsUpdated: Bool = true
    ) {
        self.areCardsUpdated = areCardsUpdated
        self.areLoansUpdated = areLoansUpdated
        self.areDepositsUpdated = areDepositsUpdated
        self.areAccountsUpdated = areAccountsUpdated
    }
    
    mutating func updateValueBy(type: ProductType, with newValue: Bool) {
        switch type {
        case .card:
            areCardsUpdated = newValue
        case .account:
            areAccountsUpdated = newValue
        case .deposit:
            areDepositsUpdated = newValue
        case .loan:
            areLoansUpdated = newValue
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

class UpdateInfoPTViewModel: PaymentsTransfersSectionViewModel {
    
    override var type: PaymentsTransfersSectionType { .updateInfo }
}

typealias MakeUpdateInfoView = (String) -> UpdateInfoView

extension String {
  
    static let updateInfoText: Self = "Мы не смогли загрузить ваши продукты. Попробуйте позже."
}

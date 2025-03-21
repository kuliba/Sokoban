//
//  UpdateInfo.swift
//  Vortex
//
//  Created by Andryusina Nataly on 28.05.2024.
//

import Foundation

struct UpdateInfo: Equatable {
    
    var areCardsUpdated = true
    var areLoansUpdated = true
    var areDepositsUpdated = true
    var areAccountsUpdated = true
    
    // TODO: вернуть после оптимизации запросов
    
    var areProductsUpdated: Bool {
        return true /*areCardsUpdated && areLoansUpdated && areDepositsUpdated && areAccountsUpdated*/
    }
    
    var areCardsOrAccountsUpdated: Bool {
        
        return true /*areCardsUpdated || areAccountsUpdated*/
    }

    
    mutating func setValue(_ value: Bool, for type: ProductType) {
        
        switch type {
        case .card:
            areCardsUpdated = value
        case .account:
            areAccountsUpdated = value
        case .deposit:
            areDepositsUpdated = value
        case .loan:
            areLoansUpdated = value
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
    
    override var type: PaymentsTransfersSectionType { .updateFailureInfo }
}

typealias MakeUpdateInfoView = (String) -> UpdateInfoView

extension String {
    
    static let updateInfoText = "Мы не смогли загрузить ваши продукты. Попробуйте позже."
}

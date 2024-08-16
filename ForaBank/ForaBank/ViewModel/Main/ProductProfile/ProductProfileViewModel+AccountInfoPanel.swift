//
//  ProductProfileViewModel+AccountInfoPanel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import Foundation

extension ProductProfileViewModel {
    
    func createAccountInfoPanel(_ card: ProductCardData) {
        
        let buttons: [PanelButtonDetails] = [
            .init(
                id: card.id,
                title: .accountDetailsTitle(by: card.cardType),
                icon: .ic24FileText,
                subtitle: nil,
                kind: .accountDetails),
            .init(
                id: card.id,
                title: .accountStatementTitle(),
                icon: .ic24FileHash,
                subtitle: .accountStatementSubtitle(by: card.cardType),
                kind: .accountStatement
            )
        ]
        bottomSheet = .init(type: .optionsPanelNew(buttons))
    }
}

extension String {
    
    static func accountDetailsTitle(by type: ProductCardData.CardType?) -> String {
        switch type {
        case nil, .main, .regular, .additionalSelfAccOwn, .additionalSelf:
            return "Реквизиты счета и карты"
        case .additionalOther, .corporate, .individualBusinessman, .additionalCorporate, .individualBusinessmanMain:
            return "Реквизиты карты"
        }
    }
    
    static func accountStatementTitle() -> String {
        return "Выписка по счету"
    }
    
    static func accountStatementSubtitle(by type: ProductCardData.CardType?) -> String? {
        
        guard let type else { return nil }
        
        switch type {
        case .additionalSelf, .additionalOther:
            return "Выписку может заказать владелец основной карты и счета"
        default:
            return nil
        }
    }
}

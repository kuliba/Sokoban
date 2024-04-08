//
//  ProductProfileViewModel+AccountInfoPanel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import Foundation

extension ProductProfileViewModel {
    
    func createAccountInfoPanel(_ card: ProductCardData) {
        
        let buttons: [PanelButton] = [
            .init(
                event: { [weak self] in self?.event(.accountDetails(card.id)) },
                config: .init(
                    title: .accountDetailsTitle(by: card.cardType),
                    icon: .ic24FileText,
                    subtitle: nil)),
            .init(
                event: { [weak self] in self?.event(.accountStatement(card.id)) },
                config: .init(
                    title: .accountStatementTitle(),
                    icon: .ic24FileHash,
                    subtitle: .accountStatementSubtitle(by: card.cardType)))
        ]
        bottomSheet = .init(type: .optionsPanelNew(buttons))
    }
}

private extension String {
    
    static func accountDetailsTitle(by type: ProductCardData.CardType?) -> String {
        switch type {
        case nil, .main, .regular, .additionalSelfAccOwn:
            return "Реквизиты счета и карты"
        case .additionalSelf, .additionalOther:
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

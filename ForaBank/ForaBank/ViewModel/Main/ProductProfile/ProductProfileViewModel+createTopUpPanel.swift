//
//  ProductProfileViewModel+createTopUpPanel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.04.2024.
//

import Foundation

extension ProductProfileViewModel {
    
    func topLeftActionForCard(_ card: ProductCardData) {
        
        switch card.cardType {
        case .additionalCorporate, .corporate, .individualBusinessman:
            event(.alert(.delayAlert(.showServiceOnlyIndividualCard)))
            
        default:
            createTopUpPanel(card)
        }
    }
    
    func topRightActionForCard(_ productData: ProductData?) {
        
        guard let card = productData?.asCard else { return }

        switch card.cardType {
            
        case .additionalOther:
            event(.alert(.delayAlert(.showTransferAdditionalOther)))
            
        case .additionalCorporate, .corporate, .individualBusinessman:
            event(.alert(.delayAlert(.showServiceOnlyIndividualCard)))
        
        default:
            action.send(ProductProfileViewModelAction.TransferButtonDidTapped())
        }
    }
    
    func createTopUpPanel(_ card: ProductCardData) {
        
        let buttons: [PanelButtonDetails] = [
            .init(
                id: card.id,
                title: .accountAnotherBankTitle(),
                icon: .ic24Sbp,
                subtitle: .accountAnotherBankSubtitle(by: card.cardType),
                kind: .accountAnotherBank
            ),
            .init(
                id: card.id,
                title: .accountOurBankTitle(),
                icon: .ic24Between,
                subtitle: .accountOurBankSubtitle(by: card.cardType),
                kind: .accountOurBank)
        ]
        bottomSheet = .init(type: .optionsPanelNew(buttons))
    }
}

extension String {
    
    static func accountAnotherBankTitle() -> String {
        return "С моего счета в другом банке"
    }
    
    static func accountOurBankTitle() -> String {
        return "Со своего счета"
    }
    
    static func accountAnotherBankSubtitle(by type: ProductCardData.CardType?) -> String? {
        
        guard let type else { return nil }
        
        switch type {
        case .additionalSelf, .additionalOther:
            return "Эта услуга доступна только для основной карты"
        default:
            return nil
        }
    }
    
    static func accountOurBankSubtitle(by type: ProductCardData.CardType?) -> String? {
        
        guard let type else { return nil }
        
        switch type {
        case .additionalOther:
            return "Эта услуга доступна только владельцу карты"
        default:
            return nil
        }
    }
}

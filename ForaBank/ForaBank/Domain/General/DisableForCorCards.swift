//
//  DisableForCorCards.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 21.08.2024.
//

import Foundation

class DisableForCorCardsPTViewModel: PaymentsTransfersSectionViewModel {
    
    override var type: PaymentsTransfersSectionType { .disableForCorCards }
}

typealias MakeDisableForCorCardsInfoView = (String) -> DisableCorCardsView

extension String {
  
    static let disableForCorCards: Self = "Все возможности нашего приложения будут доступны после того, как вы откроете продукт как физ. лицо"
}

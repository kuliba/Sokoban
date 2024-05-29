//
//  CvvInfo.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.04.2024.
//

import Foundation
import PinCodeUI
import CardUI

typealias ShowCVV = (CardDomain.CardId, @escaping (CardInfo.CVV?) -> Void) -> Void

struct CvvInfo {
    
    let showCvv: ShowCVV?
    let cardType: ProductCardData.CardType?
    let cardStatus: ProductCardData.StatusCard?
}

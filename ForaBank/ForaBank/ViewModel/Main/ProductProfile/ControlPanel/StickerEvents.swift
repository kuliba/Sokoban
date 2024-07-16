//
//  StickerEvents.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.07.2024.
//

import Foundation
import SwiftUI

enum StickerEvent {
    
    case openCard(AuthProductsViewModel)
    case orderSticker(any View)
}

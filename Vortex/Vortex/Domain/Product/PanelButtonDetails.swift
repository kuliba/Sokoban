//
//  PanelButtonDetails.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI

struct PanelButtonDetails {
    
    let id: ProductData.ID
    let title: String
    let icon: Image?
    let subtitle: String?
    let kind: Kind
}

extension PanelButtonDetails {
    
    enum Kind {
        
        case accountDetails
        case accountStatement
        case accountOurBank
        case accountAnotherBank
        case cardGuardian
        case changePin
        case visibility
    }
}

extension PanelButtonDetails {
    
    func event() -> Event {
    
        switch kind {
        case .accountDetails:
            return .init(productID: id, type: .accountDetails)
        case .accountStatement:
            return .init(productID: id, type: .accountStatement)
        case .accountOurBank:
            return .init(productID: id, type: .accountOurBank)
        case .accountAnotherBank:
            return .init(productID: id, type: .accountAnotherBank)
        case .cardGuardian:
            return .init(productID: id, type: .cardGuardian)
        case .changePin:
            return .init(productID: id, type: .changePin)
        case .visibility:
            return .init(productID: id, type: .visibility)
        }
    }
}

extension PanelButtonDetails {
    
    typealias Event = ProductProfileFlowManager.ButtonEvent
}

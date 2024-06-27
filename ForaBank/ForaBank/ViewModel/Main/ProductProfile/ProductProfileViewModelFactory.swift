//
//  ProductProfileViewModelFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 10.04.2024.
//

import SwiftUI

struct ProductProfileViewModelFactory {
    
    let makeInfoProductViewModel: (Parameters) -> InfoProductViewModel
    let makeAlert: (AlertParameters) -> Alert.ViewModel
    let makeInformerDataUpdateFailure: MakeInformerDataUpdateFailure
    let makeCardGuardianPanel: MakeCardGuardianPanel
    
    struct Parameters {
        let model: Model
        let productData: ProductData
        let info: Bool
        let showCVV: ShowCVV?
        let events: Events
        
        init(
            model: Model,
            productData: ProductData,
            info: Bool,
            showCVV: ShowCVV? = nil,
            events: @escaping Events = { _ in }
        ) {
            self.model = model
            self.productData = productData
            self.info = info
            self.showCVV = showCVV
            self.events = events
        }
    }
    
    struct AlertParameters {
        
        let title: String
        let message: String?
        let primaryButton: Alert.ViewModel.ButtonViewModel
        let secondaryButton: Alert.ViewModel.ButtonViewModel?
        
        init(
            statusCard: ProductCardData.StatusCard,
            primaryButton: Alert.ViewModel.ButtonViewModel,
            secondaryButton: Alert.ViewModel.ButtonViewModel?
        ) {
            self.title = .alertTitle(statusCard)
            self.message = .description(statusCard)
            self.primaryButton = primaryButton
            self.secondaryButton = secondaryButton
        }
    }
}

extension ProductProfileViewModelFactory {
    
    typealias Event = AlertEvent
    typealias Events = (Event) -> Void

    typealias MakeCardGuardianPanel = (ProductCardData) -> ProductProfileViewModel.CardGuardianPanelKind
}

extension ProductProfileViewModelFactory {
    
    static let preview: Self = .init(
        makeInfoProductViewModel: {
            _ in .sample
        },
        makeAlert: { .init(
            title: $0.title,
            message: $0.message,
            primary: $0.primaryButton,
            secondary: $0.secondaryButton)
        },
        makeInformerDataUpdateFailure: { nil }, 
        makeCardGuardianPanel: { .bottomSheet(.cardGuardian($0))}
    )
}

private extension String {
    
    static func alertTitle(_ statusCard: ProductCardData.StatusCard) -> String {
        
        switch statusCard {
        case .active: return "Заблокировать карту?"
        case .blockedUnlockAvailable: return "Разблокировать карту?"
        case .blockedUnlockNotAvailable: return "Невозможно разблокировать"
        case .notActivated: return ""
        }
    }
    
    static func description(_ statusCard: ProductCardData.StatusCard) -> String? {
        
        switch statusCard {
        case .blockedUnlockNotAvailable: return "Обратитесь в поддержку, чтобы разблокировать карту"
        case .active: return "Карту можно будет разблокировать в приложении или в колл-центре"
        default:
            return nil
        }
    }
}

extension ProductProfileViewModelFactory {
    
    static let makeCardGuardianPanelPreview: MakeCardGuardianPanel = { card in .bottomSheet(.cardGuardian(card))}
}

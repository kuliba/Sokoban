//
//  ProductProfileViewModelFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 10.04.2024.
//

import SwiftUI
import LandingUIComponent

struct ProductProfileViewModelFactory {
    
    let makeInfoProductViewModel: (Parameters) -> InfoProductViewModel
    let makeAlert: (AlertParameters) -> Alert.ViewModel
    let makeInformerDataUpdateFailure: MakeInformerDataUpdateFailure
    let makeCardGuardianPanel: MakeCardGuardianPanel
    let makeSubscriptionsViewModel: UserAccountNavigationStateManager.MakeSubscriptionsViewModel

    private let model: Model
    
    init(
        makeInfoProductViewModel: @escaping (Parameters) -> InfoProductViewModel,
        makeAlert: @escaping (AlertParameters) -> Alert.ViewModel,
        makeInformerDataUpdateFailure: @escaping MakeInformerDataUpdateFailure,
        makeCardGuardianPanel: @escaping MakeCardGuardianPanel,
        makeSubscriptionsViewModel: @escaping UserAccountNavigationStateManager.MakeSubscriptionsViewModel,
        model: Model
    ) {
        self.makeInfoProductViewModel = makeInfoProductViewModel
        self.makeAlert = makeAlert
        self.makeInformerDataUpdateFailure = makeInformerDataUpdateFailure
        self.makeCardGuardianPanel = makeCardGuardianPanel
        self.makeSubscriptionsViewModel = makeSubscriptionsViewModel
        self.model = model
    }

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
        
    func makeStickerLandingViewModel(
        _ type: AbroadType,
        config: LandingUIComponent.UILanding.Component.Config,
        landingActions: @escaping (LandingUIComponent.LandingEvent.Sticker) -> () -> Void
    ) -> LandingUIComponent.LandingWrapperViewModel {
            
            self.model.landingStickerViewModelFactory(
                abroadType: type,
                config: config,
                landingActions: landingActions
            )
        }
}

extension ProductProfileViewModelFactory {
    
    typealias Event = AlertEvent
    typealias Events = (Event) -> Void

    typealias MakeCardGuardianPanel = (ProductCardData) -> ProductProfileViewModel.CardGuardianPanelKind
    typealias MakeNavigationOperationView = () -> any View
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
        makeCardGuardianPanel: { .bottomSheet(.cardGuardian($0, .init(.inactive)))},
        makeSubscriptionsViewModel: { _,_ in .preview },
        model: .emptyMock
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
    
    static let makeCardGuardianPanelPreview: MakeCardGuardianPanel = { card in .bottomSheet(.cardGuardian(card, .init(.inactive)))}
}

//
//  RootViewModelFactory+makeMainViewModelSections.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Foundation
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func makeMainViewModelSections(
        bannersBinder: BannersBinder,
        c2gFlag: C2GFlag,
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        savingsAccountFlag: SavingsAccountFlag
    ) -> [MainSectionViewModel] {
        
        var sections = [
            MainSectionProductsView.ViewModel(
                model,
                promoProducts: nil
            ),
            MainSectionFastOperationView.ViewModel {
                
                createItems(c2gFlag: c2gFlag, action: $0)
            },
            MainSectionPromoView.ViewModel(model),
            //    BannerPickerSectionBinderWrapper.init(binder: binder),
            MainSectionCurrencyMetallView.ViewModel(model),
            MainSectionOpenProductView.ViewModel( // TODO: extract
                model,
                makeButtons: { [weak self] in
                    
                    guard let self else { return [] }
                    
                    return self.makeOpenNewProductButtons(
                        collateralLoanLandingFlag: collateralLoanLandingFlag,
                        savingsAccountFlag: savingsAccountFlag,
                        action: $0
                    )
                }
                                                ),
            MainSectionAtmView.ViewModel.initial
        ]
        
        if updateInfoStatusFlag.isActive {
            
            if !model.updateInfo.value.areProductsUpdated {
                
                sections.insert(
                    UpdateInfoViewModel.init(content: .updateInfoText),
                    at: 0
                )
            }
        }
        
        return sections
    }
    
    @inlinable
    func createItems(
        c2gFlag: C2GFlag,
        action: @escaping (FastOperations) -> Void
    ) -> [ButtonIconTextView.ViewModel] {
        
        return fastOperations(c2gFlag: c2gFlag).map { type in
            
            createButtonViewModel(c2gFlag: c2gFlag, for: type) { action(type) }
        }
    }
    
    @inlinable
    func fastOperations(
        c2gFlag: C2GFlag
    ) -> [FastOperations] {
        
        let uin: FastOperations? = c2gFlag.isActive ? .uin : nil
        return [.byQR, uin, .byPhone, .utility, .templates].compactMap { $0 }
    }
    
    @inlinable
    func createButtonViewModel(
        c2gFlag: C2GFlag,
        for type: FastOperations,
        action: @escaping () -> Void
    ) -> ButtonIconTextView.ViewModel {
        
        switch type {
        case .utility: return .utility(action)
        default:       return .default(c2gFlag: c2gFlag, for: type, action)
        }
    }
}

extension ButtonIconTextView.ViewModel {
    
    static func `default`(
        c2gFlag: C2GFlag,
        for type: FastOperations,
        _ action: @escaping () -> Void
    ) -> ButtonIconTextView.ViewModel {
        
        return .init(
            icon: .init(
                image: image(c2gFlag: c2gFlag, for: type),
                style: style(c2gFlag: c2gFlag, for: type),
                background: .circle,
                backgroundColor: backgroundColor(c2gFlag: c2gFlag, for: type)
            ),
            title: .init(text: type.title),
            orientation: .vertical,
            action: action
        )
    }
    
    private static func image(
        c2gFlag: C2GFlag,
        for type: FastOperations
    ) -> Image {
        
        switch type {
        case .byQR:
            switch c2gFlag.rawValue {
            case .active:   return .ic24Qr
            case .inactive: return .ic24BarcodeScanner2
            }
            
        default:
            return type.icon
        }
    }
    
    private static func style(
        c2gFlag: C2GFlag,
        for type: FastOperations
    ) -> ButtonIconTextView.ViewModel.Icon.Style {
        
        switch type {
        case .byQR:
            switch c2gFlag.rawValue {
            case .active:   return .color(.iconWhite)
            case .inactive: return .color(.iconBlack)
            }
            
        case .byPhone, .templates, .uin, .utility:
            return .color(.iconBlack)
        }
    }
    
    private static func backgroundColor(
        c2gFlag: C2GFlag,
        for type: FastOperations
    ) -> Color {
        
        switch type {
        case .byQR:
            switch c2gFlag.rawValue {
            case .active:   return .iconBlack
            case .inactive: return .mainColorsGrayLightest
            }
            
        case .byPhone, .templates, .uin, .utility:
            return .mainColorsGrayLightest
        }
    }
    
    static func utility(
        _ action: @escaping () -> Void
    ) -> ButtonIconTextView.ViewModel {
        
        let type: FastOperations = .utility
        
        return .init(
            icon: .init(
                image: type.icon,
                style: .original,
                background: .circle,
                badge: .init(
                    text: .init(
                        title: "0%",
                        font: .textBodySR12160(),
                        fontWeight: .bold
                    ),
                    backgroundColor: .mainColorsRed,
                    textColor: .white)
            ),
            title: .init(text: type.title),
            orientation: .vertical,
            action: action
        )
    }
}

private extension FastOperations {
    
    var icon: Image {
        
        switch self {
        case .byQR:      return .ic24BarcodeScanner2
        case .byPhone:   return .ic24Smartphone
        case .templates: return .ic24Star
        case .uin:       return .ic24Contract
        case .utility:   return .ic24Bulb
        }
    }
    
    var title: String {
        
        switch self {
        case .byQR:      return FastOperationsTitles.qr
        case .byPhone:   return FastOperationsTitles.byPhone
        case .templates: return FastOperationsTitles.templates
        case .uin:       return FastOperationsTitles.uin
        case .utility:   return FastOperationsTitles.utilityPayment
        }
    }
}

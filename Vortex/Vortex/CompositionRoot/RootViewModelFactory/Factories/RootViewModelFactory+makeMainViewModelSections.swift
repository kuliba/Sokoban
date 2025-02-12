//
//  RootViewModelFactory+makeMainViewModelSections.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeMainViewModelSections(
        bannersBinder: BannersBinder,
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        savingsAccountFlag: SavingsAccountFlag
    ) -> [MainSectionViewModel] {
        
        var sections = [
            MainSectionProductsView.ViewModel(
                model,
                promoProducts: nil
            ),
            MainSectionFastOperationView.ViewModel(createItems: createItems),
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
        action: @escaping (FastOperations) -> Void
    ) -> [ButtonIconTextView.ViewModel] {
        
        let displayButtonsTypes: [FastOperations] = [.byQr, .byPhone, .utility, .templates]
        
        return displayButtonsTypes.map { type in
            
            createButtonViewModel(for: type) { action(type) }
        }
    }
    
    @inlinable
    func createButtonViewModel(
        for type: FastOperations,
        action: @escaping () -> Void
    ) -> ButtonIconTextView.ViewModel {
        
        switch type {
        case .utility: return .utility(action)
        default:       return .default(for: type, action)
        }
    }
}

extension ButtonIconTextView.ViewModel {
    
    static func `default`(
        for type: FastOperations,
        _ action: @escaping () -> Void
    ) -> ButtonIconTextView.ViewModel {
        
        return .init(
            icon: .init(
                image: type.icon,
                background: .circle
            ),
            title: .init(text: type.title),
            orientation: .vertical,
            action: action
        )
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

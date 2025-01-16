//
//  RootViewModelFactory+makeMainViewModelSections.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Foundation

extension RootViewModelFactory {
    
    func makeMainViewModelSections(
        bannersBinder: BannersBinder,
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        savingsAccountFlag: SavingsAccountFlag
    ) -> [MainSectionViewModel] {
        
        let stickerViewModel:  ProductCarouselView.StickerViewModel? = nil
        
        var sections = [
            MainSectionProductsView.ViewModel(
                model,
                stickerViewModel: stickerViewModel
            ),
            MainSectionFastOperationView.ViewModel(),
            MainSectionPromoView.ViewModel(model),
            //    BannerPickerSectionBinderWrapper.init(binder: binder),
            MainSectionCurrencyMetallView.ViewModel(model),
            MainSectionOpenProductView.ViewModel(
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
                sections.insert(UpdateInfoViewModel.init(content: .updateInfoText), at: 0)
            }
        }
        return sections
    }
}

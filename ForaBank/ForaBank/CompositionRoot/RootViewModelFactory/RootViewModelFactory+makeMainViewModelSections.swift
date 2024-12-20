//
//  RootViewModelFactory+makeMainViewModelSections.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Foundation

extension RootViewModelFactory {
    
    func makeMainViewModelSections(
        bannersBinder: BannersBinder
    ) -> [MainSectionViewModel] {
        
        //        MainViewModel.getSections(
        //            model,
        //            bannersBinder,
        //            updateInfoStatusFlag: updateInfoStatusFlag,
        //            stickerViewModel: nil
        //        )
        
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
                makeItems: makeOpenNewProductItems
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
    
    func makeOpenNewProductItems(
        actionHandler: (ProductType) -> Void
    ) -> [NewProductButton.ViewModel] {
        
        let displayButtonsTypes: [ProductType] = [.card, .deposit, .account, .loan]
        
        let displayButtons: [String] = {
            
            var items = (displayButtonsTypes.map { $0.rawValue } + ["INSURANCE", "MORTGAGE"])
            items.insert(contentsOf: ["STICKER"], at: 3)
            return items
        }()
        
        var viewModels: [NewProductButton.ViewModel] = []
        
        for typeStr in displayButtons {
            
            if let type = ProductType(rawValue: typeStr) {
                
                let id = type.rawValue
                let icon = type.openButtonIcon
                let title = type.openButtonTitle
                let subTitle = description(for: type)
                
                switch type {
                case .loan:
                    viewModels.append(
                        NewProductButton.ViewModel(
                            id: id,
                            icon: icon,
                            title: title,
                            subTitle: subTitle,
                            url: model.productsOpenLoanURL
                        )
                    )
                    
                default:
                    viewModels.append(
                        NewProductButton.ViewModel(
                            id: id,
                            icon: icon,
                            title: title,
                            subTitle: subTitle,
                            action: { actionHandler(type) }
                        ))
                }
                
                } else { //no ProductType
                   
                    switch typeStr {
                    case "INSURANCE":
                        viewModels.append(NewProductButton.ViewModel(id: typeStr, icon: .ic24InsuranceColor, title: "Страховку", subTitle: "Надежно", url: model.productsOpenInsuranceURL))
                        
                    case "MORTGAGE":
                        viewModels.append(NewProductButton.ViewModel(id: typeStr, icon: .ic24Mortgage, title: "Ипотеку", subTitle: "Удобно", url: model.productsOpenMortgageURL))
                    
                    case "STICKER":
                        viewModels.append(NewProductButton.ViewModel(
                            id: typeStr,
                            icon: .ic24Sticker,
                            title: "Стикер",
                            subTitle: "Быстро",
                            action: { actionHandler(.loan) }
                        ))
                    default: break
                    }
                } //if
        } //for
        
        return viewModels

    }
    
    func description(for type: ProductType) -> String {
        
        switch type {
        case .card: return "С кешбэком"
        case .account: return "Бесплатно"
        case .deposit: return depositDescription(with: model.deposits.value)
        case .loan: return "Выгодно"
        }
    }
        
    private func depositDescription(with deposits: [DepositProductData]) -> String {
        
        guard let maxRate = deposits.map({ $0.generalСondition.maxRate }).max(),
              let maxRateString = NumberFormatter.persent.string(from: NSNumber(value: maxRate / 100))
        else { return "..." }
        
        return "\(maxRateString)"
    }
}

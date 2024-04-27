//
//  ProductProfileButtonsViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileButtonsView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()

        @Published var buttons: [ButtonIconTextRectView.ViewModel]
        
        init(buttons: [ButtonIconTextRectView.ViewModel]) {
            
            self.buttons = buttons
        }
        
        init(with product: ProductData, depositInfo: DepositInfoDataItem?) {
            
            self.buttons = []
            self.buttons = updatedButtons(for: product, depositInfo: depositInfo)
        }

        func update(with product: ProductData, depositInfo: DepositInfoDataItem?) {
            
            self.buttons = updatedButtons(for: product, depositInfo: depositInfo)
        }
        
        private func updatedButtons(for product: ProductData, depositInfo: DepositInfoDataItem?) -> [ButtonIconTextRectView.ViewModel] {
            
            var result = [ButtonIconTextRectView.ViewModel]()
            for type in ButtonType.allCases {
                
                let icon = buttonIcon(for: type, for: product)
                let title = buttonName(for: type, for: product)
                let isEnabled = buttonEnabled(for: type, for: product, depositInfo: depositInfo)
                
                result.append(.init(id: type.rawValue,
                                    icon: icon,
                                    title: title,
                                    isEnabled: isEnabled,
                                    action: { [weak self] in self?.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: type))}))
            }
            
            return result
        }
              
        func buttonEnabled(for buttonType: ButtonType, for product: ProductData, depositInfo: DepositInfoDataItem?) -> Bool {
            
            if product.asCard?.statusCard == .notActivated {
                
                switch buttonType {
                case .bottomLeft: return true
                default: return false
                }
            } else {
                
                switch buttonType {
                case .topLeft:
                    switch product {
                    case let cardProduct as ProductCardData:
                        return cardProduct.isBlocked ? false : true
                        
                    case let depositProduct as ProductDepositData:
                        return depositProduct.availableTransferType(
                            with: depositInfo,
                            deposit: depositProduct
                        ) != nil

                    default: return true
                    }
                    
                case .bottomLeft: return true
                    
                case .topRight:
                    switch product {
                    case let cardProduct as ProductCardData:
                        return cardProduct.isBlocked ? false : true
                        
                    case let depositProduct as ProductDepositData:
                        return depositProduct.availableTransferType(
                            with: depositInfo,
                            deposit: depositProduct
                        ) != nil
                        
                    case _ as ProductLoanData: return false
                    default: return true
                    }
                    
                case .bottomRight:
                    return true
                }
            }
        }

        func buttonName(for buttonType: ButtonType, for product: ProductData) -> String {
            
            switch buttonType {
            case .topLeft: return "Пополнить"
                
            case .bottomLeft:
                switch product.productType {
                case .account, .deposit: return "Детали"
                default: return "Реквизиты и выписки"
                }
                
            case .topRight:
                switch product.productType {
                case .loan: return "Управление"
                default: return "Перевести"
                }
                
            case .bottomRight:
                switch product {
                case _ as ProductCardData: return "Управление"
                case _ as ProductAccountData: return "Закрыть"
                case _ as ProductDepositData: return "Управление"
                default: return "Погасить досрочно"
                }
            }
        }
        
        func buttonIcon(for buttonType: ButtonType, for product: ProductData) -> Image {
            
            switch buttonType {
            case .topLeft: return .ic24Plus
                
            case .bottomLeft:
                switch product.productType {
                case .account, .deposit: return .ic24Info
                default: return .ic24FileText
                }
                
            case .topRight:
                switch product.productType {
                case .loan: return .ic24Server
                default: return .ic24ArrowUpRight
                }
                
            case .bottomRight:
                switch product {
                case _ as ProductCardData: return .ic24Server
                case _ as ProductAccountData: return .ic24Close
                case _ as ProductDepositData: return .ic24Server
                default: return .ic24Clock
                }
            }
        }
    }
}

//MARK: - Types

extension ProductProfileButtonsView.ViewModel {
    
    enum ButtonType: String, CaseIterable {
        
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
}

//MARK: - Action

enum ProductProfileButtonsSectionViewAction {

    struct ButtonDidTapped: Action {
        
        let buttonType: ProductProfileButtonsView.ViewModel.ButtonType
    }
}

//MARK: - View

struct ProductProfileButtonsView: View {
    
    @ObservedObject var viewModel: ProductProfileButtonsView.ViewModel
    
    var body: some View {

        if #available(iOS 14, *) {
            
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                
                ForEach(viewModel.buttons) { button in
                    
                    ButtonIconTextRectView(viewModel: button)
                        .frame(height: 48)
                }
            }
            
        } else {
           
            VStack(spacing: 8) {
                
                let rows = rows(with: viewModel.buttons)
                
                ForEach(rows, id: \.self) { row in
                    
                    HStack(spacing: 8) {
                        
                        ForEach(row) { button in

                            ButtonIconTextRectView(viewModel: button)
                        }
                    }
                }
            }
        }
    }
    
    func rows(with buttons: [ButtonIconTextRectView.ViewModel]) -> [[ButtonIconTextRectView.ViewModel]] {
        
        var result = [[ButtonIconTextRectView.ViewModel]]()
        var rowButtons = [ButtonIconTextRectView.ViewModel]()
        for item in buttons {

            rowButtons.append(item)
            
            if rowButtons.count >= 2 {
                
                result.append(rowButtons)
                rowButtons = [ButtonIconTextRectView.ViewModel]()
            }
        }
        
        return result
    }
}

//MARK: - Preview

struct ProfileButtonsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProductProfileButtonsView(viewModel: .sample)
                .previewLayout(.fixed(width: 350, height: 200))
    }
}

//MARK: - Preview Content

extension ProductProfileButtonsView.ViewModel {
    
    static let sample = ProductProfileButtonsView.ViewModel(buttons: [.samplePay, .sampleTransfer, .sampleReq, .sampleLock])
}

extension ButtonIconTextRectView.ViewModel {
 
    static let samplePay = ButtonIconTextRectView.ViewModel(id: UUID().uuidString, icon: .ic24Plus, title: "Пополнить", action: {})
    
    static let sampleTransfer = ButtonIconTextRectView.ViewModel(id: UUID().uuidString, icon: .ic24ArrowUpRight, title: "Перевести", action: {})
    
    static let sampleReq = ButtonIconTextRectView.ViewModel(id: UUID().uuidString, icon: .ic24FileText, title: "Реквизиты", action: {})
    
    static let sampleLock = ButtonIconTextRectView.ViewModel(id: UUID().uuidString, icon: .ic24Lock, title: "Блокировать", action: {})
}

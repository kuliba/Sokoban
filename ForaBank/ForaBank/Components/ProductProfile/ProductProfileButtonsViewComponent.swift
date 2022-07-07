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
        
        init(with product: ProductData) {
            
            self.buttons = []
            self.buttons = updatedButtons(for: product)
        }

        func update(with product: ProductData) {
            
            self.buttons = updatedButtons(for: product)
        }
        
        private func updatedButtons(for product: ProductData) -> [ButtonIconTextRectView.ViewModel] {
            
            var result = [ButtonIconTextRectView.ViewModel]()
            for type in ButtonType.allCases {
                
                let icon = buttonIcon(for: type, for: product)
                let title = buttonName(for: type, for: product)
                let isEnabled = buttonEnabled(for: type, for: product)
                
                result.append(.init(id: type.rawValue,
                                    icon: icon,
                                    title: title,
                                    isEnabled: isEnabled,
                                    action: { [weak self] in self?.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: type))}))
            }
            
            return result
        }
              
        func buttonEnabled(for buttonType: ButtonType, for product: ProductData) -> Bool {
            
            switch buttonType {
            case .topLeft:
                switch product.productType {
                case .card:
                    guard let cardProduct = product as? ProductCardData else {
                        return true
                    }
                    
                    return cardProduct.isBlocked ? false : true
                    
                default: return true
                }
                
            case .bottomLeft: return true
                
            case .topRight:
                switch product.productType {
                case .card:
                    guard let cardProduct = product as? ProductCardData else {
                        return true
                    }
                    
                    return cardProduct.isBlocked ? false : true
                    
                case .deposit:
                    guard let depositProduct = product as? ProductDepositData else {
                        return false
                    }
                    
                    return depositProduct.isTransferEnabled
                    
                case .loan: return false
                default: return true
                }
                
            case .bottomRight:
                switch product.productType {
                case .card:
                    guard let cardProduct = product as? ProductCardData else {
                        return false
                    }
                    
                    return cardProduct.isCanBeUnblocked ? true : false
                case .account: return false
                default: return true
                }
            }
        }
        
        func buttonName(for buttonType: ButtonType, for product: ProductData) -> String {
            
            switch buttonType {
            case .topLeft: return "Пополнить"
                
            case .bottomLeft:
                switch product.productType {
                case .deposit: return "Детали"
                default: return "Реквизиты и выписки"
                }
                
            case .topRight:
                switch product.productType {
                case .loan: return "Управление"
                default: return "Перевести"
                }
                
            case .bottomRight:
                switch product.productType {
                case .card:
                    guard let cardProduct = product as? ProductCardData else {
                        return "Блокировать"
                    }
                    
                    return cardProduct.isBlocked ? "Разблокировать" : "Блокировать"
                    
                case .account: return "Закрыть"
                case .deposit: return "Управление"
                case .loan: return "Погасить досрочно"
                }
            }
        }
        
        func buttonIcon(for buttonType: ButtonType, for product: ProductData) -> Image {
            
            switch buttonType {
            case .topLeft: return .ic24Plus
                
            case .bottomLeft:
                switch product.productType {
                case .deposit: return .ic24Info
                default: return .ic24FileText
                }
                
            case .topRight:
                switch product.productType {
                case .loan: return .ic24Server
                default: return .ic24ArrowUpRight
                }
                
            case .bottomRight:
                switch product.productType {
                case .card:
                    guard let cardProduct = product as? ProductCardData else {
                        return .ic24Lock
                    }
                    
                    return cardProduct.isBlocked ? .ic24Unlock : .ic24Lock
                    
                case .account: return .ic24Lock
                case .deposit: return .ic24Server
                case .loan: return .ic24Clock
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

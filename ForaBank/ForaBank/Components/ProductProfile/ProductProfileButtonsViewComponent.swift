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
            let buttonsTypes = buttonTypes(for: product)
            for button in buttonsTypes {
                
                result.append(.init(id: button.type.rawValue,
                                     icon: button.type.icon,
                                     title: button.type.title,
                                     isEnabled: button.isEnabled,
                                     action: { [weak self] in self?.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: button.type))}))
            }
            
            return result
        }
      
        private func buttonTypes(for product: ProductData) -> [(type: ButtonType, isEnabled: Bool)] {
            
            switch product.productType {
            case .card:
                //TODO: ublock
                return [(.pay, true), (.transfer, true), (.requisites, true), (.block, true)]
                
            case .account:
                return [(.pay, true), (.transfer, true), (.requisites, true), (.close, false)]
                
            case .deposit:
                return [(.pay, true), (.transfer, true), (.details, true), (.control, false)]
                
            case .loan:
                return [(.pay, true), (.control, true), (.requisites, true), (.repay, true)]
            }
        }
    }
}

//MARK: - Types

extension ProductProfileButtonsView.ViewModel {
    
    enum ButtonType: String {
        
        case pay
        case requisites
        case transfer
        case control
        case block
        case unblock
        case repay
        case details
        case close
        
        var title: String {
            
            switch self {
            case .pay: return "Пополнить"
            case .requisites: return "Реквизиты и выписка"
            case .transfer: return "Перевести"
            case .control: return "Управление"
            case .block: return "Блокировать"
            case .unblock: return "Разблокировать"
            case .repay: return "Погасить досрочно"
            case .details: return "Детали"
            case .close: return "Закрыть"
            }
        }
        
        var icon: Image {
            
            switch self {
            case .pay: return .ic24Plus
            case .requisites: return .ic24FileText
            case .transfer: return .ic24ArrowUpRight
            case .control: return .ic24Server
            case .block: return .ic24Lock
            case .unblock: return .ic24Unlock
            case .repay: return .ic24Clock
            case .details: return .ic24Info
            case .close: return .ic24Lock
            }
        }
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

//
//  ProductProfileOptionsPannelViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 04.07.2022.
//

import SwiftUI
import Combine

extension ProductProfileOptionsPannelView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let title: String?
        @Published var buttons: [ButtonIconTextView.ViewModel]
        
        init(title: String? = nil, buttons: [ButtonIconTextView.ViewModel]) {
            
            self.title = title
            self.buttons = buttons
        }
        
        init(title: String? = nil, buttonsTypes: [ProductProfileOptionsPannelView.ViewModel.ButtonType], productType: ProductType) {
            
            self.title = title
            self.buttons = []
            
            for type in buttonsTypes {
                
                buttons.append(buttonViewModel(of: type, productType: productType))
            }
        }
        
        func buttonViewModel(of type: ButtonType, productType: ProductType) -> ButtonIconTextView.ViewModel {
            

            let action: () -> Void = { [weak self] in self?.action.send(ProductProfileOptionsPannelViewModelAction.ButtonTapped(buttonType: type)) }
            
            switch type {
            case .refillFromOtherBank:
                return .init(icon: .init(image: .ic40SBP, style: .original, background: .circle), title: .init(text: "С моего счета в другом банке", style: .bold), orientation: .horizontal, action: action)
                
            case .refillFromOtherProduct:
                return .init(icon: .init(image: .ic24Between, background: .circle), title: .init(text: "Со своего счета", style: .bold), orientation: .horizontal, action: action)

            case .requisites:
                switch productType {
                case .card:
                    return .init(icon: .init(image: .ic24FileText, background: .circle), title: .init(text: "Реквизиты счета карты", style: .bold), orientation: .horizontal, action: action)
                    
                case .account:
                    return .init(icon: .init(image: .ic24FileText, background: .circle), title: .init(text: "Реквизиты счета", style: .bold), orientation: .horizontal, action: action)
                    
                case .deposit:
                    return .init(icon: .init(image: .ic24FileText, background: .circle), title: .init(text: "Реквизиты счета депозита", style: .bold), orientation: .horizontal, action: action)
                    
                case .loan:
                    return .init(icon: .init(image: .ic24FileText, background: .circle), title: .init(text: "Реквизиты счета кредита", style: .bold), orientation: .horizontal, action: action)
                }
                
            case .statement:
                switch productType {
                case .card:
                    return .init(icon: .init(image: .ic24FileHash, background: .circle), title: .init(text: "Выписка по счету карты", style: .bold), orientation: .horizontal, action: action)
                    
                case .account:
                    return .init(icon: .init(image: .ic24FileHash, background: .circle), title: .init(text: "Выписка по счету", style: .bold), orientation: .horizontal, action: action)
                    
                case .deposit:
                    return .init(icon: .init(image: .ic24FileHash, background: .circle), title: .init(text: "Выписка по счету депозита", style: .bold), orientation: .horizontal, action: action)
                    
                case .loan:
                    return .init(icon: .init(image: .ic24FileHash, background: .circle), title: .init(text: "Выписка по счету кредита", style: .bold), orientation: .horizontal, action: action)
                }
                
            case .info:
                switch productType {
                case .card:
                    return .init(icon: .init(image: .ic24Info, background: .circle), title: .init(text: "Информация по счету карты", style: .bold), orientation: .horizontal, action: action)

                case .account:
                    return .init(icon: .init(image: .ic24Info, background: .circle), title: .init(text: "Информация по счету", style: .bold), orientation: .horizontal, action: action)
                    
                case .deposit:
                    return .init(icon: .init(image: .ic24Info, background: .circle), title: .init(text: "Информация по счету депозита", style: .bold), orientation: .horizontal, action: action)
                    
                case .loan:
                    return .init(icon: .init(image: .ic24Info, background: .circle), title: .init(text: "Информация по счету кредита", style: .bold), orientation: .horizontal, action: action)
                }
                
            case .conditions:
                switch productType {
                case .card:
                    return .init(icon: .init(image: .ic24File, background: .circle), title: .init(text: "Условия по счету карты", style: .bold), orientation: .horizontal, action: action)

                case .account:
                    return .init(icon: .init(image: .ic24File, background: .circle), title: .init(text: "Условия по счету", style: .bold), orientation: .horizontal, action: action)
                    
                case .deposit:
                    return .init(icon: .init(image: .ic24File, background: .circle), title: .init(text: "Условия по счету депозита", style: .bold), orientation: .horizontal, action: action)
                    
                case .loan:
                    return .init(icon: .init(image: .ic24File, background: .circle), title: .init(text: "Условия по счету кредита", style: .bold), orientation: .horizontal, action: action)
                }
                
            case .closeDeposit:
                return .init(icon: .init(image: .ic24Close, background: .circle), title: .init(text: "Закрыть депозит", style: .bold), orientation: .horizontal, action: action)
            }
        }
        
        enum ButtonType {
            
            case refillFromOtherBank
            case refillFromOtherProduct
            case requisites
            case statement
            case info
            case conditions
            case closeDeposit
        }
    }
}

//MARK: - Action

enum ProductProfileOptionsPannelViewModelAction {
    
    struct ButtonTapped: Action {
        
        let buttonType: ProductProfileOptionsPannelView.ViewModel.ButtonType
    }
}

struct ProductProfileOptionsPannelView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 24) {
                
                if let title = viewModel.title {
                    
                    Text(title)
                        .font(.textH3SB18240())
                        .foregroundColor(.textSecondary)
                }
                
                ForEach(viewModel.buttons) { buttonViewModel in
                    
                    ButtonIconTextView(viewModel: buttonViewModel)
                }
            }
            
            Spacer()
        }
    }
}

struct ProductProfileOptionsPannelViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProductProfileOptionsPannelView(viewModel: .sample)
            .padding(.horizontal, 20)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension ProductProfileOptionsPannelView.ViewModel {
    
    static let sample = ProductProfileOptionsPannelView.ViewModel(title: "Пополнить", buttons: [.init(icon: .init(image: .ic40SBP, style: .original, background: .circle), title: .init(text: "С моего счета в другом банке", style: .bold), orientation: .horizontal, action: {}), .init(icon: .init(image: .ic24Between, background: .circle), title: .init(text: "Со своего счета", style: .bold), orientation: .horizontal, action: {}), .init(icon: .init(image: .ic24CreditCard, background: .circle), title: .init(text: "С карты другого банка", style: .bold), orientation: .horizontal, action: {})])

}

//
//  ProductProfileButtonView.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileButtonView {
    
    class ViewModel: Identifiable, Hashable, ObservableObject {
            
        let action: PassthroughSubject<Action, Never> = .init()

        let id = UUID()
        let title: TitleType
        let image: Image
        let state: Bool?

        internal init(title: TitleType, image: Image, state: Bool? = true) {
            
            self.title = title
            self.image = image
            self.state = state
            self.action.send(ProductProfileViewModelAction.CustomName())
        }
        
        enum TitleType: String {
            
            case pay = "Пополнить"
            case requisites = "Реквизиты и выписка"
            case transfer = "Перевести"
            case control = "Управление"
            case block = "Блокировать"
            case unblock = "Разблокировать"
            case repay = "Погасить досрочно"
            case details = "Детали"
            case close = "Закрыть"
        }
    }
}

extension ProductProfileButtonView.ViewModel {
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }

    static func == (lhs: ProductProfileButtonView.ViewModel, rhs: ProductProfileButtonView.ViewModel) -> Bool {
        
        return lhs.id == rhs.id
    }
}

//MARK: - View

struct ProductProfileButtonView: View {
    
    @ObservedObject var viewModel: ProductProfileButtonView.ViewModel
    
    var body: some View {
        
        if viewModel.state == true {
         
            Button {
                
                viewModel.action.send(ProductProfileViewModelAction.Dismiss())
                
            } label: {
                
                HStack(spacing: 12) {
                    
                    viewModel.image
                        .foregroundColor(.iconBlack)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.title.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.buttonBlack)
                }
                .frame(width: 164, height: 48, alignment: .leading)
                .padding(.leading, 12)
            }
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(8)
            
        } else {
            
            Button {
                viewModel.action.send(ProductProfileViewModelAction.BlockProduct(productId: 1))

            } label: {
                
                HStack(spacing: 12) {
                    
                    viewModel.image
                        .foregroundColor(.iconBlack)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.title.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.buttonBlack)
                }
                .frame(width: 164, height: 48, alignment: .leading)
                .padding(.leading, 12)
            }
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(8)
            .disabled(true)
            .opacity(0.3)
        }
    }
}

//MARK: - Preview

struct ProfileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ProductProfileButtonView(viewModel: .ussualyButton)
                .previewLayout(.fixed(width: 200, height: 100))

            ProductProfileButtonView(viewModel: .disableButton)
                .previewLayout(.fixed(width: 200, height: 100))
            
            ProductProfileButtonView(viewModel: .requisitsButton)
                .previewLayout(.fixed(width: 200, height: 100))
            
            ProductProfileButtonView(viewModel: .transferButton)
                .previewLayout(.fixed(width: 200, height: 100))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileButtonView.ViewModel {
    
    static let ussualyButton = ProductProfileButtonView.ViewModel(title: .pay, image: Image.ic24Plus, state: true)
    
    static let disableButton = ProductProfileButtonView.ViewModel(title: .block, image: Image.ic24Lock, state: false)
    
    static let requisitsButton = ProductProfileButtonView.ViewModel(title: .requisites, image: Image.ic24File, state: false)
    
    static let transferButton = ProductProfileButtonView.ViewModel(title: .transfer, image: Image.ic24ArrowUpRight)
}


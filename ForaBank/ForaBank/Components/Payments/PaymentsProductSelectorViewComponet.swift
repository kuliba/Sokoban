//
//  PaymentsProductSelectorViewComponet.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2022.
//

import SwiftUI
import Combine

//MARK: - View Model

extension PaymentsProductSelectorView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var categories: OptionSelectorView.ViewModel
        @Published var products: [ProductView.ViewModel]
        
        init(categories: OptionSelectorView.ViewModel, products: [ProductView.ViewModel]) {
            
            self.categories = categories
            self.products = products
        }
        
        init(_ model: Model) {
            
            self.categories = .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета"), .init(id: "2", name: "Вклады")], selected: "0", style: .productsSmall)
            self.products = []
            
            let classicSmall = ProductView.ViewModel(id: "2", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardClassic, image: nil), size: .small), isUpdating: false,  productType: .card, action: {[weak self] in self?.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: 2))})
            
            let classicSmall1 = ProductView.ViewModel(id: "3", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardRIO, image: nil), size: .small), isUpdating: false,  productType: .card, action: {[weak self] in self?.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: 2))})
            
            let classicSmall2 = ProductView.ViewModel(id: "4", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardAccount, image: nil), size: .small), isUpdating: false,  productType: .card, action: {[weak self] in self?.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: 2))})
            
            let classicSmall3 = ProductView.ViewModel(id: "5", header: .init(logo: .ic24LogoForaColor, number: "7854", period: nil), name: "Classic", footer: .init(balance: "170 897 ₽", paymentSystem: Image("Payment System Mastercard")), statusAction: nil, appearance: .init(textColor: .white, background: .init(color: .cardGold, image: nil), size: .small), isUpdating: false,  productType: .card, action: {[weak self] in self?.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: 2))})
            
            self.products = [classicSmall, classicSmall1, classicSmall2, classicSmall3]
        }
    }
    
    enum ViewModelAction {
        
        struct SelectedProduct: Action {
            
            let productId: Int
        }
    }
}

//MARK: - View

struct PaymentsProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            OptionSelectorView(viewModel: viewModel.categories)
                .frame(height: 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.products) { productViewModel in
                        
                        ProductView(viewModel: productViewModel)
                            .frame(width: 112, height: 72)
                            .onTapGesture {
                                
                                viewModel.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: productViewModel.productId))
                            }
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsProductSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsProductSelectorView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

extension PaymentsProductSelectorView.ViewModel {
    
    
    static let sample = PaymentsProductSelectorView.ViewModel(categories: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета"), .init(id: "2", name: "Вклады")], selected: "0", style: .productsSmall), products: [.classicSmall, .accountSmall])
}

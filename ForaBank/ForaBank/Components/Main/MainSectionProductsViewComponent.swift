//
//  MainSectionProductsViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension MainSectionProductsView {
    
    class ViewModel: MainSectionCollapsableViewModel {
        
        let title: String
        @Published var productsTypeSelector: OptionSelectorViewModel?
        @Published var products: [[MainCardComponentView.ViewModel]]
        
        internal init(title: String, productsTypeSelector: OptionSelectorViewModel?, products: [[MainCardComponentView.ViewModel]], isCollapsed: Bool) {
            
            self.title = title
            self.products = products
            if let productsTypeSelector = productsTypeSelector {
                
                self.productsTypeSelector = productsTypeSelector
            }
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {

            HeaderView(viewModel: viewModel)
            
            if let productSelectorViewModel = viewModel.productsTypeSelector {
                
                OptionSelectorView(viewModel: productSelectorViewModel)
                    .frame(height: 24)
                    .padding(.top, 12)

            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                            
                        HStack {

                            ForEach(viewModel.products, id: \.self) { products in
                                                                    
                                HStack(alignment: .center) {

                                        ForEach(products.indices) { index in
                                        
                                            if products[index].style == .additional {
                                                
                                                MainCardComponentView(viewModel: products[index])
                                                    .frame(height: 104)
                                                    .id(index)
                                                
                                            } else {
                                                
                                                MainCardComponentView(viewModel: products[index])
                                                    .frame(width: 164, height: 104)
                                                    .id(index)
                                            }
                              
                                        }  

                                            Divider().background(Color(hex: "F6F6F7"))
                                                .frame(width: 1, height: 48, alignment: .center)
                                    }
                                }
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
            }
            
            Spacer()
        }
    }
    
    struct HeaderView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            
            HStack(alignment: .center) {
                
                Text(viewModel.title)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                
                Button {
                    
                } label: {
                        
                    Image.ic24ChevronDown
                        .renderingMode(.original)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button {
                    
                } label: {

                    ZStack{
                        Image.ic24MoreHorizontal
                            .renderingMode(.original)
                    }
                    .frame(width: 32, height: 32, alignment: .center)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(90)

                }
            }
            .padding([.leading, .trailing], 20)
            .padding(.bottom, 8)
        }
    }
}

//MARK: - Preview

struct MainBlockProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionProductsView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
        
}

//MARK: - Preview Content

extension MainSectionProductsView.ViewModel {
    
    static let sample = MainSectionProductsView.ViewModel(title: "Мои продукты", productsTypeSelector: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета")], selected: "0", style: .products), products: [[
        .init(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .notActivated, backgroundImage: Image(""), productType: .card, style: .main, kind: .card),
        .init(logo: .ic24LogoForaColor, name: "Текущий счет", balance: "170 897 ₽", fontColor: .white, cardNumber: "1234", backgroundColor: .cardAccount, paymentSystem:  nil, status: .active, backgroundImage: Image(""), productType: .card, style: .additional, kind: .want)
    ], [
        .init(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .notActivated, backgroundImage: Image(""), productType: .card, style: .main, kind: .card),
        .init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image(""), productType: .card, style: .main, kind: .card),
        .init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .active, backgroundImage: Image(""), productType: .card, style: .main, kind: .card),
        .init(logo: .ic24LogoForaColor, name: "Текущий счет", balance: "170 897 ₽", fontColor: .white, cardNumber: "1234", backgroundColor: .cardAccount, paymentSystem:  nil, status: .active, backgroundImage: Image(""), productType: .card, style: .main, kind: .card),
        .init(logo: .ic24LogoForaColor, name: "+5", balance: "170 897 ₽", fontColor: .white, cardNumber: "1234", backgroundColor: .cardAccount, paymentSystem:  nil, status: .active, backgroundImage: Image(""), productType: .card, style: .additional, kind: .more)
    ]], isCollapsed: false)
    
}

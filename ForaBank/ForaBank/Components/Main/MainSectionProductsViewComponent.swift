//
//  MainSectionProductsViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainSectionProductsView {
    
    class ViewModel: ObservableObject {
        
        let title: String
        @Published var productsTypeSelector: MainBlockProductSelectorViewModel?
        @Published var products: [MainCardComponentView.ViewModel]
        
        init(title: String, productsTypeSelector: MainBlockProductSelectorViewModel?, products: [MainCardComponentView.ViewModel]) {
            
            self.title = title
            self.products = products
            
            if let productsTypeSelector = productsTypeSelector {
                
                self.productsTypeSelector = productsTypeSelector
            } else {
                
                self.productsTypeSelector = nil
            }
            
        }
    }

}

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {

            HeaderView(viewModel: viewModel)
            
            if let selector = viewModel.productsTypeSelector {
                
                MainBlockProductSelectorView(viewModel: selector)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack (spacing: 8) {
                    
                    ForEach(viewModel.products) { product in
                        
                        MainCardComponentView(viewModel: product)
                            .padding(.bottom, 32)
                    }
                }
                .padding(.leading, 20)
            }
            .padding(.top, 16)
            
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
        
        NavigationView {

            MainSectionProductsView(viewModel: .init(title: "Мои продукты", productsTypeSelector: nil, products: [
            .init(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .notActivated, backgroundImage: Image("")),
            .init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image("")),
            .init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .active, backgroundImage: Image(""))
        ]))
        }
    }
        
}

//MARK: - Preview Content

extension MainSectionProductsView {
    
}

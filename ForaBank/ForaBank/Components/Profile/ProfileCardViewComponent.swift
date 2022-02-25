//
//  ProfileCardViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 24.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ProfileCardViewComponent {
    
    class ViewModel: Identifiable, ObservableObject {
        
        @Published var product: MainCardComponentView.ViewModel
        @Published var products: [MainCardComponentView.ViewModel]
        @Published var selected: Option.ID

        init( product: MainCardComponentView.ViewModel, products: [MainCardComponentView.ViewModel], selected: Option.ID) {
            
            self.product = product
            self.products = products
            self.selected = selected
        }
    }
}

extension ProfileCardViewComponent {
        
    struct MiniCardViewModel {
        
        let background: Image
    }
}


struct ProfileCardViewComponent: View {
    
    @ObservedObject var viewModel: ProfileCardViewComponent.ViewModel

    public var tabBar: some View {
        
        HStack(alignment: .center, spacing: 16) {
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(viewModel.products) { product in
                    MiniCardView(viewModel: MiniCardViewModel( background: Image("card_sample", bundle: nil)), isSelected: product.id == viewModel.product.id)

                }
            }
            
            Spacer()
        }
    }
    
    var body: some View {
            
        VStack {
            
            ZStack(alignment: .top) {
                
                viewModel.product.backgroundColor
                    .frame(height: 170, alignment: .top)
                    .edgesIgnoringSafeArea(.top)
            
                VStack(spacing: 15) {
                    if #available(iOS 14.0, *) {

                        tabBar
                            .padding(.top, 20)
                        
                        TabView {
                            
                            ForEach(viewModel.products) { product in
                                
                                if product.productType == .deposit {
                                        
                                        MainCardComponentView(viewModel: product)
                                            .frame(width: 228, height: 160)

                                } else {
                                    
                                        MainCardComponentView(viewModel: product)
                                        .frame(width: 268, height: 160, alignment: .top)

                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame( height: 160, alignment: .top)
                        
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
    
    
}

extension ProfileCardViewComponent {
    
    struct MiniCardView: View {
        
        let viewModel: ProfileCardViewComponent.MiniCardViewModel
        let isSelected: Bool
        
        var body: some View {
            
                
                Button {
                    
                } label: {
                    
                    if isSelected {
                        
                        HStack(spacing: 6) {
                            
                            viewModel.background
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                        .padding(.all, 14)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(90)
                        
                    } else {
                        
                        HStack(spacing: 6) {
                            
                            viewModel.background
                                .frame(width: 24, height: 24, alignment: .center)
                                .opacity(0.4)
                        }
                        .padding(.all, 14)
                }
            }
        }
    }
}

struct ProfileCardViewComponent_Previews: PreviewProvider {
    static var previews: some View {
//        ProfileCardViewComponent(viewModel: .init(product: .init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image("card_sample"), productType: .account, style: .profile), products:  [.init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image("card_sample"), productType: .account, style: .profile), .init(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .active, backgroundImage: Image("card_sample"), productType: .deposit, style: .profile), .notActivateProfile]))
        ProfileCardViewComponent(viewModel: .init(product: .init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image("card_sample"), productType: .account, style: .profile), products:  [.init(logo: .ic24LogoForaColor, name: "Infinity", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardInfinite, paymentSystem:  Image(uiImage: UIImage(named: "card_mastercard_logo")!), status: .blocked, backgroundImage: Image("card_sample"), productType: .account, style: .profile), .init(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .active, backgroundImage: Image("card_sample"), productType: .deposit, style: .profile), .notActivateProfile], selected: "1"))
    }
}

extension ProfileCardViewComponent.ViewModel {

    static let notActivateProfile = MainCardComponentView.ViewModel(logo: .ic24LogoForaColor, name: "Classic", balance: "170 897 ₽", fontColor: .white, cardNumber: "7854", backgroundColor: .cardClassic, paymentSystem:  Image(uiImage: UIImage(named: "card_visa_logo")!), status: .notActivated, backgroundImage: Image("card_sample"), productType: .card, style: .profile)
}

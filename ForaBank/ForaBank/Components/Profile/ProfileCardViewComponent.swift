//
//  ProfileCardViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 24.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ProfileCardViewComponent {
    
    class ViewModel: ObservableObject {
        
        @Published var products: [ProductView.ViewModel]

        init( products: [ProductView.ViewModel]) {
            
            self.products = products
        }
    }
}

extension ProfileCardViewComponent {
        
    struct MiniCardViewModel {
        
        let background: Image?
        let product: ProductView.ViewModel
        let action: (ProductView.ViewModel) -> Void
    }
}

struct ProfileCardViewComponent: View {
    
    @ObservedObject var viewModel: ProfileCardViewComponent.ViewModel
    @State var currentItem: ProductView.ViewModel

    public var tabBar: some View {
        
        HStack(alignment: .center, spacing: 8) {
                
                ForEach(viewModel.products) { product in

                    if let backgroundImage = product.appearance.background.image {
                        
                        MiniCardView(viewModel: MiniCardViewModel( background: backgroundImage, product: product, action: { productItem in
                            currentItem = productItem
                            }), isSelected: currentItem.id == product.id)
                        
              
                    } else {
                        
                        MiniCardView(viewModel: MiniCardViewModel( background: nil, product: product, action: { productItem in
                            currentItem = productItem
                            }), isSelected: currentItem.id == product.id)
                    }
            }
        }
    }
    
    var body: some View {
            
        VStack {
            
            ZStack(alignment: .top) {
                
//                currentItem.appearance.background.color
//                    .frame(height: 170, alignment: .top)
//                    .edgesIgnoringSafeArea(.top)
//                    .brightness(-0.2)
            
                VStack(spacing: 15) {
                    if #available(iOS 14.0, *) {

                        tabBar
                        
                        TabView(selection: $currentItem) {
                            
                            ForEach(viewModel.products) { product in
                                
                                if product.productType == .deposit {
                                        
                                    ProductView(viewModel: product)
                                            .frame(width: 228, height: 160)
                                            .tag(product)

                                } else {

                                    ProductView(viewModel: product)
                                        .frame(width: 268, height: 160, alignment: .top)
                                        .tag(product)

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
                    
                    viewModel.action(viewModel.product)
                    
                } label: {
                    
                    if isSelected {
                        
                        HStack(spacing: 6) {
                            
                            if let backgroundImage =                             viewModel.product.appearance.background.image {
                                
                                backgroundImage
                                    .resizable()
                                    .frame(width: 32, height: 24, alignment: .center)
                                    .cornerRadius(3)

                            } else {
                                
                                viewModel.product.appearance.background.color
                                    .frame(width: 32, height: 24, alignment: .center)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(width: 32, height: 32, alignment: .center)
                        .padding(.all, 14)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(90)
                        
                    } else {
                        
                        HStack(spacing: 6) {
                            
                            if let backgroundImage =                             viewModel.product.appearance.background.image {
                                
                                backgroundImage
                                    .resizable()
                                    .frame(width: 32, height: 24, alignment: .center)
                                    .cornerRadius(3)                              .opacity(0.3)

                                
                            } else {
                                
                                viewModel.product.appearance.background.color
                                    .frame(width: 32, height: 24, alignment: .center)
                                    .cornerRadius(3)
                                    .opacity(0.3)

                            }
                        }
                        .padding(.all, 14)
                }
            }
        }
    }
}

struct ProfileCardViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCardViewComponent(viewModel: .init(products: [.blockedProfile ,.classicProfile, .accountProfile, .notActivateProfile]), currentItem: ProductView.ViewModel.classicProfile)
    }
}

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
        @State var product: ProductView.ViewModel
        @Published var moreButton: Bool
        
        init( products: [ProductView.ViewModel], product: ProductView.ViewModel, moreButton: Bool) {
            
            self.products = products.filter({$0.productType == product.productType})
            self.moreButton = moreButton
            self.product = product
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
    
    public var TabBar: some View {
        
        HStack(alignment: .center, spacing: 8) {
            
            ForEach(viewModel.products) { product in
                
                if let backgroundImage = product.appearance.background.image {
                    
                    MiniCardView(viewModel: MiniCardViewModel( background: backgroundImage, product: product, action: { productItem in
                        viewModel.product = productItem
                    }), isSelected: viewModel.product.id == product.id)
                    
                    
                } else {
                    
                    MiniCardView(viewModel: MiniCardViewModel( background: nil, product: product, action: { productItem in
                        viewModel.product = productItem
                    }), isSelected: viewModel.product.id == product.id)
                }
            }
            
            if viewModel.moreButton {
                
                Button {
                    
                } label: {
                    Image.ic16MoreHorizontal
                        .foregroundColor(.black)
                }
                .frame(width: 32, height: 22, alignment: .center)
                .background(Color.white)
                .cornerRadius(3.0)
            }
        }
    }
    
    var body: some View {
        
        VStack {
            
            ZStack(alignment: .top) {
                
                VStack(spacing: 15) {
                    if #available(iOS 14.0, *) {
                        
                        TabBar
                        
                        TabView(selection: $viewModel.product) {
                            
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
        ProfileCardViewComponent(viewModel: .init(products: [.blockedProfile, .classicProfile, .accountProfile, .notActivateProfile, .accountSmall], product: .classicProfile, moreButton: true))
            .previewLayout(.fixed(width: 400, height: 500))
            .background(Color.orange)
    }
}

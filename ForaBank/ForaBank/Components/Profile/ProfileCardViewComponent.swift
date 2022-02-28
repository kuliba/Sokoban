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
        
        @Published var products: [MainCardComponentView.ViewModel]

        init( products: [MainCardComponentView.ViewModel]) {
            
            self.products = products
        }
    }
}

extension ProfileCardViewComponent {
        
    struct MiniCardViewModel {
        
        let background: Image
        let product: MainCardComponentView.ViewModel
        let action: (MainCardComponentView.ViewModel) -> Void
    }
}


struct ProfileCardViewComponent: View {
    
    @ObservedObject var viewModel: ProfileCardViewComponent.ViewModel
    @State var currentItem: MainCardComponentView.ViewModel

    public var tabBar: some View {
        
        HStack(alignment: .center, spacing: 16) {
            
            Spacer()
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.products) { product in
                        
                    MiniCardView(viewModel: MiniCardViewModel( background: product.backgroundImage, product: product, action: { productItem in
                        currentItem = productItem
                    }), isSelected: currentItem == product)

                }
            }
            
            Spacer()
        }
    }
    
    var body: some View {
            
        VStack {
            
            ZStack(alignment: .top) {
                
                currentItem.backgroundColor
                    .frame(height: 170, alignment: .top)
                    .edgesIgnoringSafeArea(.top)
            
                VStack(spacing: 15) {
                    if #available(iOS 14.0, *) {

                        tabBar
                            .padding(.top, 20)
                        
                        TabView(selection: $currentItem) {
                            
                            ForEach(viewModel.products) { product in
                                
                                if product.productType == .deposit {
                                        
                                        MainCardComponentView(viewModel: product)
                                            .frame(width: 228, height: 160)
                                            .tag(product)

                                } else {
                                    
                                        MainCardComponentView(viewModel: product)
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
        ProfileCardViewComponent(viewModel: .init(products: [.blockedProfile ,.classicProfile, .accountProfile, .notActivateProfile]), currentItem: MainCardComponentView.ViewModel.classicProfile)
    }
}

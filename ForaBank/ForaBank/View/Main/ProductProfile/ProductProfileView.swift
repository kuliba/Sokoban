//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import SwiftUI
import Introspect

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
    
    @State private var tabBarController: UITabBarController?
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                
                ZStack {
                    
                    GeometryReader { geometry in
                        
                        ZStack {
                            
                            viewModel.product.product.appearance.background.color.contrast(0.8)
                                .frame(width: geometry.size.width, height: 150)
                                .clipped()
                        }
                    }
                    
                    VStack(spacing: 0) {
                        
                        ProductProfileCardView(viewModel: viewModel.product)
                            .padding(.top, 20)
                        
                        VStack(spacing: 32) {
                            
                            ProductProfileButtonsSectionView(viewModel: .init(kind: viewModel.product.product.productType))
                            
                            if let detailAccount = viewModel.detail {
                                
                                ProductProfileAccountDetailView(viewModel: detailAccount)
                                    .padding(.horizontal, 20)
                            }
                            
                            if let historyViewModel = viewModel.history {
                                
                                ProductProfileHistoryView(viewModel: historyViewModel)
                            }
                        }
                    }
                }
                .padding(.top, 35)
                .edgesIgnoringSafeArea(.top)
            }
            
            ZStack {
                
                viewModel.product.product.appearance.background.color.contrast(0.8)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 50)
                StatusView(viewModel: viewModel.statusBar)
            }
        }
        .navigationBarHidden(true)
        .introspectTabBarController(customize: { tabBarController in
            
            self.tabBarController = tabBarController
            tabBarController.tabBar.isHidden = true
            UIView.transition(with: tabBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        })
        .onDisappear {
            
            if let tabBarController = tabBarController {
                
                tabBarController.tabBar.isHidden = false
                UIView.transition(with: tabBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
            }
        }
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
    }
}

//MARK: - Internal Views

extension ProductProfileView {
    
    struct StatusView: View {
        
        @ObservedObject var viewModel: ProductProfileViewModel.StatusBarViewModel
        
        var body: some View {
            
            HStack {
                
                Button(action: viewModel.backButton.action) {
                    
                    viewModel.backButton.icon
                        .foregroundColor(viewModel.color)
                }

                Spacer()
                
                VStack {
                    
                    Text(viewModel.title)
                        .font(.textH3M18240())
                        .foregroundColor(viewModel.color)
                    
                    Text(viewModel.subtitle)
                        .font(.textBodySR12160())
                        .foregroundColor(viewModel.color)
                }
                
                Spacer()
                
                if let actionButtonViewModel = viewModel.actionButton {
                    
                    Button(action: actionButtonViewModel.action) {
                        
                        actionButtonViewModel.icon
                            .foregroundColor(viewModel.color)
                    }
                    
                } else {
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 20)
            .background(Color.clear)
        }
    }
}

//MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileView(viewModel: .sample)
            ProductProfileView(viewModel: .sampleCard)
            
            ProductProfileView.StatusView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 48))
            ProductProfileView.StatusView(viewModel: .sampleNoActionButton)
                .previewLayout(.fixed(width: 375, height: 48))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileViewModel {
    
    static let sample = ProductProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .depositProfile], product: .depositProfile, model: .emptyMock), model: .emptyMock, dismissAction: {})
    
    static let sampleCard = ProductProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .blockedProfile, .depositProfile], product: .blockedProfile, model: .emptyMock), model: .emptyMock, dismissAction: {})
}

extension ProductProfileViewModel.StatusBarViewModel {
    
    static let sample = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: {}), title: "Platinum", subtitle: "· 4329", actionButton: .init(icon: .ic24Edit2, action: {}), color: .iconBlack)
    
    static let sampleNoActionButton = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: {}), title: "Platinum", subtitle: "· 4329", actionButton: nil, color: .iconBlack)
}



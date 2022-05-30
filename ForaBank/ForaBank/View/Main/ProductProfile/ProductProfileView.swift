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
            
            ScrollView {
                
                GeometryReader { geometry in
                    
                    ZStack {
                        
                        if geometry.frame(in: .global).minY <= 0 {
                            
                            viewModel.accentColor.contrast(0.5)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .offset(y: geometry.frame(in: .global).minY / 9)
                                .clipped()
                            
                        } else {
                            
                            viewModel.accentColor.contrast(0.5)
                                .frame(width: geometry.size.width, height: geometry.size.height + geometry.frame(in: .global).minY)
                                .clipped()
                                .offset(y: -geometry.frame(in: .global).minY)
                        }
                    }
                }
                .frame(height: 204)
       
                VStack(spacing: 0) {
                    
                    ProductProfileCardView(viewModel: viewModel.product)
                    
                    VStack(spacing: 32) {
                        
                        ProductProfileButtonsSectionView(viewModel: viewModel.selector)
                        
                        if let detailAccount = viewModel.detail {
                            
                            ProductProfileAccountDetailView(viewModel: detailAccount)
                                .padding(.horizontal, 20)
                        }
                        
                        if let historyViewModel = viewModel.history {
                            
                            ProductProfileHistoryView(viewModel: historyViewModel)
                        }
                    }
                }
                .offset(x: 0, y: -156)
            }
            
            StatusView(viewModel: viewModel.statusBar)
                .frame(height: 48)
                .background(viewModel.accentColor.contrast(0.5).edgesIgnoringSafeArea(.top))
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
            
            if let detailViewModel = viewModel.detailOperation {
                
                ZStack(alignment: .bottom) {
                    
                     VStack(spacing: 0) {
                         
                         OperationDetailView(viewModel: detailViewModel)
                     }
                     .layoutPriority(1)
                     .frame(alignment: .top)
                     .animation(.linear(duration: 0.3))
                     .shadow(color: .black, radius: 0.2, x: 10, y: 10)
                 }.edgesIgnoringSafeArea(.all)
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
 
            ProductProfileView.StatusView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 48))
            ProductProfileView.StatusView(viewModel: .sampleNoActionButton)
                .previewLayout(.fixed(width: 375, height: 48))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileViewModel {
    
    static let sample = ProductProfileViewModel(statusBar: .sample, product: .sample, selector: .sample, detail: .sample, history: .sampleHistory)
}

extension ProductProfileViewModel.StatusBarViewModel {
    
    static let sample = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: {}), title: "Platinum", subtitle: "· 4329", actionButton: .init(icon: .ic24Edit2, action: {}), color: .iconBlack)
    
    static let sampleNoActionButton = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: {}), title: "Platinum", subtitle: "· 4329", actionButton: nil, color: .iconBlack)
}



//
//  ProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                
                ZStack {
                    
                    GeometryReader { geometry in
                        
                        ZStack {
                            
                            viewModel.productViewModel.product.appearance.background.color.contrast(0.8)
                                .frame(width: geometry.size.width, height: 150)
                                .clipped()
                        }
                    }
                    
                    VStack(spacing: 0) {
                        
                        ProfileCardViewComponent(viewModel: viewModel.productViewModel)
                            .padding(.top, 20)
                        
                        VStack(spacing: 32) {
                            
                            ProfileButtonsSectionView(viewModel: .init(kind: viewModel.productViewModel.product.productType))
                            
                            if let detailAccount = viewModel.detailAccountViewModel {
                                
                                DetailAccountViewComponent(viewModel: detailAccount)
                                    .padding(.horizontal, 20)
                            }
                            
                            if let historyViewModel = viewModel.historyViewModel {
                                
                                HistoryViewComponent(viewModel: historyViewModel)
                            }
                        }
                    }
                }
                .padding(.top, 35)
                .edgesIgnoringSafeArea(.top)
            }
            
            ZStack {
                
                viewModel.productViewModel.product.appearance.background.color.contrast(0.8)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 50)
                HeaderView(viewModel: viewModel)
            }
        }
        .navigationBarHidden(true)
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
    }
    
    struct HeaderView: View {
        
        @ObservedObject var viewModel: ProfileViewModel
        
        var body: some View {
            HStack {
                
                Button {
                    
                    viewModel.dismissAction()
                    
                } label: {
                    
                    Image.ic24ChevronLeft
                        .foregroundColor(viewModel.productViewModel.product.appearance.textColor)
                }
                
                Spacer()
                
                VStack {
                    
                    Text(viewModel.productViewModel.product.name)
                        .foregroundColor(viewModel.productViewModel.product.appearance.textColor)
                    
                    if let number = viewModel.productViewModel.product.header.number {
                        
                        Text(number)
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.productViewModel.product.appearance.textColor)
                    }
                }
                
                Spacer()
                
                if viewModel.productViewModel.product.productType != .loan || viewModel.productViewModel.product.productType != .deposit {
                    
                    Button {
                        
                        viewModel.action.send(ProductProfileViewModelAction.CustomName())
                        
                    } label: {
                        
                        Image.ic24Edit2
                            .foregroundColor(viewModel.productViewModel.product.appearance.textColor)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .background(Color.clear)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProfileView(viewModel: .sample)
        
        ProfileView(viewModel: .sampleCard)
    }
}


extension ProfileViewModel {
    
    static let sample = ProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .depositProfile], product: .depositProfile, model: .emptyMock), model: .emptyMock)
    
    static let sampleCard = ProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .blockedProfile, .depositProfile], product: .blockedProfile, model: .emptyMock), model: .emptyMock)
}


//
//  MainView.swift
//  ForaBank
//
//  Created by Max Gribov on 05.03.2022.
//

import SwiftUI
import ScrollViewProxy

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.isRefreshing == true {
                    
                    RefreshView()
                }
                
                HeaderView()
                
                ScrollView(showsIndicators: false) {
                    
                    ScrollViewReader { proxy in
                        
                        VStack(spacing: 20) {
                            
                            ForEach(viewModel.sections) { section in
                                
                                switch section {
                                case let productsSectionViewModel as MainSectionProductsView.ViewModel:
                                    MainSectionProductsView(viewModel: productsSectionViewModel)
                                    
                                case let fastOperationViewModel as MainSectionFastOperationView.ViewModel:
                                    MainSectionFastOperationView(viewModel: fastOperationViewModel)
                                    
                                case let promoViewModel  as MainSectionPromoView.ViewModel:
                                    MainSectionPromoView(viewModel: promoViewModel)
                                    
                                case let currencyViewModel as MainSectionCurrencyView.ViewModel:
                                    MainSectionCurrencyView(viewModel: currencyViewModel)
                                    
                                case let openProductViewModel as MainSectionOpenProductView.ViewModel:
                                    MainSectionOpenProductView(viewModel: openProductViewModel)
                                    
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            
        }
    }
    
    struct HeaderView: View {
        
        var body: some View {
            
            HStack {
                
                ZStack(alignment: .topTrailing) {
                    
                    ZStack(alignment: .center) {
                        
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.bGIconGrayLightest)
                        
                        Image.ic24User
                            .foregroundColor(Color.gray)
                    }
                    
                    ZStack(alignment: .center) {
                        
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.white)
                            .frame(alignment: .topTrailing)
                        
                        Image.ic64ForaColor
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                    .padding(.top, -4)
                    .padding(.trailing, -8)
                }
                
                Text("Name")
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image.ic24Search
                        .foregroundColor(.iconBlack)
                }
                
                Button {
                    
                } label: {
                    Image.ic24Bell
                        .foregroundColor(.iconBlack)
                }
                
            }
            .padding(.horizontal, 20)
        }
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet {
            case .productProfile(let productProfileViewModel):
                ProfileView(viewModel: productProfileViewModel)
                
            case .userAccount(let userAccountViewModel):
                UserAccountView(viewModel: userAccountViewModel)
                
            case .messages(let messagesHistoryViewModel):
                MessagesHistoryView(viewModel: messagesHistoryViewModel)
                
            case .myProducts(let myProductsViewModel):
                MyProductsView(viewModel: myProductsViewModel)
            }
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading:
                                UserAccountButton(viewModel: viewModel.userAccountButton),
                            trailing:
                                HStack {
                                    ForEach(viewModel.navButtonsRight) { navButtonViewModel in
                                        
                                        NavBarButton(viewModel: navButtonViewModel)
                                    }
                                }
        )
    }
}

extension MainView {
    
    struct UserAccountButton: View {
    
        @ObservedObject var viewModel: MainViewModel.UserAccountButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
               
                HStack {
                    
                    ZStack {
                        
                        ZStack {
                            
                            Circle()
                                .foregroundColor(.bGIconGrayLightest)
                                .frame(width: 40, height: 40)
                            
                            Image.ic24User
                                .renderingMode(.template)
                                .foregroundColor(.iconGray)
                        }
                       
                        ZStack{
                          
                            Circle()
                                .foregroundColor(.iconWhite)
                                .frame(width: 20, height: 20)
                            
                            viewModel.logo
                                .renderingMode(.original)
                        }
                        .offset(x: 14, y: -14)
                        
                    }
                    
                    Text(viewModel.name)
                        .foregroundColor(.textSecondary)
                        .font(.textH4R16240())
                }
            }
        }
    }
    
    struct NavBarButton: View {
        
        let viewModel: NavigationBarButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                viewModel.icon
                    .renderingMode(.template)
                    .foregroundColor(.iconBlack)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            MainView(viewModel: .sample)
        }
    }
}

extension MainViewModel {
    
    static let sample = MainViewModel(navButtonsRight: [.init(icon: .ic24Search, action: {}), .init(icon: .ic24Bell, action: {})], sections: [MainSectionProductsView.ViewModel.sample, MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample], isRefreshing: true)
    
    static let sampleProducts = MainViewModel(navButtonsRight: [.init(icon: .ic24Search, action: {}), .init(icon: .ic24Bell, action: {})], sections: [MainSectionProductsView.ViewModel(.productsMock), MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample], isRefreshing: false)
}


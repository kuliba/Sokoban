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
        
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                
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
                            
                        case let atmViewModel as MainSectionAtmView.ViewModel:
                            MainSectionAtmView(viewModel: atmViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.vertical, 20)
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: -geo.frame(in: .named("scroll")).origin.y)
           
                })
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    
                    if offset < -100 {
                        
                        viewModel.action.send(MainViewModelAction.PullToRefresh())
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .zIndex(0)
            
            if viewModel.isRefreshing == true {
                
                RefreshView()
                    .zIndex(1)
            }
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                        
                    case .userAccount(let userAccountViewModel):
                        UserAccountView(viewModel: userAccountViewModel)
                        
                    case .productProfile(let productProfileViewModel):
                        ProductProfileView(viewModel: productProfileViewModel)
                    case .messages(let messagesHistoryViewModel):
                        MessagesHistoryView(viewModel: messagesHistoryViewModel)
                    }
                }
            }
            
            if let url = viewModel.externalURL {
                
                    Color.clear
                        .onAppear {
                            
                            UIApplication.shared.open(url)
                            viewModel.externalURL = nil
                        }
            }
        }
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet.type {
                
            case .productProfile(let productProfileViewModel):
                ProductProfileView(viewModel: productProfileViewModel)
             
            case .messages(let messagesHistoryViewModel):
                MessagesHistoryView(viewModel: messagesHistoryViewModel)
                
            case .myProducts(let myProductsViewModel):
                MyProductsView(viewModel: myProductsViewModel)
                
            case .places(let placesViewModel):
                PlacesView(viewModel: placesViewModel)
            case .templates(let templatesViewModel):
                TemplatesListView(viewModel: templatesViewModel)
            case .byPhone(let viewModel):
                    TransferByPhoneView(viewModel: viewModel)
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
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

extension MainView {
    
    struct UserAccountButton: View {
    
        let viewModel: MainViewModel.UserAccountButtonViewModel?
        
        var body: some View {
            
            if let viewModel = viewModel {
                
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
                
            } else {
                
                Color.clear
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

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
                
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.sections) { section in
                        
                        switch section {
                        case let productsSectionViewModel as MainSectionProductsView.ViewModel:
                            MainSectionProductsView(viewModel: productsSectionViewModel)
                                .padding(.bottom, 19)
                            
                        case let fastOperationViewModel as MainSectionFastOperationView.ViewModel:
                            MainSectionFastOperationView(viewModel: fastOperationViewModel)
                                .padding(.bottom, 32)
                            
                        case let promoViewModel  as MainSectionPromoView.ViewModel:
                            MainSectionPromoView(viewModel: promoViewModel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 32)

                        case let currencyViewModel as MainSectionCurrencyView.ViewModel:
                            MainSectionCurrencyView(viewModel: currencyViewModel)
                                .padding(.bottom, 32)
                            
                        case let currencyMetallViewModel as MainSectionCurrencyMetallView.ViewModel:
                            MainSectionCurrencyMetallView(viewModel: currencyMetallViewModel)
                                .padding(.bottom, 32)
                            
                        case let openProductViewModel as MainSectionOpenProductView.ViewModel:
                            MainSectionOpenProductView(viewModel: openProductViewModel)
                                .padding(.bottom, 32)
                            
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
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case .userAccount(let userAccountViewModel):
                        UserAccountView(viewModel: userAccountViewModel)
                        
                    case .productProfile(let productProfileViewModel):
                        ProductProfileView(viewModel: productProfileViewModel)
                        
                    case .messages(let messagesHistoryViewModel):
                        MessagesHistoryView(viewModel: messagesHistoryViewModel)
                        
                    case .openDeposit(let depositListViewModel):
                        OpenDepositDetailView(viewModel: depositListViewModel)
                    
                    case .openCard( let authProductsViewModel):
                        AuthProductsView(viewModel: authProductsViewModel)
                        
                    case .openDepositsList(let openDepositViewModel):
                        OpenDepositView(viewModel: openDepositViewModel)
                        
                    case .templates(let templatesViewModel):
                        TemplatesListView(viewModel: templatesViewModel)
                    
                    case let .currencyWallet(viewModel):
                        CurrencyWalletView(viewModel: viewModel)
                        
                    case let .myProducts(myProductsViewModel):
                        MyProductsView(viewModel: myProductsViewModel)
                        
                    case let .country(countyViewModel):
                        CountryPaymentView(viewModel: countyViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .serviceOperators(let viewModel):
                        OperatorsView(viewModel: viewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .failedView(let failedViewModel):
                        QRFailedView(viewModel: failedViewModel)
                        
                    case .c2b(let c2bViewModel):
                        C2BDetailsView(viewModel: c2bViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .searchOperators(let viewModel):
                        QRSearchOperatorView(viewModel: viewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                        
                    case let .payments(paymentsViewModel):
                        PaymentsView(viewModel: paymentsViewModel)
                        
                    case let .operatorView(internetDetailViewModel):
                        InternetTVDetailsView(viewModel: internetDetailViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            }
            
            Color.clear
                .sheet(item: $viewModel.sheet, content: { sheet in
                    switch sheet.type {
                    case .productProfile(let productProfileViewModel):
                        ProductProfileView(viewModel: productProfileViewModel)
                        
                    case .messages(let messagesHistoryViewModel):
                        MessagesHistoryView(viewModel: messagesHistoryViewModel)
                        
                    case .places(let placesViewModel):
                        PlacesView(viewModel: placesViewModel)
                        
                    case .byPhone(let viewModel):
                        ContactsView(viewModel: viewModel)
                    }
                })
            
            Color.clear
                .fullScreenCover(item: $viewModel.fullScreenSheet) { item in
                    
                    switch item.type {
                    case let .qrScanner(viewModel):
                        NavigationView {
                            
                            QRView(viewModel: viewModel)
                                .navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
               
        }
        .ignoreKeyboard()
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in

            switch bottomSheet.type {
            case let .openAccount(openAccountViewModel):
                OpenAccountView(viewModel: openAccountViewModel)
            
            case let .clientInform(clientInformViewModel):
                ClientInformView(viewModel: clientInformViewModel)
            }
        }
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
        .tabBar(isHidden: $viewModel.isTabBarHidden)
        .onAppear { viewModel.action.send(MainViewModelAction.ViewDidApear()) }
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
    
        @ObservedObject var viewModel: MainViewModel.UserAccountButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack {
                    
                    ZStack {
                        
                        if let avatar = viewModel.avatar {
                            
                            avatar
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                        } else {
                            
                            ZStack {
                                
                                Circle()
                                    .foregroundColor(.bGIconGrayLightest)
                                    .frame(width: 40, height: 40)
                                
                                Image.ic24User
                                    .renderingMode(.template)
                                    .foregroundColor(.iconGray)
                            }
                        }
                        
                        ZStack{
                            
                            Circle()
                                .foregroundColor(.iconWhite)
                                .frame(width: 20, height: 20)
                            
                            viewModel.logo
                                .renderingMode(.original)
                        }
                        .offset(x: 18, y: -14)
                        
                    }
                    
                    Text(viewModel.name)
                        .foregroundColor(.textSecondary)
                        .font(.textH4R16240())
                        .accessibilityIdentifier("mainUserName")
                }
            }
            .accessibilityIdentifier("mainUserButton")
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
        
        Group {
            MainView(viewModel: .sample)
            
            NavigationView {
                
                MainView(viewModel: .sample)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}

extension MainViewModel {
    
    static let sample = MainViewModel(
        navButtonsRight: [.init(icon: .ic24Search, action: {}),
                          .init(icon: .ic24Bell, action: {})],
        sections: [MainSectionProductsView.ViewModel.sample,
                   MainSectionFastOperationView.ViewModel.sample,
                   MainSectionPromoView.ViewModel.sample,
                   MainSectionCurrencyMetallView.ViewModel.sample,
                   MainSectionOpenProductView.ViewModel.sample])
    
    static let sampleProducts = MainViewModel(navButtonsRight: [.init(icon: .ic24Search, action: {}), .init(icon: .ic24Bell, action: {})], sections: [MainSectionProductsView.ViewModel(.productsMock), MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample])
    
    static let sampleOldCurrency = MainViewModel(
                                    navButtonsRight: [.init(icon: .ic24Search, action: {}),
                                                      .init(icon: .ic24Bell, action: {})],
                                    sections: [MainSectionProductsView.ViewModel(.productsMock),
                                               MainSectionFastOperationView.ViewModel.sample,
                                               MainSectionPromoView.ViewModel.sample,
                                               MainSectionCurrencyView.ViewModel.sample,
                                               MainSectionOpenProductView.ViewModel.sample])
}

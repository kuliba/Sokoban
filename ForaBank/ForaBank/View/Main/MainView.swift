//
//  MainView.swift
//  ForaBank
//
//  Created by Max Gribov on 05.03.2022.
//

import SwiftUI
import ScrollViewProxy
import PaymentSticker

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
                
                viewModel.link.map {
                    
                    destinationView(
                        link: $0
                    )
                }
            }
            
            Color.clear
                .sheet(item: $viewModel.sheet, content: sheetView)
            
            Color.clear
                .fullScreenCover(
                    item: $viewModel.fullScreenSheet,
                    content: fullScreenSheetView
                )
        }
        .ignoreKeyboard()
        .bottomSheet(item: $viewModel.bottomSheet, content: bottomSheetView)
        .alert(item: $viewModel.alert, content: Alert.init(with:))
        .tabBar(isHidden: $viewModel.isTabBarHidden)
        .onAppear { viewModel.action.send(MainViewModelAction.ViewDidApear()) }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading:
                UserAccountButton(viewModel: viewModel.userAccountButton),
            trailing:
                HStack {
                    ForEach(viewModel.navButtonsRight, content: NavBarButton.init)
                }
        )
    }
    
    @ViewBuilder
    private func destinationView(
        link: MainViewModel.Link
    ) -> some View {
        
        switch link {
        case let .userAccount(userAccountViewModel):
            UserAccountView(viewModel: userAccountViewModel)
            
        case let .productProfile(productProfileViewModel):
            ProductProfileView(viewModel: productProfileViewModel)
            
        case let .messages(messagesHistoryViewModel):
            MessagesHistoryView(viewModel: messagesHistoryViewModel)
            
        case let .openDeposit(depositListViewModel):
            OpenDepositDetailView(viewModel: depositListViewModel)
            
        case let .openCard(authProductsViewModel):
            AuthProductsView(viewModel: authProductsViewModel)
            
        case let .openDepositsList(openDepositViewModel):
            OpenDepositView(viewModel: openDepositViewModel)
            
        case let .templates(templatesViewModel):
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
            
        case let .serviceOperators(viewModel):
            OperatorsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .failedView(failedViewModel):
            QRFailedView(viewModel: failedViewModel)
            
        case let .searchOperators(viewModel):
            QRSearchOperatorView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .payments(paymentsViewModel):
            PaymentsView(viewModel: paymentsViewModel)
            
        case let .operatorView(internetDetailViewModel):
            InternetTVDetailsView(viewModel: internetDetailViewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .paymentsServices(viewModel):
            PaymentsServicesOperatorsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .paymentSticker(makeOperation):
            NavigationOperationViewFactory.makeNavigationOperationView(
                makeOperation: makeOperation,
                atmData: viewModel.dictionaryAtmList(),
                atmMetroStationData: viewModel.dictionaryAtmMetroStations()
            )
        }
    }
    
    @ViewBuilder
    private func sheetView(
        _ sheet: MainViewModel.Sheet
    ) -> some View {
        
        switch sheet.type {
        case let .productProfile(productProfileViewModel):
            ProductProfileView(viewModel: productProfileViewModel)
            
        case let .messages(messagesHistoryViewModel):
            MessagesHistoryView(viewModel: messagesHistoryViewModel)
            
        case let .places(placesViewModel):
            PlacesView(viewModel: placesViewModel)
            
        case let .byPhone(viewModel):
            ContactsView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    private func bottomSheetView(
        bottomSheet: MainViewModel.BottomSheet
    ) -> some View {
        
        switch bottomSheet.type {
        case let .openAccount(openAccountViewModel):
            OpenAccountView(viewModel: openAccountViewModel)
            
        case let .clientInform(clientInformViewModel):
            ClientInformView(viewModel: clientInformViewModel)
        }
    }
    
    @ViewBuilder
    private func fullScreenSheetView(
        fullScreenSheet: MainViewModel.FullScreenSheet
    ) -> some View {
        
        switch fullScreenSheet.type {
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
                                    .foregroundColor(.bgIconGrayLightest)
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

extension MainView {
    
    static func configurationOperationView() -> PaymentSticker.ConfigurationOperationView {
        
        PaymentSticker.ConfigurationOperationView(
            tipViewConfig: .init(
                titleFont: .textBodyMR14200(),
                titleForeground: .textSecondary,
                backgroundView: .mainColorsGrayLightest
            ), stickerViewConfig: .init(
                rectangleColor: .mainColorsGrayLightest,
                configHeader: .init(
                    titleFont: .textH3Sb18240(),
                    titleColor: .mainColorsBlack,
                    descriptionFont: .textBodySR12160(),
                    descriptionColor: .textPlaceholder
                ),
                configOption: .init(
                    titleFont: .textBodySR12160(),
                    titleColor: .textPlaceholder,
                    iconColor: .systemColorActive,
                    descriptionFont: .textH4M16240(),
                    descriptionColor: .secondary,
                    optionFont: .textH4M16240(),
                    optionColor: .textSecondary
                )),
            selectViewConfig: .init(
                selectOptionConfig: .init(
                    titleFont: .textBodyMR14180(),
                    titleForeground: .textPlaceholder,
                    placeholderForeground: .textTertiary,
                    placeholderFont: .textBodyMR14180()
                ),
                optionsListConfig: .init(
                    titleFont: .textH4M16240(),
                    titleForeground: .textSecondary
                ),
                optionConfig: .init(
                    nameFont: .textH4M16240(),
                    nameForeground: .textSecondary
                )
            ),
            productViewConfig: .init(
                headerTextColor: .textPlaceholder,
                headerTextFont: .textBodyMR14180(),
                textColor: .textSecondary,
                textFont: .textH4M16240(),
                optionConfig: .init(
                    numberColor: .textWhite,
                    numberFont: .textBodyXsR11140(),
                    nameColor: .textWhite.opacity(0.4),
                    nameFont: .textBodyXsR11140(),
                    balanceColor: .textWhite,
                    balanceFont: .textBodyXsSb11140()
                ),
                background: .init(color: .mainColorsGrayLightest)
            ),
            inputViewConfig: .init(
                titleFont: .textBodyMR14180(),
                titleColor: .textPlaceholder,
                iconColor: .iconGray,
                iconName: "ic24SmsCode"
            ),
            amountViewConfig: .init(
                amountFont: .textH2Sb20282(),
                amountColor: .textWhite,
                buttonTextFont: .buttonMediumM14160(),
                buttonTextColor: .textWhite,
                buttonColor: .mainColorsRed,
                hintFont: .textBodySR12160(),
                hintColor: .textPlaceholder,
                background: .mainColorsBlackMedium
            )
        )
    }
}

extension OperationStateViewModel {

    static let empty = OperationStateViewModel(businessLogic: .empty)
}

private extension BusinessLogic {
    
    static let empty = BusinessLogic(
        processDictionaryService: { _,_ in },
        processTransferService: { _,_ in },
        processMakeTransferService: { _,_ in },
        processImageLoaderService: { _,_ in },
        selectOffice: { _,_ in },
        products: [],
        cityList: []
    )
}

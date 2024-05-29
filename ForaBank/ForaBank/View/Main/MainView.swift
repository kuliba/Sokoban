//
//  MainView.swift
//  ForaBank
//
//  Created by Max Gribov on 05.03.2022.
//

import InfoComponent
import LandingUIComponent
import PaymentSticker
import SberQR
import ScrollViewProxy
import ActivateSlider
import SwiftUI

struct MainView<NavigationOperationView: View>: View {
    
    @ObservedObject var viewModel: MainViewModel
    let navigationOperationView: () -> NavigationOperationView
    
    let viewFactory: MainViewFactory
    let paymentsTransfersViewFactory: PaymentsTransfersViewFactory
    let productProfileViewFactory: ProductProfileViewFactory
    let getUImage: (Md5hash) -> UIImage?
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.sections, content: sectionView)
                }
                .padding(.vertical, 20)
                .background(
                    GeometryReader { geo in
                        
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named("scroll")).origin.y
                            )
                    }
                )
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    
                    if offset < -100 {
                        
                        viewModel.action.send(MainViewModelAction.PullToRefresh())
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .zIndex(0)
            
            Color.clear
                .sheet(
                    item: .init(
                        get: { viewModel.route.modal?.sheet },
                        set: { if $0 == nil { viewModel.resetModal() } }),
                    content: sheetView
                )
            
            Color.clear
                .fullScreenCover(
                    item: .init(
                        get: { viewModel.route.modal?.fullScreenSheet },
                        set: { if $0 == nil { viewModel.resetModal() } }
                    ),
                    content: fullScreenSheetView
                )
        }
        .ignoreKeyboard()
        .alert(
            item: .init(
                get: { viewModel.route.modal?.alert },
                set: { if $0 == nil { viewModel.resetModal() } }
            ),
            content: Alert.init(with:)
        )
        .bottomSheet(
            item: .init(
                get: { viewModel.route.modal?.bottomSheet },
                set: { if $0 == nil { viewModel.resetModal() } }
            ),
            content: bottomSheetView
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.route.destination },
                set: { if $0 == nil { viewModel.resetDestination() } }
            ),
            content: destinationView
        )
        .tabBar(isHidden: .init(
            get: { !viewModel.route.isEmpty },
            set: { if !$0 { viewModel.reset() } }
        ))
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
    private func sectionView(
        section: MainSectionViewModel
    ) -> some View {
        
        switch section {
        case let updateInfoViewModel as UpdateInfoViewModel:
            viewFactory.makeUpdateInfoView(updateInfoViewModel.content)
            
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
    
    @ViewBuilder
    private func destinationView(
        link: MainViewModel.Link
    ) -> some View {
        
        switch link {
        case let .userAccount(userAccountViewModel):
            viewFactory.makeUserAccountView(userAccountViewModel)
            
        case let .productProfile(productProfileViewModel):
            ProductProfileView(
                viewModel: productProfileViewModel,
                viewFactory: paymentsTransfersViewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
            
        case let .messages(messagesHistoryViewModel):
            MessagesHistoryView(viewModel: messagesHistoryViewModel)
            
        case let .openDeposit(depositListViewModel):
            OpenDepositDetailView(viewModel: depositListViewModel, getUImage: getUImage)
            
        case let .openCard(authProductsViewModel):
            AuthProductsView(viewModel: authProductsViewModel)
            
        case let .openDepositsList(openDepositViewModel):
            OpenDepositListView(viewModel: openDepositViewModel, getUImage: getUImage)
            
        case let .templates(templatesViewModel):
            TemplatesListView(viewModel: templatesViewModel)
            
        case let .currencyWallet(viewModel):
            CurrencyWalletView(viewModel: viewModel)
            
        case let .myProducts(myProductsViewModel):
            MyProductsView(
                viewModel: myProductsViewModel,
                viewFactory: paymentsTransfersViewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
            
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
            
        case let .sberQRPayment(sberQRPaymentViewModel):
            viewFactory.makeSberQRConfirmPaymentView(sberQRPaymentViewModel)
                .navigationBar(
                    sberQRPaymentViewModel.navTitle,
                    dismiss: viewModel.resetDestination
                )
        case let .landing(viewModel):
            LandingWrapperView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
            
        case let .orderSticker(viewModel):
            LandingWrapperView(viewModel: viewModel)
            
        case .paymentSticker:
            navigationOperationView()
                .navigationBarTitle("Оформление заявки", displayMode: .inline)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    @ViewBuilder
    private func sheetView(
        _ sheet: MainViewModel.Sheet
    ) -> some View {
        
        switch sheet.type {
        case let .productProfile(productProfileViewModel):
            ProductProfileView(
                viewModel: productProfileViewModel,
                viewFactory: paymentsTransfersViewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
            
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
            
        case let .success(viewModel):
            PaymentsSuccessView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

private extension MainViewModel.Route {
    
    var isEmpty: Bool {
        
        destination == nil && modal == nil
    }
}

extension MainView {
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue: CGFloat { .zero }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

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

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            mainView()
            
            NavigationView(content: mainView)
        }
    }
    
    private static func mainView() -> some View {
        
        MainView(
            viewModel: .sample,
            navigationOperationView: EmptyView.init,
            viewFactory: .preview,
            paymentsTransfersViewFactory: .preview,
            productProfileViewFactory: .init(makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:)),
            getUImage: { _ in nil }
        )
    }
}

extension MainViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeSberQRConfirmPaymentView: {
                
                .init(
                    viewModel: $0,
                    map: PublishingInfo.preview(info:),
                    config: .iFora
                )
            },
            makeUserAccountView: UserAccountView.init(viewModel:),
            makeUpdateInfoView: UpdateInfoView.init(text:)
        )
    }
}

extension MainViewModel {
    
    static let sample = MainViewModel(
        .emptyMock,
        makeProductProfileViewModel: ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersFlowManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            unblockCardServices: .preview(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: .preview
        ),
        navigationStateManager: .preview,
        sberQRServices: .empty(),
        qrViewModelFactory: .preview(),
        paymentsTransfersFactory: .preview, 
        updateInfoStatusFlag: .init(.active),
        onRegister: {}
    )
    
    static let sampleProducts = MainViewModel(
        .emptyMock,
        makeProductProfileViewModel: ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersFlowManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            unblockCardServices: .preview(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: .preview
        ),
        navigationStateManager: .preview,
        sberQRServices: .empty(),
        qrViewModelFactory: .preview(),
        paymentsTransfersFactory: .preview,
        updateInfoStatusFlag: .init(.active),
        onRegister: {}
    )
    
    static let sampleOldCurrency = MainViewModel(
        .emptyMock,
        makeProductProfileViewModel: ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersFlowManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            unblockCardServices: .preview(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: .preview
        ),
        navigationStateManager: .preview,
        sberQRServices: .empty(),
        qrViewModelFactory: .preview(),
        paymentsTransfersFactory: .preview,
        updateInfoStatusFlag: .init(.active),
        onRegister: {}
    )
}

private extension NavigationOperationView
where OperationView == Color,
      ListView == Color {
    
    static func preview() -> Self {
        .init(
            location: .init(id: ""),
            viewModel: .init(),
            operationView: { _ in Color.red },
            listView: { _,_ in Color.yellow }
        )
    }
}

extension PaymentSticker.OperationViewConfiguration {
    
    static let `default`: Self = .init(
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
            ),
            textFieldConfig: .init(
                font: .textH4M16240(),
                textColor: .textSecondary,
                tintColor: .textSecondary,
                backgroundColor: .clear,
                placeholderColor: .textTertiary
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
            iconName: "ic24SmsCode",
            warningFont: .textBodySR12160(),
            warningColor: .systemColorError,
            textFieldFont: .body,
            textFieldColor: .textSecondary,
            textFieldTintColor: .textSecondary,
            textFieldBackgroundColor: .clear,
            textFieldPlaceholderColor: .textPlaceholder
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
        ),
        resultViewConfiguration: .init(
            colorSuccess: Color.systemColorActive,
            colorWait: Color.systemColorWarning,
            colorFailed: Color.systemColorError,
            titleColor: Color.textSecondary,
            titleFont: .textH3Sb18240(),
            descriptionColor: .textPlaceholder,
            descriptionFont: .textBodyMR14200(),
            amountColor: .textSecondary,
            amountFont: .textH1Sb24322(),
            mainButtonColor: .textWhite,
            mainButtonFont: .textH3Sb18240(),
            mainButtonBackgroundColor: .buttonPrimary
        ),
        continueButtonConfiguration: .init(
            activeColor: .buttonPrimary,
            inActiveColor: .buttonPrimaryDisabled,
            textFont: .textH3Sb18240(),
            textColor: .textWhite
        )
    )
}

extension OperationStateViewModel {
    
    static let empty = OperationStateViewModel { _,_ in }
}

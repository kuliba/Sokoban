//
//  MainView.swift
//  ForaBank
//
//  Created by Max Gribov on 05.03.2022.
//

import ActivateSlider
import Banners
import Combine
import FooterComponent
import ForaTools
import InfoComponent
import LandingUIComponent
import PaymentSticker
import SberQR
import ScrollViewProxy
import SwiftUI
import UIPrimitives

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
            viewFactory.makeInfoViews.makeUpdateInfoView(updateInfoViewModel.content)
            
        case let productsSectionViewModel as MainSectionProductsView.ViewModel:
            viewFactory.components.makeMainSectionProductsView(productsSectionViewModel)
                .padding(.bottom, 19)
            
        case let fastOperationViewModel as MainSectionFastOperationView.ViewModel:
            MainSectionFastOperationView(viewModel: fastOperationViewModel)
                .padding(.bottom, 32)
            
        case let promoViewModel  as MainSectionPromoView.ViewModel:
            MainSectionPromoView(viewModel: promoViewModel)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            
        case let promo as BannerPickerSectionBinderWrapper:
            makeBannersView(promo.binder)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            
        case let currencyViewModel as MainSectionCurrencyView.ViewModel:
            MainSectionCurrencyView(viewModel: currencyViewModel)
                .padding(.bottom, 32)
            
        case let currencyMetalViewModel as MainSectionCurrencyMetallView.ViewModel:
            viewFactory.components.makeMainSectionCurrencyMetalView(currencyMetalViewModel)
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
            viewFactory.makeUserAccountView(userAccountViewModel, .iFora)
            
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
            
        case let .templates(node):
            viewFactory.components.makeTemplatesListFlowView(node)
            
        case let .currencyWallet(viewModel):
            viewFactory.components.makeCurrencyWalletView(viewModel)
            
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
            viewFactory.components.makeQRFailedView(failedViewModel)
            
        case let .searchOperators(viewModel):
            viewFactory.components.makeQRSearchOperatorView(viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .payments(node):
            viewFactory.components.makePaymentsView(node.model)
            
        case let .operatorView(internetDetailViewModel):
            InternetTVDetailsView(viewModel: internetDetailViewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .paymentsServices(viewModel):
            viewFactory.components.makePaymentsServicesOperatorsView(viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .sberQRPayment(sberQRPaymentViewModel):
            viewFactory.makeSberQRConfirmPaymentView(sberQRPaymentViewModel)
                .navigationBarWithBack(
                    title: sberQRPaymentViewModel.navTitle,
                    dismiss: viewModel.resetDestination
                )
        case let .landing(viewModel, needIgnoringSafeArea):
            if needIgnoringSafeArea {
                LandingWrapperView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                LandingWrapperView(viewModel: viewModel)
            }
            
        case let .orderSticker(viewModel):
            LandingWrapperView(viewModel: viewModel)
            
        case .paymentSticker:
            navigationOperationView()
                .navigationBarTitle("Оформление заявки", displayMode: .inline)
                .edgesIgnoringSafeArea(.bottom)
            
        case let .paymentProviderPicker(node):
            paymentProviderPicker(node.model)
            
        case let .providerServicePicker(node):
            servicePicker(flowModel: node.model)
            
        case .collateralLoanLanding:
            // TODO: There are will added integration in next commit
            Color.clear
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
            
        case let .byPhone(node):
            viewFactory.components.makeContactsView(node.model)
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
        case let .qrScanner(node):
            viewFactory.components.makeQRView(node.model.qrModel)
            
        case let .success(viewModel):
            viewFactory.components.makePaymentsSuccessView(viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - banners

private extension MainView {
        
    func makeBannersView(
        _ binder: BannersBinder
    ) -> some View {
        
        ComposedBannersView(
            bannersBinder: binder,
            factory: .init(
                makeContentView: {
                    BannersContentView(
                        content: binder.content,
                        factory: .init(
                            makeBannerSectionView: makeBannerSectionView
                        ),
                        config: .init(bannerSectionHeight: 128, spacing: 10)
                    )
                }
            )
        )
    }

    
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage

    func makeBannerSectionView(
        binder: BannerPickerSectionBinder
    ) -> some View {
        
        ComposedBannerPickerSectionFlowView(
            binder: binder,
            config: .init(spacing: 10),
            itemView: itemView,
            makeDestinationView: { Text(String(describing: $0)) }
        )
    }

    @ViewBuilder
    private func itemView(
        item: BannerPickerSectionState.Item
    ) -> some View {
        
        BannerPickerSectionStateItemView(
            item: item,
            config: .iFora,
            bannerView: { item in
                
                let label = viewFactory.makeGeneralIconView(.image(item.imageEndpoint))
                    .frame(Config.iFora.size)
                    .cornerRadius(Config.iFora.cornerRadius)
                
                Button { viewModel.promoAction(item) } label: { label }
                    .frame(Config.iFora.size)
                    .buttonStyle(PushButtonStyle())
                    .accessibilityIdentifier("mainActionBanner")
            },
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
    
    private typealias Config = BannerPickerSectionStateItemViewConfig
}

// MARK: - payment provider & service pickers

private extension MainView {
    
    func paymentProviderPicker(
        _ flowModel: SegmentedPaymentProviderPickerFlowModel
    ) -> some View {
        
        viewFactory.components.makeComposedSegmentedPaymentProviderPickerFlowView(flowModel)
            .navigationBarWithBack(
                title: PaymentsTransfersSectionType.payments.name,
                dismiss: viewModel.dismissPaymentProviderPicker,
                rightItem: .barcodeScanner(
                    action: viewModel.dismissPaymentProviderPicker
                )
            )
    }
    
    @ViewBuilder
    func servicePicker(
        flowModel: AnywayServicePickerFlowModel
    ) -> some View {
        
        let provider = flowModel.state.content.state.payload.provider
        
        viewFactory.components.makeAnywayServicePickerFlowView(flowModel)
            .navigationBarWithAsyncIcon(
                title: provider.origin.title,
                subtitle: provider.origin.inn,
                dismiss: viewModel.dismissProviderServicePicker,
                icon: viewFactory.iconView(provider.origin.icon),
                style: .normal
            )
    }
}

extension PaymentProviderServicePickerFlowModel: Identifiable {
    
    var id: String { state.content.state.payload.provider.origin.id }
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
            productProfileViewFactory: .init(
                makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                makeHistoryButton: { .init(event: $0, isFiltered: $1, isDateFiltered: $2, clearOptions: $3) },
                makeRepeatButtonView: { _ in .init(action: {}) }
            ),
            getUImage: { _ in nil }
        )
    }
}

extension MainViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeAnywayPaymentFactory: { _ in fatalError() },
            makeIconView: IconDomain.preview, 
            makeGeneralIconView: IconDomain.preview,
            makePaymentCompleteView: { _,_ in fatalError() },
            makeSberQRConfirmPaymentView: {
                
                .init(
                    viewModel: $0,
                    map: PublishingInfo.preview(info:),
                    config: .iFora
                )
            },
            makeInfoViews: .default,
            makeUserAccountView: { UserAccountView.init(viewModel: $0, config: $1, viewFactory: .preview) },
            components: .preview
        )
    }
}

extension ProductProfileViewModel  {
    
    static let makeProductProfileViewModel = ProductProfileViewModel.make(
        with: .emptyMock,
        fastPaymentsFactory: .legacy,
        makeUtilitiesViewModel: { _,_ in },
        makeTemplates: { _ in .sampleComplete },
        makePaymentsTransfersFlowManager: { _ in .preview },
        userAccountNavigationStateManager: .preview,
        sberQRServices: .empty(),
        landingServices: .empty(),
        productProfileServices: .preview,
        qrViewModelFactory: .preview(),
        cvvPINServicesClient: HappyCVVPINServicesClient(),
        productNavigationStateManager: .preview,
        makeCardGuardianPanel: ProductProfileViewModelFactory.makeCardGuardianPanelPreview,
        makeSubscriptionsViewModel: { _,_ in .preview },
        updateInfoStatusFlag: .active,
        makePaymentProviderPickerFlowModel: SegmentedPaymentProviderPickerFlowModel.preview,
        makePaymentProviderServicePickerFlowModel: AnywayServicePickerFlowModel.preview,
        makeServicePaymentBinder: ServicePaymentBinder.preview
    )
}

extension MainViewModel {
    
    static let sample = MainViewModel(
        .emptyMock,
        makeProductProfileViewModel: ProductProfileViewModel.makeProductProfileViewModel,
        navigationStateManager: .preview,
        sberQRServices: .empty(),
        qrViewModelFactory: .preview(),
        landingServices: .empty(), 
        paymentsTransfersFactory: .preview,
        updateInfoStatusFlag: .active,
        onRegister: {},
        bannersBinder: .preview
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

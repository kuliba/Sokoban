//
//  MainView.swift
//  Vortex
//
//  Created by Max Gribov on 05.03.2022.
//

import ActivateSlider
import Banners
import ClientInformList
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI
import Combine
import FooterComponent
import InfoComponent
import LandingUIComponent
import PaymentSticker
import RxViewModel
import SberQR
import ScrollViewProxy
import SwiftUI
import UIPrimitives
import VortexTools
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import SavingsAccount

struct MainView<NavigationOperationView: View>: View {
    
    @ObservedObject var viewModel: MainViewModel
    let navigationOperationView: () -> NavigationOperationView
    
    let viewFactory: MainViewFactory
    let paymentsTransfersViewFactory: PaymentsTransfersViewFactory
    let productProfileViewFactory: ProductProfileViewFactory
    let getUImage: (Md5hash) -> UIImage?
    let makeImageView: (Md5hash) -> UIPrimitives.AsyncImage
    
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
                .accessibilityIdentifier(ElementIDs.mainView(.fullScreenCoverAnchor).rawValue)
                .fullScreenCoverInspectable(
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
        .accessibilityIdentifier(ElementIDs.mainView(.content).rawValue)
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
            viewFactory.components.makeInfoViews.makeUpdateInfoView(updateInfoViewModel.content)
            
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
            
        case let .templates(node):
            viewFactory.components.makeTemplatesListFlowView(node)
                .accessibilityIdentifier(ElementIDs.mainView(.templates).rawValue)
            
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
            viewFactory.components.makeQRFailedWrapperView(failedViewModel)
            
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
            
        case let .collateralLoanLanding(binder):
            let factory = viewModel.makeCollateralLoanFactory()
            
            viewFactory.components.makeCollateralLoanShowcaseWrapperView(
                binder: binder,
                factory: viewModel.makeCollateralLoanFactory(),
                goToMain: viewModel.resetDestination
            )
                .navigationBarWithBack(
                    title: "Кредиты",
                    dismiss: viewModel.resetDestination
                )
                .edgesIgnoringSafeArea(.bottom)

        case let .collateralLoanLandingProduct(binder):
            viewFactory.components.makeCollateralLoanWrapperView(
                binder: binder,
                factory: viewModel.makeCollateralLoanFactory(), 
                goToMain: viewModel.resetDestination
            )
                .navigationBarWithBack(
                    title: "",
                    dismiss: viewModel.resetDestination
                )
 
        case .orderCard:
            viewFactory.components.makeOrderCardView()
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
            
        case let .clientInform(clientInform):
            ClientInformListView(config: .iVortex, info: clientInform.client)
        }
    }
    
    @ViewBuilder
    private func fullScreenSheetView(
        fullScreenSheet: MainViewModel.FullScreenSheet
    ) -> some View {
        
        switch fullScreenSheet.type {
        case let .qrScanner(node):
            NavigationView {
                
                viewFactory.components.makeQRView(node.model.qrScanner)
                    .accessibilityIdentifier(ElementIDs.mainView(.qrScanner).rawValue)
            }
            .navigationViewStyle(.stack)
            
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
            config: .iVortex,
            bannerView: { item in
                
                let label = viewFactory.makeGeneralIconView(.image(item.imageEndpoint))
                    .frame(Config.iVortex.size)
                    .cornerRadius(Config.iVortex.cornerRadius)
                
                Button { viewModel.promoAction(item) } label: { label }
                    .frame(Config.iVortex.size)
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
        
        viewFactory.components.makeSegmentedPaymentProviderPickerView(flowModel)
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
        
        Button(action: viewModel.action, label: label)
            .accessibilityIdentifier("mainUserButton")
    }
}

private extension UserAccountButton {
    
    func label() -> some View {
        
        UserAccountButtonLabel(avatar: viewModel.avatar, name: viewModel.name, config: .prod)
    }
}

struct NavBarButton: View {
    
    let viewModel: NavigationBarButtonViewModel
    
    var body: some View {
        
        Button(action: viewModel.action, label: label)
    }
    
    private func icon() -> some View {
        
        viewModel.icon
            .renderingMode(.template)
            .foregroundColor(.iconBlack)
    }
    
    @ViewBuilder
    private func label() -> some View {
        
        switch viewModel.title {
        case "":
            viewModel.icon
            
        default:
            HStack(spacing: 8) {
                
                Text(viewModel.title)
                    .foregroundStyle(.textSecondary)
                    .font(.textBodySM12160())
                
                icon()
            }
            .padding(8)
            .background(Color.bgIconPinkPurple)
            .clipShape(RoundedRectangle(cornerRadius: 88))
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
            getUImage: { _ in nil },
            makeImageView: { _ in previewAsyncImage }
        )
    }
}

private var previewAsyncImage: UIPrimitives.AsyncImage { AsyncImage(
    image: .init(systemName: "car"),
    publisher: Empty()
        .eraseToAnyPublisher()
)}

extension MainViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeAnywayPaymentFactory: { _ in fatalError() },
            makeIconView: IconDomain.preview,
            makeGeneralIconView: IconDomain.preview,
            makePaymentCompleteView: { _,_ in fatalError() },
            makeSberQRConfirmPaymentView: {
                
                return .init(
                    viewModel: $0,
                    map: PublishingInfo.preview(info:),
                    config: .iVortex
                )
            },
            makeUserAccountView: {
                
                return .init(
                    viewModel: $0,
                    config: .preview,
                    viewFactory: .preview
                )
            },
            components: .preview
        )
    }
}

//extension CollateralLoanLandingWrapperView {
//    
//    static let preivew = Self(
//        binder: .preview,
//        factory: .preview,
//        config: .default,
//        goToMain: {},
//        makeOperationDetailInfoViewModel: { _,_  in .preview }
//    )
//}

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
        makeRepeatPaymentNavigation: { _,_,_,_  in .none },
        makeSubscriptionsViewModel: { _,_ in .preview },
        updateInfoStatusFlag: .active,
        makePaymentProviderPickerFlowModel: SegmentedPaymentProviderPickerFlowModel.preview,
        makePaymentProviderServicePickerFlowModel: AnywayServicePickerFlowModel.preview,
        makeServicePaymentBinder: ServicePaymentBinder.preview,
        makeOpenNewProductButtons: { _ in [] },
        operationDetailFactory: .preview,
        makeOrderCardViewModel: { /*TODO:  implement preview*/ },
        makePaymentsTransfers: { PreviewPaymentsTransfersSwitcher() }
    )
}

extension MainViewModel {
    
    static private var previewAsyncImage: UIPrimitives.AsyncImage { AsyncImage(
        image: .init(systemName: "car"),
        publisher: Empty()
            .eraseToAnyPublisher()
    )}
    
    static let sample = MainViewModel(
        .emptyMock,
        bannersBox: BannersBox(load: { $0(nil) }),
        navigationStateManager: .preview,
        sberQRServices: .empty(),
        landingServices: .empty(),
        paymentsTransfersFactory: .preview,
        updateInfoStatusFlag: .active,
        onRegister: {
        },
        sections: [],
        bindersFactory: .preview,
        viewModelsFactory: .preview,
        makeOpenNewProductButtons: { _ in [] },
        getPDFDocument: { _,_ in }, 
        makeCollateralLoanLandingFactory: { _ in .preview }
    )
}

// MARK: - GetCollateralLandingDomain.Binder preview

private extension GetCollateralLandingDomain.Binder {
    
    static let preview = GetCollateralLandingDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension GetCollateralLandingDomain.Content {
    
    static let preview = GetCollateralLandingDomain.Content(
        initialState: .init(
            landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
            formatCurrency: { _ in "" }
        ),
        reduce: {
            state,_ in (state, nil)
        },
        handleEffect: { _,_ in }
    )
}

private extension GetCollateralLandingDomain.Flow {
    
    static let preview = GetCollateralLandingDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
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

extension OperationStateViewModel {
    
    static let empty = OperationStateViewModel { _,_ in }
}

// MARK: - Adapters

private extension ClientInformListDataState {
    
    var client: ClientInformList.ClientInformListDataState {
        
        switch self {
        case let .single(single):
            
            return .single(.init(
                
                label: .init(image: single.label.image, title: single.label.title, url: single.label.url),
                text: single.text
            ))
            
        case let .multiple(multiple):
            
            return .multiple(.init(
                
                title: .init(image: multiple.title.image, title: multiple.title.title),
                items: multiple.items.map {
                    
                    return .init(id: $0.id, image: $0.image, title: $0.title, url: $0.url)
                }
            ))
        }
    }
}

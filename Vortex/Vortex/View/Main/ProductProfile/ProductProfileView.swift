//
//  ProductProfileView.swift
//  Vortex
//
//  Created by Дмитрий on 09.03.2022.
//

import ActivateSlider
import CalendarUI
import InfoComponent
import PinCodeUI
import RxViewModel
import SberQR
import SwiftUI
import VortexTools
import Combine

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    let viewFactory: PaymentsTransfersViewFactory
    let productProfileViewFactory: ProductProfileViewFactory
    let getUImage: (Md5hash) -> UIImage?
    
    var accentColor: some View {
        
        return viewModel.accentColor.overlay(Color(hex: "1с1с1с").opacity(0.3))
    }
    
    private let offsetHeight: CGFloat = 204 - 48

    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView {
                
                ZStack(alignment: .top) {
                    
                    filler()

                    content()
                        .padding(.top, 56 - 48)
                }
                .background(
                    GeometryReader { geo in
                        
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named("scroll")).origin.y
                            )
                    }
                )
            }
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                
                if offset < -100 {
                    
                    viewModel.action.send(ProductProfileViewModelAction.PullToRefresh())
                }
            }
            .coordinateSpace(name: "scroll")
            
            NavigationLink(
                "",
                isActive: .init(
                    get: { viewModel.link != nil },
                    set: { if !$0 { viewModel.link = nil }}
                )
            ) {
                viewModel.link.map(navLinkDestination)
            }
            
            // workaround to fix mini-cards jumps when product name editing alert presents
            Color.clear
                .textfieldAlert(alert: $viewModel.textFieldAlert)
               
            historySheet()
            
            viewModel.closeAccountSpinner.map(CloseAccountSpinnerView.init)
            
            spinner()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBar(with: viewModel.navigationBar)
        .onReceive(viewModel.action) { action in
            switch action {
            case _ as ProductProfileViewModelAction.Close.SelfView:
                self.mode.wrappedValue.dismiss()
                
            default: break
            }
        }
        .alert(item: $viewModel.alert, content: Alert.init(with:))
        .bottomSheet(
            item: $viewModel.bottomSheet,
            content: bottomSheetContent
        )
        .fullScreenCover(
            item: $viewModel.fullScreenCoverState,
            content: fullScreenCoverContent
        )
        .sheet(item: $viewModel.sheet, content: sheetContent)
    }
    
    private func historySheetContent(
        sheet: ProductProfileViewModel.HistoryState.Sheet
    ) -> some View {
        
        VStack(spacing: 15) {
            
            switch sheet {
            case .calendar:
                CalendarWrapperView(
                    state: .init(
                        date: Date(),
                        range: .init(
                            startDate: Date.startDayOfCalendar(),
                            endDate: Date()
                        ),
                        monthsData: .generate(startDate: viewModel.calendarDayStart()),
                        periods: [.week, .month, .dates]
                    ),
                    event: { event in
                        
                        switch event {
                        case .clear:
                            break
                        case .dismiss:
                            viewModel.event(.history(.dismiss))
                        }
                    },
                    config: .iVortex,
                    apply: { lowerDate, upperDate in
                        if let lowerDate = lowerDate,
                           let upperDate = upperDate {
                            
                            viewModel.filterState.calendar.range = .init(
                                startDate: lowerDate,
                                endDate: upperDate
                            )
                            viewModel.filterHistoryRequest(
                                lowerDate,
                                upperDate,
                                nil,
                                []
                            )
                        }
                        viewModel.event(.history(.dismiss))
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarWithBack(
                    title: "Выберите даты или период",
                    dismiss: {
                    viewModel.event(.history(.filter(.dismissCalendar)))
                })
                
            case let .filter(filter):
                    
                NavigationView {
                    
                    FilterWrapperView(
                        model: filter,
                        config: .iVortex
                    ) {
                        viewModel.event(.history(.filter(.period($0))))
                    } buttonsView: { hasFilter in
                        ButtonsContainer(
                            applyAction: {
                                
                                viewModel.event(.updateFilter(filter.state))
                            },
                            clearOptionsAction: {
                                filter.event(.clearOptions)
                            },
                            isAvailable: hasFilter,
                            config: .init(
                                clearButtonTitle: "Очистить",
                                applyButtonTitle: "Применить",
                                disableButtonBackground: .mainColorsGrayLightest
                            )
                        )
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(
                        destination: viewModel.historyState?.calendarState,
                        dismiss: { viewModel.event(.history(.filter(.dismissCalendar))) },
                        content: { state in
                            
                            CalendarWrapperView(
                                state: state.state,
                                event: {
                                    
                                    switch $0 {
                                    case .clear:
                                        break
                                    case .dismiss:
                                        viewModel.event(.history(.filter(.dismissCalendar)))
                                    }
                                },
                                config: .iVortex,
                                apply: { lowerDate, upperDate in
                                    
                                    if let lowerDate = lowerDate,
                                       let upperDate = upperDate {
                                    
                                        filter.event(.selectedDates(lowerDate...upperDate, .dates))
                                    }
                                    
                                    viewModel.event(.history(.filter(.dismissCalendar)))
                                }
                            )
                            .navigationBarWithBack(
                                title: "Выберите даты или период",
                                dismiss: {
                                viewModel.event(.history(.filter(.dismissCalendar)))
                            })
                        }
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func navLinkDestination(
        link: ProductProfileViewModel.Link
    ) -> some View {
        
        switch link {
        case let .anyway(node):
            let payload = node.model.state.content.state.transaction.context.outline.payload
            
            viewFactory.components.makeAnywayFlowView(node.model)
                .navigationBarWithAsyncIcon(
                    title: payload.title,
                    subtitle: payload.subtitle,
                    dismiss: viewModel.closeAction,
                    icon: viewFactory.iconView(payload.icon),
                    style: .normal
                )
            
        case let .controlPanel(controlPanelViewModel):
            viewFactory.components.makeControlPanelWrapperView(controlPanelViewModel)
                .edgesIgnoringSafeArea(.bottom)
            
        case let .productInfo(viewModel):
            InfoProductView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
            
        case let .productStatement(viewModel):
            ProductStatementView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Выписка по счету")
            
        case let .meToMeExternal(viewModel):
            MeToMeExternalView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Пополнить со счета в другом банке")
                .navigationBarItems(
                    trailing: Image(uiImage: UIImage(named: "logo-spb-mini") ?? UIImage())
                )
            
        case let .myProducts(viewModel):
            MyProductsView(
                viewModel: viewModel,
                viewFactory: viewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
            
        case let .paymentsTransfers(node):
            PaymentsTransfersView(
                viewModel: node.model,
                viewFactory: viewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
            
        case let .payment(viewModel):
            viewFactory.components.makePaymentsView(viewModel)
            
        case let .paymentsTransfersSwitcher(switcher):
            viewFactory.components.makePaymentsTransfersSwitcherView(switcher)
        }
    }
    
    @ViewBuilder
    private func bottomSheetContent(
        sheet: ProductProfileViewModel.BottomSheet
    ) -> some View {
        
        switch sheet.type {
        case let .operationDetail(operationDetail):
            viewFactory.components.makeOperationDetailView(operationDetail, productProfileViewFactory.makeRepeatButtonView, { viewModel.payment(operationID: operationDetail.operationId, productStatement: operationDetail.productStatement) })
            
        case let .optionsPannel(viewModel):
            ProductProfileOptionsPannelView(viewModel: viewModel)
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 72)
            
        case let .optionsPanelNew(items):
            PanelView(items: items, event: viewModel.event)
                .padding(.horizontal, 12)
                .padding(.top, 26)
                .padding(.bottom, 72)
                .fixedSize(horizontal: false, vertical: true)

        case let .meToMeLegacy(viewModel):
            MeToMeView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
                .frame(height: 474)
            
        case let .meToMe(viewModel):
            viewFactory.components.makePaymentsMeToMeView(viewModel)
                .fullScreenCover(item: $viewModel.success) {
                    
                    viewFactory.components.makePaymentsSuccessView($0)
                    
                }.transaction { transaction in
                    transaction.disablesAnimations = false
                }
            
        case let .printForm(viewModel):
            PrintFormView(viewModel: viewModel)
            
        case let .placesMap(viewModel):
            PlacesView(viewModel: viewModel)
            
        case let .info(viewModel):
            OperationDetailInfoView(
                viewModel: viewModel
            )
        }
    }
        
    @ViewBuilder
    private func fullScreenCoverContent(
        state: ProductProfileViewModel.FullScreenCoverState
    ) -> some View {
        
        switch state {
        case let .changePin(changePIN):
            ZStack {
                Color.white
                    .ignoresSafeArea()
                changePinCodeView(
                    cardId: changePIN.cardId,
                    actionType: .changePin(changePIN.displayNumber),
                    changePIN.model,
                    confirm: viewModel.confirmShowCVV,
                    confirmChangePin: viewModel.confirmChangePin,
                    showSpinner: {},
                    resendRequest: changePIN.request,
                    resendRequestAfterClose: viewModel.closeLinkAndResendRequest
                )
                .transition(.move(edge: .leading))
            }
        case let .confirmOTP(confirm):
            
            confirmCodeView(
                phoneNumber: confirm.phone,
                cardId: confirm.cardId,
                actionType: confirm.action,
                reset: { viewModel.fullScreenCoverState = nil },
                showSpinner: {},
                resendRequest: confirm.request,
                resendRequestAfterClose: viewModel.closeLinkAndResendRequest
            ).transition(.move(edge: .leading))
            
        case let .successChangePin(viewModel):
            
            viewFactory.components.makePaymentsSuccessView(viewModel)
                .transaction { transaction in
                    transaction.disablesAnimations = false
                }
            
        case let .successZeroAccount(viewModel):
            
            viewFactory.components.makePaymentsSuccessView(viewModel)
                .transaction { transaction in
                    transaction.disablesAnimations = false
                }
        }
    }
    
    private func changePinCodeView(
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction,
        _ viewModel: PinCodeViewModel,
        confirm: @escaping (OtpDomain.Otp, @escaping (ErrorDomain?) -> Void) -> Void,
        confirmChangePin:  @escaping  (ConfirmViewModel.ChangePinStruct, @escaping (ErrorDomain?) -> Void) -> Void,
        showSpinner: @escaping () -> Void,
        resendRequest: @escaping () -> Void,
        resendRequestAfterClose: @escaping (CardDomain.CardId, ConfirmViewModel.CVVPinAction) -> Void
    ) -> some View {
        
        let buttonConfig: PinCodeUI.ButtonConfig = .init(
            font: .textH1R24322(),
            textColor: .textSecondary,
            buttonColor: .mainColorsGrayLightest
        )
        
        let pinConfig: PinCodeView.PinCodeConfig = .init(
            font: .textH4M16240(),
            foregroundColor: .textSecondary,
            colorsForPin: .init(
                normal: .mainColorsGrayMedium,
                incorrect: .systemColorError,
                correct: .systemColorActive,
                printing: .mainColorsBlack)
        )
        
        return PinCodeChangeView(
            config: .init(
                buttonConfig: buttonConfig,
                pinCodeConfig: pinConfig
            ),
            viewModel: viewModel,
            confirmationView: { phone, code in
                
                ConfirmCodeView(
                    phoneNumber: .init(phone.value),
                    newPin: code,
                    cardId: cardId,
                    actionType: actionType,
                    reset: viewModel.resetState,
                    resendRequest: resendRequest,
                    handler: confirm,
                    handlerChangePin: confirmChangePin,
                    showSpinner: showSpinner,
                    resendRequestAfterClose: resendRequestAfterClose
                )
            }
        )
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("")
    }
    
    private func confirmCodeView(
        phoneNumber: PhoneDomain.Phone,
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction,
        reset: @escaping () -> Void,
        showSpinner: @escaping () -> Void,
        resendRequest: @escaping () -> Void,
        resendRequestAfterClose: @escaping (CardDomain.CardId, ConfirmViewModel.CVVPinAction) -> Void
    ) -> some View {
        
        ConfirmCodeView(
            phoneNumber: phoneNumber,
            cardId: cardId,
            actionType: actionType,
            reset: reset,
            resendRequest: resendRequest,
            hasDefaultBackButton: false,
            handler: viewModel.confirmShowCVV,
            handlerChangePin: nil,
            showSpinner: showSpinner,
            resendRequestAfterClose: resendRequestAfterClose
        )
    }
    
    @ViewBuilder
    private func sheetContent(
        sheet: ProductProfileViewModel.Sheet
    ) -> some View {
        
        switch sheet.type {
        case let .printForm(viewModel):
            PrintFormView(viewModel: viewModel)
            
        case let .placesMap(viewModel):
            PlacesView(viewModel: viewModel)
        }
    }
}

// MARK: - Internal Views

extension ProductProfileView {
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

private extension ProductProfileView {

    func filler() -> some View {
        
        GeometryReader { geometry in
            
            let geoY = geometry.frame(in: .global).minY
            
            let condition = geoY <= 0
            let height = offsetHeight + (condition ? 0 : geoY)
            let offsetY = condition ? geoY / 9 : -geoY
            
            accentColor
                .frame(width: geometry.size.width, height: height)
                .offset(y: offsetY)
        }
    }
    
    @ViewBuilder
    func historyView() -> some View {
    
        if let historyViewModel = viewModel.history {
            
            ProductProfileHistoryView(
                viewModel: historyViewModel,
                makeHistoryButton: { isHistoryLoading in
                    
                    if isHistoryLoading {
                        return historyButton()
                        
                    } else {
                        return nil
                    }
                }
            )
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func historyButton() -> HistoryButtonView? {
    
        productProfileViewFactory.makeHistoryButton(
            {
                viewModel.event(.button($0))
            },{
                viewModel.filterState.filter.selectedServices.isEmpty == false || viewModel.filterState.filter.selectedTransaction != nil || viewModel.filterState.filter.selectedPeriod == .week || viewModel.filterState.filter.selectDates != nil
            },{
                return (viewModel.filterState.calendar.range?.lowerDate != nil && viewModel.filterState.filter.selectDates == nil) && viewModel.filterState.filter.selectedTransaction == nil &&
                viewModel.filterState.filter.selectedServices.isEmpty
            }, {
                
                viewModel.filterState.filter.selectedServices = []
                viewModel.filterState.filter.selectedTransaction = nil
                viewModel.filterState.filter.selectedPeriod = .month
                viewModel.filterState.filter.selectDates = nil
                viewModel.filterState.calendar.range = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.viewModel.history?.action.send(
                        ProductProfileHistoryViewModelAction.Filter(
                            filterState: viewModel.filterState,
                            period: (
                                lowerDate: .distantPast,
                                upperDate: Date()
                            ))
                    )
                }
            })
    }
    
    @ViewBuilder
    func productProfileDetailView() -> some View {
        
        viewModel.detail.map {
            
            ProductProfileDetailView(viewModel: $0)
                .padding(.horizontal, 20)
        }
    }
    
    func content() -> some View {
        
        VStack(spacing: 12) {
            
            ProductProfileCardView(
                viewModel: viewModel.product,
                makeSliderActivateView: productProfileViewFactory.makeActivateSliderView,
                makeSliderViewModel: viewModel.makeSliderViewModel()
            )
            
            VStack(spacing: 32) {
                
                ProductProfileButtonsView(viewModel: viewModel.buttons)
                    .padding(.horizontal, 20)
                
                productProfileDetailView()
                
                historyView()
            }
        }
    }

    @ViewBuilder
    func spinner() -> some View {
    
        viewModel.spinner.map { spinner in
            
            SpinnerView(viewModel: spinner)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(.greatestFiniteMagnitude)
        }
    }
    
    @ViewBuilder
    func historySheet() -> some View {
        
        if viewModel.historyState != nil {
            
            Color.clear
                .sheet(
                    modal: viewModel.historyState?.showSheet,
                    dismiss: { viewModel.event(.history(.dismiss)) },
                    content: historySheetContent
                )
        }
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            productProfileView(viewModel: .sample)
            productProfileView(viewModel: .sadSample)
        }
    }
    
    private static func productProfileView(
        viewModel: ProductProfileViewModel
    ) -> some View {
        
        ProductProfileView(
            viewModel: viewModel,
            viewFactory: .preview,
            productProfileViewFactory: .init(
                makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                makeHistoryButton: { .init(event: $0, isFiltered: $1, isDateFiltered: $2, clearOptions: $3) },
                makeRepeatButtonView: { _ in .init(action: { }) }
            ),
            getUImage: { _ in nil }
        )
    }
}

// MARK: - Preview Content

extension ProductProfileViewModel {
    
    static let sample = ProductProfileViewModel(
        navigationBar: NavigationBarView.ViewModel.sampleNoActionButton,
        product: .sample,
        buttons: .sample,
        detail: .sample,
        history: nil,
        fastPaymentsFactory: .legacy,
        makePaymentsTransfersFlowManager: { _ in .preview },
        userAccountNavigationStateManager: .preview,
        sberQRServices: .empty(),
        productProfileServices: .preview,
        qrViewModelFactory: .preview(),
        paymentsTransfersFactory: .preview,
        operationDetailFactory: .preview,
        productNavigationStateManager: .preview,
        cvvPINServicesClient: HappyCVVPINServicesClient(),
        filterHistoryRequest: { _,_,_,_ in },
        makeOpenNewProductButtons: { _ in [] },
        productProfileViewModelFactory: .preview,
        filterState: .preview,
        rootView: ""
    )
    
    static let sadSample = ProductProfileViewModel(
        navigationBar: NavigationBarView.ViewModel.sampleNoActionButton,
        product: .sample,
        buttons: .sample,
        detail: .sample,
        history: nil,
        fastPaymentsFactory: .legacy,
        makePaymentsTransfersFlowManager: { _ in .preview },
        userAccountNavigationStateManager: .preview,
        sberQRServices: .empty(),
        productProfileServices: .preview,
        qrViewModelFactory: .preview(),
        paymentsTransfersFactory: .preview,
        operationDetailFactory: .preview,
        productNavigationStateManager: .preview,
        cvvPINServicesClient: SadCVVPINServicesClient(),
        filterHistoryRequest: { _,_,_,_ in },
        makeOpenNewProductButtons: { _ in [] },
        productProfileViewModelFactory: .preview,
        filterState: .preview,
        rootView: ""
    )
}

extension NavigationBarView.ViewModel {
    
    static let sampleNoActionButton = NavigationBarView.ViewModel(
        title: "Platinum", subtitle: "· 4329",
        leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
        rightItems: [],
        background: .purple, foreground: .iconWhite
    )
}

extension QRViewModel {
    
    static func preview(
        closeAction: @escaping () -> Void
    ) -> QRViewModel {
        
        .init(
            closeAction: closeAction,
            qrResolve: { _ in .unknown },
            scanner: QRScannerView.ViewModel()
        )
    }
}

extension OperationDetailFactory {
    
    static let preview: Self = .init(makeOperationDetailViewModel: { _,_,_ in
            .sampleComplete
    })
}

extension Date {
    
    static func startDayOfCalendar() -> Date {
        var today = Date.date(Date(), addDays: -30)!
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = gregorian.dateComponents([.timeZone, .year, .month, .day, .hour, .minute,.second], from: today)

        components.hour = 0
        components.minute = 0
        components.second = 0

        today = gregorian.date(from: components)!
        
        return today
    }
}

//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import ActivateSlider
import ForaTools
import InfoComponent
import PinCodeUI
import RxViewModel
import SberQR
import SwiftUI
import CalendarUI

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    let viewFactory: PaymentsTransfersViewFactory
    let productProfileViewFactory: ProductProfileViewFactory
    let getUImage: (Md5hash) -> UIImage?
    
    var accentColor: some View {
        
        return viewModel.accentColor.overlay(Color(hex: "1с1с1с").opacity(0.3))
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView {
                
                ZStack {
                    
                    Group {
                        
                        GeometryReader { geometry in
                            
                            ZStack {
                                
                                if geometry.frame(in: .global).minY <= 0 {
                                    
                                    accentColor
                                        .frame(width: geometry.size.width, height: 204 - 48)
                                        .offset(y: geometry.frame(in: .global).minY / 9)
                                        .clipped()
                                    
                                } else {
                                    
                                    accentColor
                                        .frame(width: geometry.size.width, height: 204 - 48 + geometry.frame(in: .global).minY)
                                        .clipped()
                                        .offset(y: -geometry.frame(in: .global).minY)
                                }
                            }
                        }
                    }
                    .zIndex(0)
                    
                    VStack(spacing: 12) {
                        
                        ProductProfileCardView(
                            viewModel: viewModel.product,
                            makeSliderActivateView: productProfileViewFactory.makeActivateSliderView,
                            makeSliderViewModel: viewModel.makeSliderViewModel()
                        )
                        
                        VStack(spacing: 32) {
                            
                            ProductProfileButtonsView(viewModel: viewModel.buttons)
                                .padding(.horizontal, 20)
                            
                            if let detailAccount = viewModel.detail {
                                
                                ProductProfileDetailView(viewModel: detailAccount)
                                    .padding(.horizontal, 20)
                            }
                            
                            if let historyViewModel = viewModel.history {
                                
                                ProductProfileHistoryView(
                                    viewModel: historyViewModel,
                                    makeHistoryButton: { isHistoryLoading in
                                        
                                        if isHistoryLoading {
                                            
                                            return productProfileViewFactory.makeHistoryButton(
                                                {
                                                    viewModel.event(.history($0))
                                                },{
                                                    viewModel.filterState?.selectedServices.isEmpty == false || viewModel.filterState?.selectedTransaction != nil || viewModel.filterState?.selectedPeriod == .week
                                                },{
                                                    return viewModel.filterState?.selectDates?.lowerDate != nil
                                                    
                                                }, {
                                                    
                                                    self.viewModel.history?.action.send(ProductProfileHistoryViewModelAction.Filter(filterState: viewModel.filterState, period: (lowerDate: nil, upperDate: nil)))
                                                    viewModel.filterState?.selectedServices = []
                                                    viewModel.filterState?.selectedTransaction = nil
                                                    viewModel.filterState?.selectedPeriod = .month
                                                    viewModel.filterState?.selectDates = nil
                                                })
                                        } else {
                                            return nil
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.top, 56 - 48)
                    .zIndex(1)
                }
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: -geo.frame(in: .named("scroll")).origin.y)
                    
                })
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    
                    if offset < -100 {
                        
                        viewModel.action.send(ProductProfileViewModelAction.PullToRefresh())
                    }
                }
                
            }.coordinateSpace(name: "scroll")
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                viewModel.link.map(navLinkDestination)
            }
            
            // workaround to fix mini-cards jumps when product name editing alert presents
            Color.clear
                .textfieldAlert(alert: $viewModel.textFieldAlert)
               
            if viewModel.historyState?.showSheet == true {
                
                historySheet()
            }
            
            viewModel.closeAccountSpinner.map(CloseAccountSpinnerView.init)
            
            viewModel.spinner.map { spinner in
                
                VStack {
                    SpinnerView(viewModel: spinner)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(.greatestFiniteMagnitude)
            }
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
    
    private func historySheet() -> some View {
        
        Color.clear
            .sheet(
                modal: viewModel.historyState,
                dismissModal: { viewModel.historyState?.showSheet = false },
                content: { _ in historySheetContent() }
            )
    }
    
    private func historySheetContent() -> some View {
        
        VStack(spacing: 15) {
            
            if let state = viewModel.historyState {
                
                switch state.buttonAction {
                case .calendar:
                    
                    CalendarWrapperView(
                        state: .init(
                            date: Date(),
                            range: .init(),
                            monthsData: .generate(startDate: viewModel.calendarDayStart()),
                            periods: []
                        ),
                        config: .iFora
                    )
                    
                case .filter:
                    if let filterState = self.viewModel.filterState {
                                             
                        FilterView(
                            filterState: .init(
                                title: filterState.title,
                                selectDates: state.selectedDates,
                                selectedPeriod: filterState.selectedPeriod,
                                selectedTransaction: filterState.selectedTransaction,
                                selectedServices: filterState.selectedServices,
                                periods: filterState.periods,
                                transactionType: filterState.transactionType,
                                services: viewModel.historyCategories()
                            ),
                            event: { event in
                                
                                self.viewModel.filterState?.services = self.viewModel.historyCategories()
                                self.viewModel.event(.filter(event))
                                
                            },
                            config: .iFora,
                            makeButtonsContainer: { applyAction, state in
                                .init(
                                    applyAction: {
//                                        applyAction()
                                        
                                        self.viewModel.filterState?.selectedServices = state.selectedServices
                                        self.viewModel.filterState?.selectedPeriod = state.selectedPeriod
                                        self.viewModel.filterState?.selectedTransaction = state.selectedTransaction
                                        
                                        self.viewModel.event(.history(.dismiss))
                                                                            
                                        self.viewModel.history?.action.send(ProductProfileHistoryViewModelAction.Filter(
                                            filterState: viewModel.filterState,
                                            period: (lowerDate: nil, upperDate: nil)
                                        ))
                                        
                                        self.viewModel.history?.action.send(ModelAction.Statement.List.Request(
                                            productId: viewModel.product.activeProductId,
                                            direction: .custom(start: Date(), end: Date()),
                                            category: filterState.selectedServices.map({ $0 })
                                        ))
                                    },
                                    clearOptionsAction: {
                                        self.viewModel.event(.filter(.clearOptions))
                                        self.viewModel.filterState = nil
                                        self.viewModel.action.send(ModelAction.Statement.List.Request(productId: viewModel.product.activeProductId, direction: .latest, category: nil))
                                    },
                                    config: .init(
                                        clearButtonTitle: "Очистить",
                                        applyButtonTitle: "Применить"
                                    )
                                )
                            },
                            clearOptionsAction: {
                                self.viewModel.event(.history(.clearOptions))
                            },
                            dismissAction: {
                                self.viewModel.action.send(ProductProfileHistoryViewModelAction.Filter(filterState: viewModel.filterState, period: (lowerDate: nil, upperDate: nil)))
                                self.viewModel.event(.history(.dismiss))
                            }, calendarViewAction: {
                                
                                self.viewModel.event(.history(.button(.calendar({ lowerDate, upperDate in
                                    self.viewModel.event(.history(.button(.filter(lowerDate, upperDate))))
                                }))))
                            }
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func navLinkDestination(
        link: ProductProfileViewModel.Link
    ) -> some View {
        
        switch link {
        case let .controlPanel(controlPanelViewModel):
            ControlPanelWrapperView(
                viewModel: controlPanelViewModel,
                config: .default, 
                getUImage: getUImage)
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
        
        case let .payment(paymentViewModel):
            PaymentsView(viewModel: paymentViewModel)
            
        case let .paymentsTransfers(viewModel):
            PaymentsTransfersView(
                viewModel: viewModel,
                viewFactory: viewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
        }
    }
    
    @ViewBuilder
    private func bottomSheetContent(
        sheet: ProductProfileViewModel.BottomSheet
    ) -> some View {
        
        switch sheet.type {
        case let .operationDetail(viewModel):
                OperationDetailView(
                    viewModel: viewModel,
                    makeRepeatButtonView: self.productProfileViewFactory.makeRepeatButtonView,
                    payment: {
                        if let operationId = viewModel.operationId {
                            
                            self.viewModel.productProfileServices.repeatPayment.createInfoRepeatPaymentServices(.init(paymentOperationDetailId: operationId)) { result in
                                
                                switch result {
                                case let .success(infoPayment):
                                    switch infoPayment.type {
                                        
                                    case .betweenTheir:
                                        if let transfer = infoPayment.parameterList.last,
                                           let productId = transfer.payeeInternal?.cardId ?? transfer.payeeInternal?.accountId,
                                           let product = viewModel.model.products.value.flatMap({ $0.value }).first(where: { $0.id == productId }),
                                           let amount = transfer.amount,
                                           let paymentViewModel = PaymentsMeToMeViewModel.init(Model.shared, mode: .makePaymentTo(product, amount)) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                
                                                self.viewModel.bottomSheet = .init(type: .meToMe(paymentViewModel))
                                            }
                                        }
                                        
                                    case .direct, .contactAddressless:
                                        
                                        if let transfer = infoPayment.parameterList.last,
                                           let additional = transfer.additional,
                                           let phone = transfer.additional?.first(where: { $0.fieldname == "RECP"})?.fieldvalue,
                                           let countryId = transfer.additional?.first(where: { $0.fieldname == "trnPickupPoint"})?.fieldvalue {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self.viewModel.link = .payment(.init(source: .direct(
                                                    phone: phone,
                                                    countryId: countryId,
                                                    serviceData: .init(
                                                        additionalList: additional.map({ PaymentServiceData.AdditionalListData(
                                                            fieldTitle: $0.fieldname,
                                                            fieldName: $0.fieldname,
                                                            fieldValue: $0.fieldvalue,
                                                            svgImage: ""
                                                        )}),
                                                        amount: transfer.amount ?? 0,
                                                        date: Date(),
                                                        paymentDate: "",
                                                        puref: transfer.puref ?? "",
                                                        type: .internet,
                                                        lastPaymentName: nil
                                                    )
                                                ), model: Model.shared, closeAction: {
                                                    self.viewModel.link = nil
                                                }))
                                            }
                                        }
                                    case .externalEntity, .externalIndivudual:
                                            if let transfer = infoPayment.parameterList.last,
                                               let inn = transfer.payeeExternal?.inn,
                                               let bankBic = transfer.payeeExternal?.bankBIC,
                                               let amount = transfer.amount?.description,
                                               let accountNumber = transfer.payeeExternal?.accountNumber {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                    self.viewModel.link = .payment(.init(source: .repeatPaymentRequisites(
                                                        accountNumber: accountNumber,
                                                        bankId: bankBic,
                                                        inn: inn, 
                                                        kpp: transfer.payeeExternal?.kpp,
                                                        amount: amount,
                                                        productId: transfer.payer?.cardId ?? transfer.payer?.accountId,
                                                        comment: transfer.comment
                                                    ), model: Model.shared, closeAction: {
                                                        self.viewModel.link = nil
                                                    }))
                                                }
                                            }
                                    case .insideBank:
                                        
                                        if let transfer = infoPayment.parameterList.last,
                                           let phone = transfer.additional?.first(where: { $0.fieldname == "RECP"})?.fieldvalue,
                                           let countryId = transfer.additional?.first(where: { $0.fieldname == "trnPickupPoint"})?.fieldvalue {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self.viewModel.link = .payment(.init(source: .sfp(phone: phone, bankId: countryId, amount: nil, productId: self.viewModel.product.activeProductId), model: Model.shared, closeAction: {
                                                    self.viewModel.link = nil
                                                }))
                                            }
                                        }
                                    case .internet, .transport, .housingAndCommunalService:
                                        if let transfer = infoPayment.parameterList.first,
                                           let puref = transfer.puref,
                                           let amount = infoPayment.parameterList.first?.amount ?? infoPayment.parameterList.last?.amount,
                                           let additional = transfer.additional {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                
                                                self.viewModel.link = .payment(.init(source: .servicePayment(
                                                    puref: puref,
                                                    additionalList: additional.map{ .init(fieldTitle: $0.fieldname, fieldName: $0.fieldname, fieldValue: $0.fieldvalue, svgImage: nil )},
                                                    amount: amount
                                                ), model: Model.shared, closeAction: {
                                                    self.viewModel.link = nil
                                                }))
                                            }
                                        }
                                        
                                    case .otherBank:
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1300)) {
                                            
                                            self.viewModel.link = .payment(.init(Model.shared, service: .toAnotherCard, closeAction: {
                                                self.viewModel.link = nil
                                            }))
                                        }
                                        
                                    case .byPhone:
                                        if let phone = infoPayment.parameterList.last?.payeeInternal?.phoneNumber,
                                           let amount = infoPayment.parameterList.last?.amount?.description {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self.viewModel.link = .payment(.init(source: .sfp(phone: phone, bankId: ForaBank.BankID.foraBankID.digits, amount: amount, productId: self.viewModel.product.activeProductId), model: Model.shared, closeAction: {
                                                    self.viewModel.link = nil
                                                }))
                                            }
                                        }
                                    case .sfp:
                                        if let transfer = infoPayment.parameterList.last,
                                           let phone = transfer.additional?.first(where: { $0.fieldname == "RecipientID"})?.fieldvalue,
                                           let bankId = transfer.additional?.first(where: { $0.fieldname == "BankRecipientID"})?.fieldvalue,
                                           let amount = transfer.amount?.description {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self.viewModel.link = .payment(.init(source: .sfp(phone: phone, bankId: bankId, amount: amount, productId: self.viewModel.product.activeProductId), model: Model.shared, closeAction: {
                                                    self.viewModel.link = nil
                                                }))
                                            }
                                        }
                                    case .mobile:
                                        
                                        if let transfer = infoPayment.parameterList.last,
                                           let phone = transfer.additional?.first(where: { $0.fieldname == "a3_NUMBER_1_2"})?.fieldvalue,
                                           let amount = transfer.amount?.description {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                
                                                self.viewModel.link = .payment(.init(source: .mobile(
                                                    phone: "7\(phone)",
                                                    amount: amount,
                                                    productId: transfer.payer?.cardId ?? transfer.payer?.accountId
                                                ), model: Model.shared, closeAction: {
                                                    self.viewModel.link = nil
                                                }))
                                            }
                                        }
                                    case .taxes:
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1300)) {
                                            
                                            self.viewModel.link = .payment(.init(source: .taxes(parameterData: nil), model: Model.shared, closeAction: {
                                                self.viewModel.link = nil
                                            }))
                                        }
                                    }
                                    
                                case let .failure(error):
                                    print(error)
                                }
                            }
                            
                            self.viewModel.bottomSheet = nil
                        }
                    }
                )
            
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
            PaymentsMeToMeView(viewModel: viewModel)
                .fullScreenCover(item: $viewModel.success) {
                    
                    PaymentsSuccessView(viewModel: $0)
                    
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
            
            PaymentsSuccessView(viewModel: viewModel)
                .transaction { transaction in
                    transaction.disablesAnimations = false
                }
            
        case let .successZeroAccount(viewModel):
            
            PaymentsSuccessView(viewModel: viewModel)
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
        history: .sampleHistory,
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
        productProfileViewModelFactory: .preview,
        rootView: ""
    )
    
    static let sadSample = ProductProfileViewModel(
        navigationBar: NavigationBarView.ViewModel.sampleNoActionButton,
        product: .sample,
        buttons: .sample,
        detail: .sample,
        history: .sampleHistory,
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
        productProfileViewModelFactory: .preview,
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
            qrResolve: QRViewModel.ScanResult.init
        )
    }
}

extension OperationDetailFactory {
    
    static let preview: Self = .init(makeOperationDetailViewModel: { _,_,_ in
            .sampleComplete
    })
}

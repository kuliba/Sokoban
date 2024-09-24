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
                                                    viewModel.event(.button($0))
                                                },{
                                                    viewModel.filterState.filter.selectedServices.isEmpty == false || viewModel.filterState.filter.selectedTransaction != nil || viewModel.filterState.filter.selectedPeriod == .week || viewModel.filterState.filter.selectDates != nil
                                                },{
                                                    return (viewModel.filterState.calendar.range?.lowerDate != nil && viewModel.filterState.filter.selectDates == nil)
                                                }, {
                                                    
                                                    self.viewModel.history?.action.send(ProductProfileHistoryViewModelAction.Filter(filterState: viewModel.filterState, period: (lowerDate: nil, upperDate: nil)))
                                                    viewModel.filterState.filter.selectedServices = []
                                                    viewModel.filterState.filter.selectedTransaction = nil
                                                    viewModel.filterState.filter.selectedPeriod = .month
                                                    viewModel.filterState.filter.selectDates = nil
                                                    viewModel.filterState.calendar.range = .init()
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
               
            if viewModel.historyState != nil {
                
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
                modal: viewModel.historyState?.showSheet,
                dismissModal: { viewModel.event(.history(.dismiss)) },
                content: historySheetContent
            )
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
                            startDate: Date.date(Date(), addDays: -31),
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
                    config: .iFora,
                    apply: { lowerDate, upperDate in
                        if let lowerDate = lowerDate,
                           let upperDate = upperDate {
                            
                            viewModel.filterState.calendar.range = .init(startDate: lowerDate, endDate: upperDate)
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
                    title: "Выберите период",
                    dismiss: {
                    viewModel.event(.history(.filter(.dismissCalendar)))
                })
                
            case let .filter(filter):
                    
                NavigationView {
                    
                    FilterWrapperView(
                        model: filter,
                        config: .iFora
                    ) {
                        viewModel.event(.history(.filter(.period($0))))
                    } buttonsView: {
                        ButtonsContainer(
                            applyAction: {
                                
                                viewModel.event(.updateFilter(filter.state))
                            },
                            clearOptionsAction: {
                                filter.event(.clearOptions)
                            },
                            config: .init(
                                clearButtonTitle: "Очистить",
                                applyButtonTitle: "Применить"
                            )
                        )
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(
                        destination: viewModel.historyState?.calendarState,
                        dismissDestination: { viewModel.event(.history(.filter(.dismissCalendar))) },
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
                                config: .iFora,
                                apply: { lowerDate, upperDate in
                                    
                                    if let lowerDate, let upperDate {
                                    
                                        filter.event(.selectedDates(lowerDate..<upperDate, .dates))
                                    }
                                    
                                    viewModel.event(.history(.filter(.dismissCalendar)))
                                }
                            )
                            .navigationBarWithBack(
                                title: "Выберите период",
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
            
        case let .paymentsTransfers(node):
            PaymentsTransfersView(
                viewModel: node.model,
                viewFactory: viewFactory, 
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
        case let .payment(viewModel):
            PaymentsView(viewModel: viewModel)
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
                                        
                                        let paymentViewModels = infoPayment.parameterList.compactMap { transfer -> PaymentsMeToMeViewModel? in
                                            let allProducts = viewModel.model.products.value.flatMap({ $0.value })
                                            
                                            if let payeeInternalId = transfer.payeeInternal?.cardId ?? transfer.payeeInternal?.accountId,
                                               let product = allProducts.first(where: { $0.id == payeeInternalId }),
                                               let amount = transfer.amount,
                                               let paymentViewModel = PaymentsMeToMeViewModel(Model.shared, mode: .makePaymentTo(product, amount)) {
                                                
                                                return paymentViewModel
                                            }
                                            
                                            if let payerId = transfer.payer?.cardId ?? transfer.payer?.accountId,
                                               let product = allProducts.first(where: { $0.id == payerId }),
                                               let amount = transfer.amount,
                                               let paymentViewModel = PaymentsMeToMeViewModel(Model.shared, mode: .makePaymentTo(product, amount)) {
                                                
                                                return paymentViewModel
                                            }
                                            
                                            return nil
                                        }
                                        
                                        if let firstPaymentViewModel = paymentViewModels.first {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1300)) {
                                                self.viewModel.bottomSheet = .init(type: .meToMe(firstPaymentViewModel))
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
                                           let bankBic = transfer.payeeExternal?.bankBIC,
                                           let amount = transfer.amount?.description,
                                           let accountNumber = transfer.payeeExternal?.accountNumber {
                                            
                                            let inn: String = transfer.payeeExternal?.inn ?? ""
                                            
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
                                           let amount = infoPayment.parameterList.first?.amount ?? infoPayment.parameterList.last?.amount {
                                            
                                            let additionalList: [PaymentServiceData.AdditionalListData]? = transfer.additional?.map {
                                                .init(fieldTitle: $0.fieldname, fieldName: $0.fieldname, fieldValue: $0.fieldvalue, svgImage: nil)
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                
                                                self.viewModel.link = .payment(.init(source: .servicePayment(
                                                    puref: puref,
                                                    additionalList: additionalList,
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
        filterHistoryRequest: { _,_,_,_ in },
        productProfileViewModelFactory: .preview,
        filterState: .preview,
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
        filterHistoryRequest: { _,_,_,_ in },
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
            qrResolve: { _ in .unknown }
        )
    }
}

extension OperationDetailFactory {
    
    static let preview: Self = .init(makeOperationDetailViewModel: { _,_,_ in
            .sampleComplete
    })
}

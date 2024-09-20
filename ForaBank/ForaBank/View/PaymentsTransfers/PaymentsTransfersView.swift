//
//  Payments&TransfersView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import AnywayPaymentDomain
import ActivateSlider
import Combine
import InfoComponent
import OperatorsListComponents
import PaymentComponents
import SberQR
import SwiftUI
import TextFieldModel
import UIPrimitives

struct PaymentsTransfersView: View {
    
    @ObservedObject var viewModel: PaymentsTransfersViewModel
    
    let viewFactory: PaymentsTransfersViewFactory
    let productProfileViewFactory: ProductProfileViewFactory
    let getUImage: (Md5hash) -> UIImage?
    
    var body: some View {
        
        content()
            .onAppear {
                viewModel.action.send(PaymentsTransfersViewModelAction.ViewDidApear())
            }
            .modal(
                viewModel.route.modal,
                dismiss: { viewModel.event(.dismiss(.modal)) },
                serviceFailureAlert: serviceFailureAlert,
                bottomSheetContent: bottomSheetView,
                fullScreenContent: { fullScreenCover in
                    
                    fullScreenCoverView(
                        fullScreenCover: fullScreenCover,
                        goToMain: { viewModel.event(.outside(.goToMain)) }
                    )
                },
                sheetContent: sheetView
            )
            .navigationDestination(
                item: .init(
                    get: { viewModel.route.destination },
                    set: { if $0 == nil { viewModel.event(.dismiss(.destination)) }}
                ),
                content: destinationView(link:)
            )
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: leadingBarItems,
                trailing: trailingBarItems
            )
    }
}

private extension View {
    
    @ViewBuilder
    func modal(
        _ modal: PaymentsTransfersViewModel.Modal?,
        dismiss: @escaping () -> Void,
        serviceFailureAlert: @escaping (ServiceFailureAlert) -> Alert,
        bottomSheetContent: @escaping (PaymentsTransfersViewModel.BottomSheet) -> some View,
        fullScreenContent: @escaping (PaymentsTransfersViewModel.FullScreenSheet) -> some View,
        sheetContent: @escaping (PaymentsTransfersViewModel.Sheet) -> some View
    ) -> some View {
        
        switch modal {
        case .none:
            self
            
        case let .alert(viewModel):
            alert(
                item: viewModel,
                content: Alert.init(with:)
            )
        case let .serviceAlert(serviceAlert):
            alert(
                item: serviceAlert,
                content: serviceFailureAlert
            )
        case let .bottomSheet(bottom):
            bottomSheet(
                sheet: bottom,
                dismiss: dismiss,
                content: bottomSheetContent
            )
        case let .fullScreenSheet(cover):
            fullScreenCover(
                cover: cover,
                dismissFullScreenCover: dismiss,
                content: fullScreenContent
            )
        case let .sheet(modal):
            sheet(
                modal: modal,
                dismissModal: dismiss,
                content: sheetContent
            )
        }
    }
}

extension PaymentsTransfersView {
    
    private func content() -> some View {
        
        VStack() {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                ForEach(viewModel.sections, content: sectionView)
            }
        }
    }
    
    private func serviceFailureAlert(
        _ alert: ServiceFailureAlert
    ) -> Alert {
        
        let title = "Ошибка"
        let message: String = {
            
            switch alert.serviceFailure {
            case .connectivityError:
                return "Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже."
                
            case let .serverError(message):
                return message
            }
        }()
        
        return Alert(with: .init(
            title: title,
            message: message,
            primary: .init(
                type: .default,
                title: "OK",
                action: { viewModel.event(.dismiss(.modal)) }
            )
        ))
    }
    
    @ViewBuilder
    private func sectionView(
        section: PaymentsTransfersSectionViewModel
    ) -> some View {
        
        switch section {
        case let disableInfoViewModel as DisableForCorCardsPTViewModel:
            viewFactory.makeInfoViews.makeDisableCorCardsInfoView(.disableForCorCards)
                .padding(.horizontal, 16)
            
        case let updateInfo as UpdateInfoPTViewModel:
            viewFactory.makeInfoViews.makeUpdateInfoView(.updateInfoText)
            
        case let latestPaymentsSectionVM as PTSectionLatestPaymentsView.ViewModel:
            PTSectionLatestPaymentsView(viewModel: latestPaymentsSectionVM)
            
        case let transfersSectionVM as PTSectionTransfersView.ViewModel:
            PTSectionTransfersView(viewModel: transfersSectionVM)
            
        case let payGroupSectionVM as PTSectionPaymentsView.ViewModel:
            PTSectionPaymentsView(viewModel: payGroupSectionVM)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func destinationView(
        link: PaymentsTransfersViewModel.Link
    ) -> some View {
        
        switch link {
        case let .userAccount(userAccountViewModel):
            UserAccountView(viewModel: userAccountViewModel)
            
        case let .exampleDetail(title):
            ExampleDetailMock(title: title)
            
        case let .mobile(model):
            MobilePayView(viewModel: model)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .country(countryData):
            CountryPaymentView(viewModel: countryData)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea(.all)
            
        case let .payments(node):
            PaymentsView(viewModel: node.model)
                .navigationBarHidden(true)
            
        case let .phone(phoneData):
            PaymentPhoneView(viewModel: phoneData)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea(.all)
            
        case let .internetOperators(model):
            OperatorsView(viewModel: model)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .serviceOperators(model):
            OperatorsView(viewModel: model)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .transportOperators(model):
            OperatorsView(viewModel: model)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .transport(viewModel):
            OperatorsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .internet(viewModel):
            OperatorsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .service(viewModel):
            OperatorsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .templates(node):
            TemplatesListFlowView(
                model: node.model,
                makeAnywayFlowView: makeAnywayFlowView,
                makeIconView: {
                    
                    viewFactory.makeIconView($0.map { .svg($0) })
                }
            )

        case let .currencyWallet(currencyWalletViewModel):
            CurrencyWalletView(viewModel: currencyWalletViewModel)
            
        case let .failedView(failedViewModel):
            QRFailedView(viewModel: failedViewModel)
            
        case let .c2b(c2bViewModel):
            C2BDetailsView(viewModel: c2bViewModel, getUImage: getUImage)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea(.all)
            
        case let .searchOperators(viewModel):
            QRSearchOperatorView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .operatorView(internetDetailViewModel):
            InternetTVDetailsView(viewModel: internetDetailViewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .paymentsServices(viewModel):
            PaymentsServicesOperatorsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .transportPayments(transportPaymentsViewModel):
            transportPaymentsView(
                viewModel: viewModel,
                transportPaymentsViewModel: transportPaymentsViewModel
            )
            
        case let .productProfile(productProfileViewModel):
            ProductProfileView(
                viewModel: productProfileViewModel,
                viewFactory: viewFactory,
                productProfileViewFactory: productProfileViewFactory,
                getUImage: getUImage
            )
            
        case let .openDeposit(depositListViewModel):
            OpenDepositDetailView(viewModel: depositListViewModel, getUImage: getUImage)
            
        case let .openDepositsList(openDepositViewModel):
            OpenDepositListView(viewModel: openDepositViewModel, getUImage: getUImage)
            
        case let .sberQRPayment(sberQRPaymentViewModel):
            viewFactory.makeSberQRConfirmPaymentView(sberQRPaymentViewModel)
                .navigationBarWithBack(
                    title: sberQRPaymentViewModel.navTitle,
                    dismiss: { viewModel.event(.dismiss(.destination)) }
                )
            
        case let .utilityPayment(flowState):
            let event = { viewModel.event(.utilityFlow($0)) }
            let dismissDestination = { viewModel.event(.dismiss(.destination)) }
            
            utilityPaymentFlowView(state: flowState, event: event)
                .ignoresSafeArea()
                .navigationBarWithBack(
                    title: flowState.navTitle,
                    dismiss: dismissDestination,
                    rightItem: .barcodeScanner(action: viewModel.openScanner)
                )
            
        case let .servicePayment(state):
            let payload = state.content.state.transaction.context.outline.payload
            let operatorIconView = viewFactory.makeIconView(
                payload.icon.map { .md5Hash(.init($0)) }
            )
            paymentFlowView(
                state: state,
                event: { viewModel.event(.utilityFlow(.payment($0)))}
            )
            .navigationBarWithAsyncIcon(
                title: payload.title,
                subtitle: payload.subtitle,
                dismiss: { viewModel.event(.dismiss(.destination)) },
                icon: operatorIconView,
                style: .large
            )
            
        case let .paymentProviderPicker(node):
            paymentProviderPicker(node.model)
            
        case let .providerServicePicker(node):
            servicePicker(flowModel: node.model)
        }
    }
    
    private func transportPaymentsView(
        viewModel: PaymentsTransfersViewModel,
        transportPaymentsViewModel: TransportPaymentsViewModel
    ) -> some View {
        
        TransportPaymentsView(
            viewModel: transportPaymentsViewModel
        ) {
            MosParkingView(
                viewModel: .init(
                    operation: viewModel.getMosParkingPickerData
                ),
                stateView: { state in
                    
                    MosParkingStateView(
                        state: state,
                        mapper: DefaultMosParkingPickerDataMapper(select: transportPaymentsViewModel.selectMosParkingID(id:)),
                        errorView: {
                            Text($0.localizedDescription).foregroundColor(.red)
                        }
                    )
                }
            )
            // TODO: fix navigation bar
            // .navigationBar(
            //     with: .init(
            //         title: "Московский паркинг",
            //         rightItems: [
            //             NavigationBarView.ViewModel.IconItemViewModel(
            //                 icon: .init("ic40Transport"),
            //                 style: .large
            //             )
            //         ]
            //     )
            // )
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBar(
            with: .with(
                title: "Транспорт",
                navLeadingAction: viewModel.dismiss,
                navTrailingAction: viewModel.openScanner
            )
        )
    }
    
    @ViewBuilder
    private func sheetView(
        sheet: PaymentsTransfersViewModel.Sheet
    ) -> some View {
        
        switch sheet.type {
            
        case let .transferByPhone(viewModel):
            TransferByPhoneView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
        case let .meToMe(viewModel):
            PaymentsMeToMeView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
                .fixedSize(horizontal: false, vertical: true)
            
        case let .successMeToMe(successMeToMeViewModel):
            PaymentsSuccessView(viewModel: successMeToMeViewModel)
            
        case .anotherCard(let anotherCardViewModel):
            AnotherCardView(viewModel: anotherCardViewModel)
                .edgesIgnoringSafeArea(.bottom)
            
        case let .fastPayment(node):
            ContactsView(viewModel: node.model)
            
        case let .country(node):
            ContactsView(viewModel: node.model)
        }
    }
    
    @ViewBuilder
    private func bottomSheetView(
        bottomSheet: PaymentsTransfersViewModel.BottomSheet
    ) -> some View {
        
        switch bottomSheet.type {
        case let .exampleDetail(title):
            ExampleDetailMock(title: title)
            
        case let .meToMe(viewModel):
            
            PaymentsMeToMeView(viewModel: viewModel)
                .fullScreenCover(item: $viewModel.fullCover) { fullCover in
                    
                    switch fullCover.type {
                    case let .successMeToMe(successMeToMeViewModel):
                        PaymentsSuccessView(viewModel: successMeToMeViewModel)
                    }
                    
                }.transaction { transaction in
                    transaction.disablesAnimations = false
                }
        }
    }
    
    @ViewBuilder
    private func fullScreenCoverView(
        fullScreenCover: PaymentsTransfersViewModel.FullScreenSheet,
        goToMain: @escaping () -> Void
    ) -> some View {
        
        switch fullScreenCover.type {
        case let .qrScanner(node):
            NavigationView {
                
                QRView(viewModel: node.model.qrModel)
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    .edgesIgnoringSafeArea(.all)
            }
            
        case let .paymentCancelled(expired: expired):
            PaymentCancelledView(state: expired, event: goToMain)
            
        case let .success(viewModel):
            PaymentsSuccessView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func payByInstructionsView(
        _ paymentsViewModel: PaymentsViewModel
    ) -> some View {
        
        PaymentsView(viewModel: paymentsViewModel)
            .navigationBarHidden(true)
    }
    
    @ViewBuilder
    var leadingBarItems: some View {
        
        if viewModel.mode == .normal {
            
            UserAccountButton(viewModel: viewModel.userAccountButton)
        }
    }
    
    var trailingBarItems: some View {
        
        HStack {
            
            ForEach(viewModel.navButtonsRight, content: NavBarButton.init)
        }
    }
}

// MARK: - payment provider & service pickers

private extension PaymentsTransfersView {
    
    func paymentProviderPicker(
        _ flowModel: PaymentProviderPickerFlowModel
    ) -> some View {
        
        ComposedPaymentProviderPickerFlowView(
            flowModel: flowModel,
            iconView: viewFactory.makeIconView,
            makeAnywayFlowView: makeAnywayFlowView
        )
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
        
        AnywayServicePickerFlowView(
            flowModel: flowModel,
            factory: .init(
                makeAnywayFlowView: makeAnywayFlowView,
                makeIconView: viewFactory.makeIconView
            )
        )
        .navigationBarWithAsyncIcon(
            title: provider.origin.title,
            subtitle: provider.origin.inn,
            dismiss: viewModel.dismissProviderServicePicker,
            icon: viewFactory.iconView(provider.origin.icon),
            style: .normal
        )
    }
}

// MARK: - payment flow

private extension PaymentsTransfersView {
    
    @ViewBuilder
    func makeAnywayFlowView(
        flowModel: AnywayFlowModel
    ) -> some View {
        
        let anywayPaymentFactory = viewFactory.makeAnywayPaymentFactory {
            
            flowModel.state.content.event(.payment($0))
        }
        
        AnywayFlowView(
            flowModel: flowModel,
            factory: .init(
                makeElementView: anywayPaymentFactory.makeElementView,
                makeFooterView: anywayPaymentFactory.makeFooterView
            ),
            makePaymentCompleteView: {
                
                viewFactory.makePaymentCompleteView(
                    .init(
                        formattedAmount: $0.formattedAmount,
                        merchantIcon: $0.merchantIcon,
                        result: $0.result.mapError {
                            
                            return .init(hasExpired: $0.hasExpired)
                        }
                    ),
                    { flowModel.event(.goTo(.main)) }
                )
            }
        )
    }
}

// MARK: - Utility Payment Flow

private extension PaymentsTransfersView {
    
    // TODO: move to viewFactory
    func utilityPaymentFlowView(
        state: UtilityFlowState,
        event: @escaping (UtilityFlowEvent) -> Void
    ) -> some View {
        
        UtilityPaymentFlowView(
            state: state,
            event: { event(.prepayment($0)) },
            content: {
                
                UtilityPrepaymentWrapperView(
                    binder: state.content,
                    completionEvent: { event(.prepayment($0.flowEvent)) },
                    makeIconView: { viewFactory.makeIconView($0.map { .md5Hash(.init($0)) }) }
                )
            },
            destinationView: {
                
                utilityFlowDestinationView(state: $0, event: event)
            }
        )
    }
    
    @ViewBuilder
    func utilityFlowDestinationView(
        state: UtilityFlowState.Destination,
        event: @escaping (UtilityFlowEvent) -> Void
    ) -> some View {
        
        switch state {
        case let .operatorFailure(operatorFailure):
            let operatorIconView = viewFactory.makeIconView(
                operatorFailure.content.icon.map { .md5Hash(.init($0)) }
            )
            operatorFailureView(
                operatorFailure: operatorFailure,
                payByInstructions: { event(.prepayment(.payByInstructions)) },
                dismissDestination: { event(.prepayment(.dismiss(.operatorFailureDestination))) }
            )
            .frame(maxHeight: .infinity)
            .navigationBarWithAsyncIcon(
                title: operatorFailure.content.title,
                subtitle: operatorFailure.content.subtitle,
                dismiss: { event(.prepayment(.dismiss(.operatorFailureDestination))) },
                icon: operatorIconView,
                style: .large
            )
            
        case let .payByInstructions(paymentsViewModel):
            payByInstructionsView(paymentsViewModel)
            
        case let .payment(state):
            let payload = state.content.state.transaction.context.outline.payload
            let operatorIconView = viewFactory.makeIconView(
                payload.icon.map { .md5Hash(.init($0)) }
            )
            paymentFlowView(state: state, event: { event(.payment($0)) })
                .navigationBarWithAsyncIcon(
                    title: payload.title,
                    subtitle: payload.subtitle,
                    dismiss: { event(.prepayment(.dismiss(.destination))) },
                    icon: operatorIconView,
                    style: .large
                )
            
        case let .servicePicker(state):
            let operatorIconView = viewFactory.makeIconView(
                state.content.operator.icon.map { .md5Hash(.init($0)) }
            )
            servicePickerView(state: state, event: event)
                .navigationBarWithAsyncIcon(
                    title: state.content.operator.title,
                    subtitle: state.content.operator.subtitle,
                    dismiss: { event(.prepayment(.dismiss(.servicesDestination))) },
                    icon: operatorIconView,
                    style: .large
                )
        }
    }
    
    func operatorFailureView(
        operatorFailure: OperatorFailure,
        payByInstructions: @escaping () -> Void,
        dismissDestination: @escaping () -> Void
    ) -> some View {
        
        SberOperatorFailureFlowView(
            state: operatorFailure,
            event: dismissDestination,
            contentView: {
                
                FooterView(
                    state: .failure(.iFora),
                    event: { event in
                        
                        switch event {
                        case .payByInstruction:
                            payByInstructions()
                            
                        case .addCompany:
                            break
                        }
                    },
                    config: .iFora
                )
            },
            destinationView: operatorFailureDestinationView
        )
    }
    
    @ViewBuilder
    func operatorFailureDestinationView(
        destination: OperatorFailure.Destination
    ) -> some View {
        
        switch destination {
        case let .payByInstructions(paymentsViewModel):
            payByInstructionsView(paymentsViewModel)
        }
    }
    
    @ViewBuilder
    func paymentFlowView(
        state: UtilityServicePaymentFlowState,
        event: @escaping (UtilityServicePaymentFlowEvent) -> Void
    ) -> some View {
        
        let transactionEvent = { state.content.event($0) }
        
        let factory = viewFactory.makeAnywayPaymentFactory {
            
            transactionEvent(.payment($0))
        }
        
        AnywayTransactionStateWrapperView(viewModel: state.content) { state, event in
            
            AnywayTransactionView(state: state, event: transactionEvent, factory: factory)
        }
        .alert(
            item: state.alert,
            content: paymentFlowAlert(
                transactionEvent: { transactionEvent($0) },
                flowEvent: { viewModel.event(.utilityFlow(.payment($0))) }
            )
        )
        .fullScreenCover(
            cover: state.fullScreenCover,
            dismissFullScreenCover: { event(.dismiss(.fullScreenCover)) },
            content: paymentFlowFullScreenCoverView
        )
        .bottomSheet(
            sheet: state.modal,
            dismiss: { event(.dismiss(.fraud)) },
            content: paymentFlowModalView(
                event: { transactionEvent(.fraud($0)) }
            )
        )
        .padding(.bottom)
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationTitle("Payment: \(state.content.state.transaction.isValid ? "valid" : "invalid")")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func paymentFlowAlert(
        transactionEvent: @escaping (AnywayTransactionEvent) -> Void,
        flowEvent: @escaping (UtilityServicePaymentFlowEvent) -> Void
    ) -> (UtilityServicePaymentFlowState.Alert) -> Alert {
        
        return { alert in
            
            switch alert {
            case .paymentRestartConfirmation:
                return .init(
                    with: .paymentRestartConfirmation,
                    event: transactionEvent
                )
                
            case let .serverError(errorMessage):
                return .init(
                    with: .serverError(message: errorMessage),
                    event: transactionEvent
                )
                
            case let .terminalError(errorMessage):
                return .init(
                    with: .terminalError(message: errorMessage),
                    event: flowEvent
                )
            }
        }
    }
    
    @ViewBuilder
    func paymentFlowFullScreenCoverView(
        fullScreenCover: UtilityServicePaymentFlowState.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case let .completed(result):
            viewFactory.makePaymentCompleteView(result, { viewModel.event(.outside(.goToMain)) })
        }
    }
    
    func paymentFlowModalView(
        event: @escaping (FraudEvent) -> Void
    ) -> (UtilityServicePaymentFlowState.Modal) -> FraudNoticeView {
        
        return { 
            
            switch $0 {
            case let .fraud(fraud):
                FraudNoticeView(state: fraud, event: event) }
            }
    }
    
    @ViewBuilder
    func servicePickerView(
        state: ServicePickerState,
        event: @escaping (UtilityFlowEvent) -> Void
    ) -> some View {
        
        let selectService = {
            event(.prepayment(.select(
                .oneOf($0, for: state.content.`operator`)
            )))
        }
        
        let operatorIconView = viewFactory.makeIconView(
            state.content.operator.icon.map { .md5Hash(.init($0)) }
        )
        
        ServicePickerFlowView(
            state: state,
            event: event,
            contentView: {
                
                servicePickerContentView(
                    services: state.content.services.elements,
                    selectService: selectService,
                    iconView: operatorIconView
                )
            },
            destinationView: {
                
                servicePickerDestinationView(
                    destination: $0,
                    event: { event(.payment($0)) },
                    navBar: .init(
                        title: state.content.operator.title,
                        subtitle: state.content.operator.subtitle,
                        icon: operatorIconView
                    )
                )
            }
        )
        .navigationTitle(state.content.operator.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func servicePickerContentView(
        services: [UtilityService],
        selectService: @escaping (UtilityService) -> Void,
        iconView: IconDomain.IconView
    ) -> some View {
        
        ServicePickerView(
            state: services,
            serviceView: { service in
                
                Button {
                    
                    selectService(service)
                    
                } label: {
                    
                    UtilityServiceLabel(service: service, iconView: iconView)
                }
            }
        )
    }
    
    @ViewBuilder
    func servicePickerDestinationView(
        destination: ServicePickerState.Destination,
        event: @escaping (UtilityServicePaymentFlowEvent) -> Void,
        navBar: NavBar
    ) -> some View {
        
        switch destination {
        case let .payment(state):
            paymentFlowView(state: state, event: event)
                .navigationBarWithAsyncIcon(
                    title: navBar.title,
                    subtitle: navBar.subtitle,
                    dismiss: { viewModel.event(.utilityFlow(.prepayment(.dismiss(.servicesDestination)))) },
                    icon: navBar.icon,
                    style: .large
                )
        }
    }
    
    struct NavBar {
        
        let title: String
        let subtitle: String?
        let icon: UIPrimitives.AsyncImage
    }
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentBinder
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, Service, Content>
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, Service>
    
    typealias OperatorFailure = SberOperatorFailureFlowState<UtilityPaymentOperator>
    
    typealias ServicePickerState = UtilityServicePickerFlowState<UtilityPaymentOperator, Service>
}

extension UtilityServicePaymentFlowState.Modal: BottomSheetCustomizable {
    
    var isUserInteractionEnabled: CurrentValueSubject<Bool, Never> { .init(false) }
}

extension UtilityServicePaymentFlowState.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case .paymentRestartConfirmation:
            return .paymentRestartConfirmation
            
        case .serverError:
            return .serverError
            
        case .terminalError:
            return .terminalError
        }
    }
    
    enum ID: Hashable {
        
        case paymentRestartConfirmation
        case serverError
        case terminalError
    }
}

extension UtilityServicePaymentFlowState.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
        case .completed: return  .completed
        }
    }
    
    enum ID: Hashable {
        
        case completed
    }
}

extension UtilityServicePaymentFlowState.Modal: Identifiable {
    
    var id: ID {
        
        switch self {
        case .fraud: return  .fraud
        }
    }
    
    enum ID: Hashable {
        
        case fraud
    }
}

// MARK: - Alerts

extension AlertModel
where PrimaryEvent == AnywayTransactionEvent,
      SecondaryEvent == AnywayTransactionEvent {
    
    static var paymentRestartConfirmation: Self {
        
        return .init(
            title: "Внимание",
            message: "Изменение параметров перевода потребует повторного заполнение всех полей формы",
            primaryButton: .init(
                type: .default,
                title: "Продолжить",
                event: .paymentRestartConfirmation(true)
            ),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .paymentRestartConfirmation(false)
            )
        )
    }
    
    static func serverError(
        message: String
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismissRecoverableError
            )
        )
    }
}

private extension AlertModel
where PrimaryEvent == UtilityServicePaymentFlowEvent,
      SecondaryEvent == UtilityServicePaymentFlowEvent {
    
    static func terminalError(
        message: String
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismiss(.paymentError)
            )
        )
    }
}

// MARK: - NavBar

private extension NavigationBarView.ViewModel {
    
    static func with(
        title: String,
        navLeadingAction: @escaping () -> Void,
        navTrailingAction: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        .init(
            title: title,
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(
                    icon: .ic24ChevronLeft,
                    action: navLeadingAction
                )
            ],
            rightItems: [
                NavigationBarView.ViewModel.ButtonItemViewModel(
                    icon: Image("qr_Icon"),
                    action: navTrailingAction
                )
            ]
        )
    }
}

private extension PaymentsTransfersViewModel.Route {
    
    var isEmpty: Bool {
        
        destination == nil && modal == nil
    }
}

//MARK: - LatestPaymentDetailMock

extension PaymentsTransfersView {
    
    struct ExampleDetailMock: View {
        var title: String
        
        var body: some View {
            Spacer()
            Text("TypeButton: \(title)")
                .font(.title)
            Spacer()
        }
    }
}

extension PaymentsTransfersView {
    
    //MARK: - ViewBarButton
    
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

private extension UtilityPrepaymentCompletionEvent {
    
    var flowEvent: UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService> {
        
        switch self {
        case .addCompany:
            return .outside(.addCompany)
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payByInstructionsFromError:
            return .payByInstructionsFromError
            
        case let .select(select):
            switch select {
            case let .lastPayment(lastPayment):
                return .select(.lastPayment(lastPayment))
                
            case let .operator(`operator`):
                return .select(.operator(`operator`))
            }
        }
    }
}

//MARK: - Preview

struct Payments_TransfersView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        paymentsTransfersView()
            .previewDevice(PreviewDevice(rawValue: "iPhone X 15.4"))
            .previewDisplayName("iPhone X")
        
        paymentsTransfersView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            .previewDisplayName("iPhone 13 Pro Max")
        
        paymentsTransfersView()
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE (3rd generation)")
        
        paymentsTransfersView()
            .previewDevice("iPhone 13 mini")
            .previewDisplayName("iPhone 13 mini")
        
        paymentsTransfersView()
            .previewDevice("5se 15.4")
            .previewDisplayName("iPhone 5 SE")
    }
    
    private static func paymentsTransfersView() -> some View {
        
        PaymentsTransfersView(
            viewModel: .sample,
            viewFactory: .preview,
            productProfileViewFactory: .init(
                makeActivateSliderView: ActivateSliderStateWrapperView.init(payload:viewModel:config:),
                makeHistoryButton: { .init(event: $0, isFiltered: $1, isDateFiltered: $2, clearOptions: $3) },
                makeRepeatButtonView: { _ in .init(action: {}) }
            ),
            getUImage: { _ in nil }
        )
    }
}

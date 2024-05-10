//
//  Payments&TransfersView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import InfoComponent
import SberQR
import SwiftUI
import OperatorsListComponents
import TextFieldModel

struct PaymentsTransfersView: View {
    
    @ObservedObject var viewModel: PaymentsTransfersViewModel
    
    let viewFactory: PaymentsTransfersViewFactory
    let getUImage: (Md5hash) -> UIImage?
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack() {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ForEach(viewModel.sections, content: sectionView)
                }
            }
            
            Color.clear
                .sheet(
                    item: .init(
                        get: { viewModel.route.modal?.sheet },
                        set: { if $0 == nil { viewModel.event(.dismissModal) } }),
                    content: sheetView
                )
            
            Color.clear
                .fullScreenCover(
                    item: .init(
                        get: { viewModel.route.modal?.fullScreenSheet },
                        set: { if $0 == nil { viewModel.event(.dismissModal) } }
                    ),
                    content: fullScreenCoverView
                )
        }
        .onAppear {
            viewModel.action.send(PaymentsTransfersViewModelAction.ViewDidApear())
        }
        .alert(
            item: .init(
                get: { viewModel.route.modal?.alert },
                set: { if $0 == nil { viewModel.event(.dismissModal) } }
            ),
            content: Alert.init(with:)
        )
        .bottomSheet(
            item: .init(
                get: { viewModel.route.modal?.bottomSheet },
                set: { if $0 == nil { viewModel.event(.dismissModal) } }
            ),
            content: bottomSheetView
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.route.destination },
                set: { if $0 == nil { viewModel.event(.dismissDestination) } }
            ),
            content: destinationView(link:)
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading: Group {
                
                if viewModel.mode == .normal {
                    
                    UserAccountButton(
                        viewModel: viewModel.userAccountButton
                    )
                }
            },
            trailing:
                HStack {
                    ForEach(viewModel.navButtonsRight, content: NavBarButton.init)
                }
        )
        .tabBar(isHidden: .init(
            get: { viewModel.route.destination != nil },
            set: { if !$0 { viewModel.reset() } }
        ))
    }
    
    @ViewBuilder
    private func sectionView(
        section: PaymentsTransfersSectionViewModel
    ) -> some View {
        
        switch section {
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
            
        case let .payments(paymentsViewModel):
            PaymentsView(viewModel: paymentsViewModel)
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
            
        case let .template(templateListViewModel):
            TemplatesListView(viewModel: templateListViewModel)
            
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
                getUImage: getUImage
            )
            
        case let .openDeposit(depositListViewModel):
            OpenDepositDetailView(viewModel: depositListViewModel, getUImage: getUImage)
            
        case let .openDepositsList(openDepositViewModel):
            OpenDepositListView(viewModel: openDepositViewModel, getUImage: getUImage)
            
        case let .sberQRPayment(sberQRPaymentViewModel):
            viewFactory.makeSberQRConfirmPaymentView(sberQRPaymentViewModel)
                .navigationBar(
                    sberQRPaymentViewModel.navTitle,
                    dismiss: { viewModel.event(.dismissDestination) }
                )
            
        case let .utilities(utilitiesRoute):
#warning("replace implementation")
            utilityOperatorPicker(utilitiesRoute.viewModel)
                .navigationDestination(
                    item: .init(
                        get: { viewModel.route.utilitiesRoute?.destination },
                        set: { if $0 == nil { fatalError()
                            /*viewModel.event(.resetUtilityDestination)*/ }}
                    ),
                    content: utilitiesDestinationView
                )
                .navigationBarTitle(Text("Услуги ЖКХ"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {}, label: {
                    
                    Image.ic24BarcodeScanner2
                }))
                .ignoresSafeArea(edges: .bottom)
            
        case .payByInstructions:
            Text("payByInstructions - TBD - replace with payment")
            
        case let .utilityPayment(flowState):
            let event = { viewModel.event(.utilityFlow($0)) }
     
            viewFactory.makeUtilityPaymentFlowView(flowState, event)
                .navigationTitle("Utility Prepayment View")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    #warning("remove")
    @ViewBuilder
    private func utilitiesDestinationView(
        destination: PaymentsTransfersViewModel.Route.UtilitiesDestination
    ) -> some View {
        switch destination {
        case let .failure(`operator`):
            failureView(`operator`)
#warning("add nav bar")
            
        case let .list(list):
            #warning("replace implementation")
            utilityServicePicker(list.operator, list.services)
                .navigationDestination(
                    item: .init(
                        get: { list.destination },
                        set: { if $0 == nil { fatalError() /*viewModel.event(.resetUtilityListDestination)*/}}
                    ),
                    content: utilityServicePickerDestinationView
                )
#warning("add nav bar")
            
        case let .payment(utilityPaymentState):
            utilityPaymentWrapperView(utilityPaymentState)
#warning("add nav bar")
        }
    }
    
    #warning("remove")
    #warning("replace implementation")
    private func failureView(
        _ `operator`: OperatorsListComponents.Operator
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text(String(describing: `operator`))
                .font(.title3.bold())
            
            Text("Что-то пошло не так.\nПопробуйте позже или воспользуйтесь другим способом оплаты.")
                .foregroundColor(.secondary)
            
            Button("Оплатить по реквизитам") {
                
                fatalError()
                // self.viewModel.event(.utilityFlow(.payByInstructions))
            }
        }
        .padding()
    }
    
    #warning("remove")
    private func utilityServicePicker(
        _ `operator`: OperatorsListComponents.Operator,
        _ utilityServices: [UtilityService]
    ) -> some View {
        VStack(spacing: 32) {
            
            Text("Services for \(String(describing: `operator`))")
                .font(.title3.bold())
#warning("replace implementation")
            UtilityServicePicker(
                state: utilityServices,
                event: { _ in fatalError() /*self.viewModel.event(.utilityFlow(.select(.service($0, for: `operator`))))*/ }
            )
        }
    }

    #warning("remove")
#warning("replace implementation")
    private func utilityPaymentWrapperView(
        _ utilityPaymentState: UtilityPaymentState
    ) -> some View {
        UtilityPaymentWrapperView(
            state: utilityPaymentState,
            event: { _ in fatalError() /*viewModel.event(.utilityPayment($0))*/ }
        )
    }
    
    #warning("remove")
    @ViewBuilder
    private func utilityServicePickerDestinationView(
        _ utilityListDestination: PaymentsTransfersViewModel.Route.UtilitiesDestination.UtilityServicePickerDestination
    ) -> some View {
        
        switch utilityListDestination {
        case let .payment(utilityPaymentState):
            utilityPaymentWrapperView(utilityPaymentState)
        }
#warning("add nav bar")
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
    
    private func utilityOperatorPicker(
        _ viewModel: UtilitiesViewModel
    ) -> some View {
        UtilityOperatorPicker(
            state: viewModel.state,
            event: { _ in fatalError()
#warning("replace implementation")
                /*self.viewModel.event(.utilityPayment($0))*/ }
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
            
        case .fastPayment(let viewModel):
            ContactsView(viewModel: viewModel)
            
        case .country(let viewModel):
            ContactsView(viewModel: viewModel)
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
        fullScreenCover: PaymentsTransfersViewModel.FullScreenSheet
    ) -> some View {
        
        switch fullScreenCover.type {
        case let .qrScanner(viewModel):
            NavigationView {
                
                QRView(viewModel: viewModel)
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    .edgesIgnoringSafeArea(.all)
            }
            
        case .paymentCancelled:
            Text("TBD: Payment cancelled")
            
        case let .success(viewModel):
            PaymentsSuccessView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

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
            getUImage: { _ in nil }
        )
    }
}

//
//  Payments&TransfersView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SberQR
import SwiftUI

struct PaymentsTransfersView: View {
    
    @ObservedObject
    var viewModel: PaymentsTransfersViewModel
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack() {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ForEach(viewModel.sections) { section in
                        
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
                } //mainVerticalScrollView
            } //mainVStack
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                viewModel.link.map(destinationView)
            }
            
            Color.clear
                .sheet(item: $viewModel.sheet, content: sheetView)
            
            Color.clear
                .fullScreenCover(
                    item: $viewModel.fullScreenSheet,
                    content: fullScreenCoverView
                )
        }
        .onAppear {
            viewModel.action.send(PaymentsTransfersViewModelAction.ViewDidApear())
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading: Group {
                
                if viewModel.mode == .normal {
                    
                    MainView.UserAccountButton(viewModel: viewModel.userAccountButton)
                }
            },
            trailing:
                HStack {
                    ForEach(viewModel.navButtonsRight, content: NavBarButton.init)
                }
        )
        .bottomSheet(
            item: $viewModel.bottomSheet, 
            content: bottomSheetView
        )
        .alert(item: $viewModel.alert, content: Alert.init(with:))
        .tabBar(isHidden: $viewModel.isTabBarHidden)
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
            C2BDetailsView(viewModel: c2bViewModel)
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
            ProductProfileView(viewModel: productProfileViewModel)
            
        case let .openDeposit(depositListViewModel):
            OpenDepositDetailView(viewModel: depositListViewModel)
            
        case let .openDepositsList(openDepositViewModel):
            OpenDepositView(viewModel: openDepositViewModel)
            
        case let .sberQRPayment(sberQRPaymentViewModel):
            SberQRConfirmPaymentWrapperView(
                viewModel: sberQRPaymentViewModel,
                config: .iFora
            )
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
                navTrailingAction: viewModel.openScannerAction
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
            
        case let .success(viewModel):
            PaymentsSuccessView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
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
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice(PreviewDevice(rawValue: "iPhone X 15.4"))
            .previewDisplayName("iPhone X")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            .previewDisplayName("iPhone 13 Pro Max")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE (3rd generation)")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice("iPhone 13 mini")
            .previewDisplayName("iPhone 13 mini")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice("5se 15.4")
            .previewDisplayName("iPhone 5 SE")
    }
}

//
//  Payments&TransfersView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

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
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case let .userAccount(userAccountViewModel):
                        UserAccountView(viewModel: userAccountViewModel)
                        
                    case let .exampleDetail(title):
                        ExampleDetailMock(title: title)
                        
                    case .mobile(let model):
                        MobilePayView(viewModel: model)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .chooseCountry(let model):
                        ChooseCountryView(viewModel: model)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case let .country(countryData):
                        CountryPaymentView(viewModel: countryData)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case let .payments(paymentsViewModel):
                        PaymentsView(viewModel: paymentsViewModel)
                        
                    case let .transferByRequisites(transferByRequisitesViewModel):
                        PaymentsView(viewModel: transferByRequisitesViewModel)
                        
                    case let .phone(phoneData):
                        PaymentPhoneView(viewModel: phoneData)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .internetOperators(let model):
                        OperatorsView(viewModel: model)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .serviceOperators(let model):
                        OperatorsView(viewModel: model)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .transportOperators(let model):
                        OperatorsView(viewModel: model)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .transport(let viewModel):
                        OperatorsView(viewModel: viewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .internet(let viewModel):
                        OperatorsView(viewModel: viewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .service(let viewModel):
                        OperatorsView(viewModel: viewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .template(let templateListViewModel):
                        TemplatesListView(viewModel: templateListViewModel)
                        
                    case .currencyWallet(let currencyWalletViewModel):
                        CurrencyWalletView(viewModel: currencyWalletViewModel)
                        
                    case .failedView(let failedViewModel):
                        QRFailedView(viewModel: failedViewModel)
                        
                    case .c2b(let c2bViewModel):
                        C2BDetailsView(viewModel: c2bViewModel)
                        
                    case .searchOperators(let viewModel):
                        QRSearchOperatorView(viewModel: viewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                        
                    case let .operatorView(internetDetailViewModel):
                        InternetTVDetailsView(viewModel: internetDetailViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .edgesIgnoringSafeArea(.all)
                        
                    }
                }
            }
            
            Color.clear
                .sheet(item: $viewModel.sheet, content: { sheet in
                    
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
                    }
                })
            
            Color.clear
                .fullScreenCover(item: $viewModel.fullScreenSheet, content: { item in
                    
                    switch item.type {
                    case let .qrScanner(viewModel):
                        NavigationView {
                            QRView(viewModel: viewModel)
                                .navigationBarTitle("", displayMode: .inline)
                                .navigationBarBackButtonHidden(true)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                })
            
        }
        .onAppear {
            viewModel.action.send(PaymentsTransfersViewModelAction.ViewDidApear())
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading: MainView.UserAccountButton(viewModel: viewModel.userAccountButton),
            trailing:
                HStack {
                    ForEach(viewModel.navButtonsRight) { navButtonViewModel in
                        
                        NavBarButton(viewModel: navButtonViewModel)
                    }
                })
        .bottomSheet(item: $viewModel.bottomSheet) { sheet in
            
            switch sheet.type {
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
                
            case .anotherCard(let model):
                AnotherCardView(viewModel: model)
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarTitle("", displayMode: .inline)
                    .frame(height: 494)
                
            }
        }
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
        
        .tabBar(isHidden: $viewModel.isTabBarHidden)
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




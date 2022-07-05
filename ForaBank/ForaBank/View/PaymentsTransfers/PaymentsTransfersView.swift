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
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: MainView.UserAccountButton(viewModel: viewModel.userAccountButton),
                trailing:
                    HStack {
                        ForEach(viewModel.navButtonsRight) { navButtonViewModel in
                                            
                            NavBarButton(viewModel: navButtonViewModel)
                        }
                    })
 
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
                            .edgesIgnoringSafeArea(.all)
                        
                    case let .taxAndStateService(taxAndStateServiceVM):
                        PaymentsView(viewModel: taxAndStateServiceVM)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarHidden(true)
                        
                    case let .transferByRequisites(transferByRequisitesViewModel):
                        TransferByRequisitesView(viewModel: transferByRequisitesViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                        
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
                        
                    case .qrScanner(let qrViewModel):
                        QrScannerView(viewModel: qrViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            }
        }
        .bottomSheet(item: $viewModel.bottomSheet) {} content: { sheet in
            
            switch sheet.type {
            case let .exampleDetail(title):
                ExampleDetailMock(title: title)
                
            case let .country(countryData):
                CountryPaymentView(viewModel: .init(countryData: countryData))

            case let .meToMe(viewModel):
                MeToMeView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: 540)
                
            case .anotherCard(let model):
                //TODO: как то нужно открыть не молным модальным откном, UIViewControllerTransitioningDelegate не работает
                
                AnotherCardView(viewModel: model)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: 540)
                    .navigationBarTitle("", displayMode: .inline)
            }
        }
        .sheet(item: $viewModel.sheet, content: { sheet in
            
            switch sheet.type {
            case let .transferByPhone(viewModel):
                TransferByPhoneView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
            }
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




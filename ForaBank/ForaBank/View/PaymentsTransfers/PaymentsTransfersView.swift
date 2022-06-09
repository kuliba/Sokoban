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
    var previewMode: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                VStack() {
                    
                    Color.clear.frame(height: 48) // mock SearchView
                    
                    GeometryReader { grProxy in
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            ForEach(viewModel.sections) { section in
                                
                                switch section {
                                case let latestPaymentsSectionVM as PTSectionLatestPaymentsView.ViewModel:
                                    PTSectionLatestPaymentsView(viewModel: latestPaymentsSectionVM)
                                    
                                case let transfersSectionVM as PTSectionTransfersView.ViewModel:
                                    PTSectionTransfersView(viewModel: transfersSectionVM)
                                    
                                case let payGroupSectionVM as PTSectionPayGroupView.ViewModel:
                                    PTSectionPayGroupView(viewModel: payGroupSectionVM,
                                                          heightBlock: grProxy.size.height)
                                default:
                                    EmptyView()
                                }
                            }
                            
                        } //mainVerticalScrollView
                    } //geometry
                    
                    if previewMode {
                        if #available(iOS 14.0, *) {
                            Rectangle()
                                .ignoresSafeArea()
                                .foregroundColor(.mainColorsGrayLightest)
                                .frame(height: 56)
                        } else {
                            Color.mainColorsGrayLightest.frame(height: 56)
                        }
                    }
                    
                } //mainVStack
                
                if #available(iOS 14.0, *) {
                    Color.mainColorsGrayLightest
                        .frame(height: 48)
                        .ignoresSafeArea()
                        .overlay(TopSearchViewMock())
                } else {
                    Color.mainColorsGrayLightest
                        .frame(height: 48)
                        .overlay(TopSearchViewMock())
                } //mock topSearchView
                
                NavigationLink("", isActive: $viewModel.isLinkActive) {
                    
                    if let link = viewModel.link  {
                        
                        switch link {
                            
                        case .chooseCountry:
                            ChooseCountryView()
                        }
                    }
                }
                
            } //mainZStack
            .sheet(item: $viewModel.sheet, content: { sheet in
                switch sheet.type {
                    
                case .country:
                    ChooseCountryView()
                    
                case .productProfile(let productProfileViewModel):
                    ProductProfileView(viewModel: productProfileViewModel)
                    
                case .userAccount(let userAccountViewModel):
                    UserAccountView(viewModel: userAccountViewModel)
                    
                case .messages(let messagesHistoryViewModel):
                    MessagesHistoryView(viewModel: messagesHistoryViewModel)
                    
                case .myProducts(let myProductsViewModel):
                    MyProductsView(viewModel: myProductsViewModel)
                    
                case .places(let placesViewModel):
                    PlacesView(viewModel: placesViewModel)
                }
            })
            .navigationBarHidden(true)
        }
    }
}

extension PaymentsTransfersView {
 
//MARK: - ViewMock

    struct TopSearchViewMock: View {
        var body: some View {
            
            HStack {
                Image("ic24Search")
                Text("Название категории, ИНН")
                    .font(.textBodyMR14200())
                    .foregroundColor(Color(hex: "#999999"))
                Spacer()
                Image("ic24BarcodeScanner2")
            }
            .padding(18)
            .background(Color.mainColorsGrayLightest)
            
        }
    }

}

//MARK: - Preview

struct Payments_TransfersView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTransfersView(viewModel: .sample, previewMode: true)
            .previewDevice(PreviewDevice(rawValue: "iPhone X 15.4"))
            .previewDisplayName("iPhone X")
        
        PaymentsTransfersView(viewModel: .sample, previewMode: true)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            .previewDisplayName("iPhone 13 Pro Max")
        
        PaymentsTransfersView(viewModel: .sample, previewMode: true)
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE (3rd generation)")
        
        PaymentsTransfersView(viewModel: .sample, previewMode: true)
            .previewDevice("iPhone 13 mini")
            .previewDisplayName("iPhone 13 mini")
        
        PaymentsTransfersView(viewModel: .sample, previewMode: true)
            .previewDevice("5se 15.4")
            .previewDisplayName("iPhone 5 SE")
            
    }
}




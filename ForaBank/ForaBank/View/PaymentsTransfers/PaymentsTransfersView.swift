//
//  Payments&TransfersView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SwiftUI
import Introspect

struct PaymentsTransfersView: View {
    
    @ObservedObject
    var viewModel: PaymentsTransfersViewModel
    @State private var tabBarController: UITabBarController?

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
                                    
                                case let payGroupSectionVM as PTSectionPaymentsView.ViewModel:
                                    PTSectionPaymentsView(viewModel: payGroupSectionVM,
                                                          heightBlock: grProxy.size.height)
                                default:
                                    EmptyView()
                                }
                            }
                            
                        } //mainVerticalScrollView
                    } //geometry
                    
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
                            
                        case let .exampleDetail(title):
                            ExampleDetailMock(title: title)
                            
                        case .chooseCountry(let model):
                            ChooseCountryView(viewModel: model)
                                .navigationBarHidden(true)
//                                .navigationBarTitle("", displayMode: .inline)
                                .introspectTabBarController(customize: { tabBarController in
                                    hideTabBar(tabBarController)
                                })
                                .onDisappear {
                                    showTabBar(self.tabBarController)
                                }
                        }
                    }
                }
                
            } //mainZStack
            .sheet(item: $viewModel.sheet, content: { sheet in
                switch sheet.type {
                
                case let .exampleDetail(title):    //TODO: 
                    ExampleDetailMock(title: title)
                    
                }
            })
            .navigationBarHidden(true)
        }
    }
    
    private func hideTabBar(_ tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        tabBarController.tabBar.isHidden = true
        UIView.transition(with: tabBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func showTabBar(_ tabBarController: UITabBarController?) {
        if let tabBarController = tabBarController {
            
            tabBarController.tabBar.isHidden = false
            UIView.transition(with: tabBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

//MARK: - LatestPaymentDetailMock

extension PaymentsTransfersView {
    
    struct ExampleDetailMock: View {
        var title: String
        
        var body: some View {
            
            Text("TypeButton: \(title)")
                .font(.title)
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




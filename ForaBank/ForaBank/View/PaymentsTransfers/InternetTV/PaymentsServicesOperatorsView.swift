//
//  PaymentsServicesOperatorsView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.04.2023.
//

import SwiftUI

struct PaymentsServicesOperatorsView: View {
    
    @ObservedObject var viewModel: PaymentsServicesViewModel
    
    var body: some View {
        
        VStack(spacing: 5) {
            
            SearchBarView(viewModel: viewModel.searchBar)
                .frame(height: 44)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 15))

            ScrollView {
                PaymentsServicesLatestPaymentsSectionView(viewModel: viewModel.latestPayments)
                    .opacity(viewModel.filteredOperators.isEmpty ? 0 : 1)
                    .padding(.top, 15)

                VStack(alignment: .leading, spacing: 0) {
                    
                    switch viewModel.searchValue {
                        
                    case .empty:
                        
                        ForEach(viewModel.operators) { singleOperator in
                        
                            PaymentsServicesOperatorItemView(viewModel: singleOperator)
                        }
                        
                        NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                            .padding(.top, 43)
                        
                    case .noEmpty:
                        
                        if !viewModel.filteredOperators.isEmpty {
                            
                            ForEach(viewModel.filteredOperators) { singleOperator in
                                
                                PaymentsServicesOperatorItemView(viewModel: singleOperator)
                            }
                        }
                        
                        NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                            .padding(.top, 43)
                        
                    case .noResult:
                        
                        NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                            .padding(.top, 43)
                    }
                }
            }
        }
        .background(NavigationLink("", isActive: $viewModel.isLinkActive) {
            
            if let link = viewModel.link  {
                
                switch link {
                    
                case .operation(let viewModel):
                    InternetTVDetailsView(viewModel: viewModel)
                        .navigationBarTitle("", displayMode: .inline)
                        .edgesIgnoringSafeArea(.all)
                    
                case .payments(let viewModel):
                    PaymentsView(viewModel: viewModel)
                        .navigationBarHidden(true)

                case let .avtodor(action):
                    MultiOperatorView(viewModel: .init(), action: action)
                    //.navigationBarHidden(true)
                    
                case .mosParking:
                    
                    MosParkingSelectorView(
                        initialState: .monthlyOne,
                        options: .all,
                        paymentAction: {},
                        continueAction: {}
                    )
                }
            }
        }.opacity(0))
        .padding(.top, 20)
        .navigationBar(with: viewModel.navigationBar)
        .sheet(item: $viewModel.sheet) { item in
                
                switch item.sheetType {
                case .city(let model):
                    SearchCityView(viewModel: model)
                }
            }
    }
}

struct PaymentsServicesOperatorsView_Previews: PreviewProvider {
    static var previews: some View {
        
        PaymentsServicesOperatorsView.init(
            viewModel: .init(
                searchBar: .withText("Введите ИНН"),
                navigationBar: .init(title: "Все регионы"),
                model: .emptyMock,
                latestPayments: .sample,
                allOperators: [],
                addCompanyAction: {},
                requisitesAction: {}
            )
        )
    }
}

//
//  PaymentsServicesOperatorsView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.04.2023.
//

import SwiftUI

struct PaymentsServicesOperatorsViewFactory {
    
    let makePaymentsView: MakePaymentsView
}

extension PaymentsServicesOperatorsViewFactory {
    
    static let preview: Self = .init(makePaymentsView: {_ in fatalError()})
}

struct PaymentsServicesOperatorsView: View {
    
    @ObservedObject var viewModel: PaymentsServicesViewModel
    let viewFactory: PaymentsServicesOperatorsViewFactory
    
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
                    OperatorsView(
                        searchValue: viewModel.searchValue,
                        operators: viewModel.operators,
                        filteredOperators: viewModel.filteredOperators
                    )

                    NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                        .padding(.top, 43)
                }
            }
        }
        .background(navigationLink)
        .padding(.top, 20)
        .navigationBar(with: viewModel.navigationBar)
        .sheet(item: $viewModel.sheet, content: sheet(item:))
    }
    
    private var navigationLink: some View {
        
        NavigationLink("", isActive: $viewModel.isLinkActive) {
            
            destination(link: viewModel.link)
        }
        .opacity(0)
    }
    
    @ViewBuilder
    private func destination(
        link: PaymentsServicesViewModel.Link?
    ) -> some View {
        
        switch link {
        case .none:
            EmptyView()
            
        case .operation(let viewModel):
            InternetTVDetailsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case .payments(let viewModel):
            viewFactory.makePaymentsView(viewModel)
                .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func sheet(
        item: PaymentsServicesViewModel.Sheet
    ) -> some View {
        
        switch item.sheetType {
        case .city(let model):
            SearchCityView(viewModel: model)
        }
    }
    
    struct OperatorsView: View {
        
        let searchValue: PaymentsServicesViewModel.SearchValue
        let operators: [PaymentsServicesViewModel.ItemViewModel]
        let filteredOperators: [PaymentsServicesViewModel.ItemViewModel]
        
        var body: some View {
            
            switch searchValue {
                
            case .empty:
                
                ForEach(
                    operators,
                    content: PaymentsServicesOperatorItemView.init(viewModel:)
                )
                
            case .noEmpty:
                
                if !filteredOperators.isEmpty {
                    
                    ForEach(
                        filteredOperators,
                        content: PaymentsServicesOperatorItemView.init(viewModel:)
                    )
                }
                
            case .noResult:
                
                EmptyView()
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
            ), 
            viewFactory: .preview
        )
    }
}

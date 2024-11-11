//
//  QRSearchOperatorView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI

struct QRSearchOperatorViewFactory {
    
    let makePaymentsView: MakePaymentsView
}

struct QRSearchOperatorView: View {
    
    @ObservedObject var viewModel: QRSearchOperatorViewModel
    let viewFactory: QRSearchOperatorViewFactory
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            SearchBarView(viewModel: viewModel.searchBar)
                .padding(.horizontal, 20)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    switch viewModel.searchValue {
                        
                    case .empty:
                        
                        ForEach(viewModel.operators) { singleOperator in
                        
                            QRSearchOperatorComponent(viewModel: singleOperator)
                        }
                        
                        NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                            .padding(.top, 48)
                        
                    case .noEmpty:
                        
                        ForEach(viewModel.filteredOperators) { singleOperator in
                            
                            QRSearchOperatorComponent(viewModel: singleOperator)
                        }
                        
                        NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                            .padding(.top, 48)
                        
                    case .noResult:
                        
                        NoCompanyInListView(viewModel: viewModel.noCompanyInListViewModel)
                            .padding(.top, 48)
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
                    viewFactory.makePaymentsView(viewModel)
                        .navigationBarHidden(true)
                }
            }
        }.opacity(0))
        .padding(.top, 20)
        .navigationBar(with: viewModel.navigationBar)
        .sheet(item: $viewModel.sheet) { item in
                
                switch item.sheetType {
                case .city(let model):
                    QRSearchCityView(viewModel: model)
                }
            }
    }
}

struct QRSearchOperatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRSearchOperatorView(
            viewModel: .init(
                searchBar: .withText("Введите ИНН"),
                navigationBar: .init(title: "Все регионы"),
                model: .emptyMock,
                addCompanyAction: {},
                requisitesAction: {}
            ), 
            viewFactory: .init(makePaymentsView: { _ in fatalError() })
        )
    }
}

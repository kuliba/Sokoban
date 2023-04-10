//
//  QRSearchOperatorView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI

struct QRSearchOperatorView: View {
    
    @ObservedObject var viewModel: QRSearchOperatorViewModel
    
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
                        
                        EmptySearchView(viewModel: viewModel)
                            .padding(.top, 48)
                        
                    case .noEmpty:
                        
                        ForEach(viewModel.filteredOperators) { singleOperator in
                            
                            QRSearchOperatorComponent(viewModel: singleOperator)
                        }
                        
                        EmptySearchView(viewModel: viewModel)
                            .padding(.top, 48)
                        
                    case .noResult:
                        
                        EmptySearchView(viewModel: viewModel)
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

struct EmptySearchView: View {
    
    @ObservedObject var viewModel: QRSearchOperatorViewModel
    
    var body: some View {
        
        VStack(spacing: 28) {
            
            VStack(spacing: 16) {
                
                Text(viewModel.emptyViewTitle)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.emptyViewContent)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
                
            } .padding(.horizontal, 20)
            
            VStack(spacing: 20) {
                
                VStack(spacing: 8) {
                    
                    ForEach(viewModel.searchOperatorButton) { buttons in
                        
                        ButtonSimpleView(viewModel: buttons)
                            .frame(height: 56)
                            .padding(.horizontal, 20)
                    }
                }
                
                Text(viewModel.emptyViewSubtitle)
                    .font(.textBodyMR14200())
                    .foregroundColor(Color.textPlaceholder)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct QRSearchOperatorView_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchOperatorView.init(viewModel: .init(searchBar: .init(textFieldPhoneNumberView: .init(.text("Введите ИНН"))), navigationBar: .init(title: "Все регионы"), model: .emptyMock, addCompanyAction: {}, requisitesAction: {}))
    }
}

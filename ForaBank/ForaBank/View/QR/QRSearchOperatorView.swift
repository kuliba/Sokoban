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
        
        VStack {
            
            QRSearchViewComponent(text: $viewModel.textFieldValue, textFieldPlaceholder: "Название или ИНН", action: {
                viewModel.textFieldValue = ""
            })
            .padding(20)
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    switch viewModel.searchValue {
                        
                    case .empty:
                        
                        ForEach(viewModel.operators) { singleOperator in
                            QRSearchOperatorComponent(viewModel: singleOperator)
                        }
                        
                    case .noEmpty:
                        
                        if let filteredOperators = viewModel.filteredOperators {
                            
                            ForEach(filteredOperators) { singleOperator in
                                QRSearchOperatorComponent(viewModel: singleOperator)
                            }
                        }
                        
                    case .noResult:
                        
                        EmptySearchView(viewModel: viewModel)
                            .padding(.top, 100)
                    }
                }
            }
        } .navigationBar(with: viewModel.navigationBar)
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
        
        VStack(spacing: 50) {
            
            VStack(spacing: 20) {
                
                Text(viewModel.emptyViewTitle)
                    .font(Font.textH3M18240())
                    .foregroundColor(Color.textSecondary)
                
                Text(viewModel.emptyViewContent)
                    .font(Font.textBodyMSB14200())
                    .foregroundColor(Color.textPlaceholder)
            } .padding(.horizontal, 20)
            
            
            VStack(spacing: 20) {
                
                VStack(spacing: 10) {
                    ForEach(viewModel.searchOperatorButton) { buttons in
                        ButtonSimpleView(viewModel: buttons)
                            .frame(height: 48)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                
                Text(viewModel.emptyViewSubtitle)
                    .font(Font.textBodyMSB14200())
                    .foregroundColor(Color.textPlaceholder)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct QRSearchOperatorView_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchOperatorView.init(viewModel: .init(textFieldPlaceholder: "Название или ИНН", navigationBar: .init(title: "Все регионы"), model: .emptyMock))
    }
}

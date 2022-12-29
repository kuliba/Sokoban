//
//  QRSearchCityView.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.12.2022.
//

import SwiftUI

struct QRSearchCityView: View {
    
    @ObservedObject var viewModel: QRSearchCityViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Text(viewModel.title)
                    .font(Font.textH3UnderlineSB18240())
                    .foregroundColor(Color.textSecondary)
                    .frame(height: 30)
                
                Spacer()
            } .padding(20)
            
            QRSearchViewComponent(text: $viewModel.textFieldValue, textFieldPlaceholder: "Введите название города", action: {
                viewModel.textFieldValue = ""
            })
                .padding(20)
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    
                    if viewModel.filteredCity.isEmpty == false {
                        
                        if let filteredOperators = viewModel.filteredCity {
                            
                            ForEach(filteredOperators, id: \.self) { city in
                                Button {
                                    
                                    viewModel.action(city)
                                } label: {
                                    Text(city)
                                        .font(Font.textH4M16240())
                                        .foregroundColor(Color.iconBlack)
                                        .frame(height: 30)
                                    Spacer()
                                }
                            }
                        }
                        
                    } else {
                        
                        ForEach(viewModel.city, id: \.self) { city in
                            
                            Button {
                                
                                viewModel.action(city)
                            } label: {
                                Text(city)
                                    .font(Font.textH4M16240())
                                    .foregroundColor(Color.iconBlack)
                                    .frame(height: 30)
                                Spacer()
                            }
                        }
                    }
                } .padding(.horizontal, 16)
            }
        }
    }
}

struct QRSearchCityView_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchCityView(viewModel: .init(model: .emptyMock, action: {_ in }))
    }
}

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
        
        VStack(spacing: 20) {
            
            HStack {
                
                Text(viewModel.title)
                    .font(Font.textH3UnderlineSB18240())
                    .foregroundColor(Color.textSecondary)
                    .frame(height: 30)
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                
                SearchBarView(viewModel: viewModel.searchView)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        
                        //TODO: refactoring required
                        if viewModel.filteredCity.isEmpty == false {
                            
                            ForEach(viewModel.filteredCity, id: \.self) { city in
                                
                                Button {
                                    
                                    viewModel.action(city)
                                } label: {
                                    
                                    Text(city)
                                        .multilineTextAlignment(.leading)
                                        .font(Font.textH4M16240())
                                        .foregroundColor(Color.iconBlack)
                                        
                                    Spacer()
                                }
                                .frame(height: 56)
                            }
                            
                        } else {
                            
                            ForEach(viewModel.city, id: \.self) { city in
                                
                                Button {
                                    
                                    viewModel.action(city)
                                } label: {
                                    Text(city)
                                        .font(Font.textH4M16240())
                                        .foregroundColor(Color.iconBlack)
                                        
                                    Spacer()
                                }
                                .frame(height: 56)
                            }
                        }
                    }.padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 20)
    }
}

struct QRSearchCityView_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchCityView(viewModel: .init(model: .emptyMock, searchView: .init(textFieldPhoneNumberView: .init(.text("Введите название региона"))), action: {_ in }))
    }
}

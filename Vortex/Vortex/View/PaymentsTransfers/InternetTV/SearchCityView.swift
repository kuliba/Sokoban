//
//  SearchCityView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.04.2023.
//

import SwiftUI

struct SearchCityView: View {
    
    @ObservedObject var viewModel: SearchCityViewModel
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack {
                
                Text(viewModel.title)
                    .font(Font.textH3Sb18240())
                    .foregroundColor(Color.textSecondary)
                    .frame(height: 20)
                
                Spacer()
                
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 13) {
                
                SearchBarView(viewModel: viewModel.searchView)
                    .frame(height: 44)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 15))
                    .accessibilityIdentifier("SearchBarViewInPaymentsServices")
                
                
                if !viewModel.filteredCity.isEmpty {
                    
                    ScrollView {
                        
                        VStack(alignment: .leading) {
                            
                            ForEach(viewModel.filteredCity, id: \.self) { city in
                                
                                Button(action: { viewModel.action(city) }) {
                                    
                                    Text(city)
                                        .multilineTextAlignment(.leading)
                                        .font(Font.textH4R16240())
                                        .foregroundColor(Color.iconBlack)
                                    
                                    Spacer()
                                }
                                .frame(height: 46)
                                .accessibilityIdentifier("RegionName")

                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 15))

                    }

                } else {
                    EmptyCityView()
                }
                
            }
        }
        .padding(.top, 20)
    }
}

struct EmptyCityView: View {
    var body: some View {
        Spacer()
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.mainColorsGrayLightest)
                Image.ic24Search
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.textPlaceholder)
            }
            Text("Нет совпадений")
                .font(Font.textH4R16240())
                .foregroundColor(Color.textPlaceholder)
        }
        Spacer()
    }
}

struct SearchCityView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCityView(
            viewModel: .init(
                model: .emptyMock,
                searchView: .withText("Введите название региона"),
                operators: [],
                action: {_ in })
        )
    }
}

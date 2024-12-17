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
                    .font(.textH3UnderlineSb18240())
                    .foregroundColor(Color.textSecondary)
                    .frame(height: 30)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                
                SearchBarView(viewModel: viewModel.searchViewModel)
                    .padding(.horizontal, 20)
                
                ScrollView(content: scrollViewContent)
            }
        }
        .padding(.top, 20)
    }
    
    private func scrollViewContent() -> some View {
        
        VStack(alignment: .leading) {
            
            ForEach(
                viewModel.state.regionsToDisplay,
                id: \.self,
                content: regionButton
            )
            .animation(.default, value: viewModel.state)
            
        }
        .padding(.horizontal, 20)
    }
    
    private func regionButton(for region: String) -> some View {
        
        Button {
            viewModel.select(region)
        } label: {
            regionLabel(for: region)
            
            Spacer()
        }
        .frame(height: 56)
    }
    
    @ViewBuilder
    private func regionLabel(for region: String) -> some View {
        
        switch viewModel.state {
        case .all:
            Text(region)
                .font(Font.textH4M16240())
                .foregroundColor(Color.iconBlack)
            
        case .filtered:
            Text(region)
                .multilineTextAlignment(.leading)
                .font(Font.textH4M16240())
                .foregroundColor(Color.iconBlack)
        }
    }
}

extension RegionsState {
    
    var regionsToDisplay: [Region] {
        
        switch self {
        case let .all(regions):
            return regions
            
        case let .filtered(filtered):
            return filtered
        }
    }
}

struct QRSearchCityView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        QRSearchCityView(
            viewModel: .init(
                regions: [],
                searchViewModel: .withText("Введите название региона"),
                select: { _ in })
        )
    }
}

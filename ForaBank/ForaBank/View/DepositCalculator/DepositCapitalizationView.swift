//
//  DepositCapitalizationView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import SwiftUI

struct DepositCapitalizationView: View {
    
    @ObservedObject var viewModel: DepositCapitalizationViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Image.ic24TrendingUp
                    .renderingMode(.template)
                    .foregroundColor(viewModel.isOn ? .mainColorsWhite : .mainColorsGray)
                
                Text(viewModel.title)
                    .foregroundColor(viewModel.isOn ? .mainColorsWhite : .mainColorsGray)
                    .font(.textBodyMR14200())
                    .padding(.leading)
                
                Spacer()
                
                DepositToggleViewComponent(isOn: $viewModel.isOn)
            }
            
            Divider()
                .background(Color.mainColorsGray)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
        }.padding([.leading, .trailing], 20)
    }
}

struct DepositCapitalizationView_Previews: PreviewProvider {
    static var previews: some View {
        DepositCapitalizationView(viewModel: .sample)
            .background(Color.mainColorsBlack)
            .previewLayout(.sizeThatFits)
    }
}

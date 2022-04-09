//
//  PlacesControlView.swift
//  ForaBank
//
//  Created by Max Gribov on 06.04.2022.
//

import SwiftUI

struct PlacesControlView: View {
    
    @ObservedObject var viewModel: PlacesControlViewModel
    
    var body: some View {
        
        HStack {
            
            HStack(spacing: 12) {
                
                ForEach(viewModel.optionButtons) { optionButtonViewModel in
                   
                    PlacesControlView.OptionButtonView(viewModel: optionButtonViewModel)
                }
            }
            
            Spacer()
            
            PlacesControlView.ModeButtonView(viewModel: viewModel.modeButton)
        }
        .padding(.horizontal)
    }
}

extension PlacesControlView {
    
    struct ModeButtonView: View {
        
        let viewModel: PlacesControlViewModel.ModeButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack {
                    
                    viewModel.icon
                        .renderingMode(.template)
                        .foregroundColor(.mainColorsBlack)
                    
                    Text(viewModel.title)
                        .font(.textBodyMM14200())
                        .foregroundColor(.mainColorsBlack)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().foregroundColor(.mainColorsGrayLightest).shadow(color: .mainColorsBlack.opacity(0.12), radius: 2, x: 0, y: 2))
                
            }
        }
    }
    
    struct OptionButtonView: View {
        
        let viewModel: PlacesControlViewModel.OptionButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                viewModel.icon
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsBlack)
                    .padding(6)
                    .background(Circle().foregroundColor(.mainColorsGrayLightest).shadow(color: .mainColorsBlack.opacity(0.12), radius: 2, x: 0, y: 2))
            }
        }
    }
}

struct PlacesControlView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlacesControlView(viewModel: .init(mode: .map))
            .previewLayout(.fixed(width: 375, height: 80))
    }
}

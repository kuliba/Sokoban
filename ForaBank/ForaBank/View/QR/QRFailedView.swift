//
//  QRFailedView.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.11.2022.
//

import SwiftUI

struct QRFailedView: View {
    
    @ObservedObject var viewModel: QRFailedViewModel
    
    var body: some View {
        
        VStack {
            
            var iconView: some View {
                
                if let icon = viewModel.icon {
                    
                    if let iconImage = icon.image {
                        
                        iconImage
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 96, height: 96)
                            .overlay(Circle()
                                .stroke(lineWidth: 0)
                            )
                    }
                    
                    ZStack {
                        Circle()
                            .foregroundColor(.iconBlack)
                            .frame(width: 32, height: 32)
                        
                        Image.ic16Edit2
                            .foregroundColor(.iconWhite)
                    } .offset(x: 32, y: -32)
                }
            }
            
            Text(viewModel.title)
                .font(Font.textH3M18240())
                .foregroundColor(Color.textSecondary)
            Text(viewModel.content)
                .font(Font.textBodyMSB14200())
                .foregroundColor(Color.textPlaceholder)
            
            ForEach(viewModel.searchOperatorButton) { buttons in
                ButtonSimpleView(viewModel: buttons)
            }
        }
    }
}


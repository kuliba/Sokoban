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
        
        VStack(spacing: 30) {
            
            avatarView
            
            Text(viewModel.title)
                .font(Font.textH3M18240())
                .foregroundColor(Color.textSecondary)
            
            Text(viewModel.content)
                .font(Font.textBodyMSB14200())
                .foregroundColor(Color.textPlaceholder)
            
            VStack(spacing: 8) {
                ForEach(viewModel.searchOperatorButton) { buttons in
                    ButtonSimpleView(viewModel: buttons)
                        .frame(height: 48)
                        .padding(.horizontal, 20)
                }
            }
        }
        
        NavigationLink("", isActive: $viewModel.isLinkActive) {
            
            if let link = viewModel.link  {
                
                switch link {

                case .failedView(let view):
                    QRSearchOperatorView(viewModel: view)
                }
            }
        }
    }
    
    var avatarView: some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(.mainColorsGrayLightest)
                .frame(width: 88, height: 88)
            
            Image.ic24BarcodeScanner2
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundColor(.iconBlack)
            
            ZStack {
                
                Circle()
                    .foregroundColor(.iconRed)
                    .frame(width: 32, height: 32)
                
                Image.ic16AlertCircle
                    .resizable()
                    .foregroundColor(.iconWhite)
                    .frame(width: 20, height: 20)
            }
            .offset(x: 32, y: -32)
        }
    }
}


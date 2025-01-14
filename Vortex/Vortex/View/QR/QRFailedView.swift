//
//  QRFailedView.swift
//  Vortex
//
//  Created by Константин Савялов on 14.11.2022.
//

import SwiftUI

struct QRFailedViewFactory {
    
    let makeQRSearchOperatorView: (QRSearchOperatorViewModel) -> QRSearchOperatorView
}

struct QRFailedView: View {
    
    @ObservedObject var viewModel: QRFailedViewModel
    let viewFactory: QRFailedViewFactory
    
    var body: some View {
        
        QRFailedContentView(
            title: viewModel.title,
            subtitle: viewModel.content,
            buttons: viewModel.searchOperatorButton
        )
        
        NavigationLink("", isActive: $viewModel.isLinkActive) {
            
            if let link = viewModel.link  {
                
                switch link {
                    
                case let .failedView(viewModel):
                    viewFactory.makeQRSearchOperatorView(viewModel)
                }
            }
        }
    }
}

struct QRFailedContentView: View {
    
    let title: String
    let subtitle: String
    let buttons: [ButtonSimpleView.ViewModel]
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            QRFailedAvatarView(title: title, subtitle: subtitle)
            
            VStack(spacing: 8) {
                
                ForEach(buttons) { buttons in
                    
                    ButtonSimpleView(viewModel: buttons)
                        .frame(height: 56)
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
        }
        .padding(.top, 80)
    }
}

struct QRFailedAvatarView: View {
    
    let title: String
    let subtitle: String
    
    var body: some View {
        
        VStack(spacing: 28) {
            
            avatarView()
            
            VStack(spacing: 8) {
                
                Text(title)
                    .font(.textH3Sb18240())
                    .foregroundColor(.textSecondary)
                
                Text(subtitle)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
            }
        }
    }
}

private extension QRFailedAvatarView {
    
    func avatarView() -> some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(.mainColorsGrayLightest)
                .frame(width: 88, height: 88, alignment: .center)
            
            Image.ic48BarcodeScanner
                .resizable()
                .frame(width: 48, height: 48, alignment: .center)
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

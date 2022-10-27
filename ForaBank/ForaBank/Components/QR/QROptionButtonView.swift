//
//  QROptionButtonView.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.10.2022.
//

import SwiftUI

//MARK: - ViewModel

extension QROptionButtonView {
    
    class ViewModel: QROptionButtonViewModel {}
}

//MARK: - View

struct QROptionButtonView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            Button(action: viewModel.action) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(Color.mainColorsWhite)
                        .frame(width: 56, height: 56)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
            Text(viewModel.title)
                .font(Font.textBodySM12160())
                .foregroundColor(.white)
                .frame(height: 24)
        }
    }
}

//MARK: - Preview

struct QROptionButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        QROptionButtonView(viewModel: .init(id: UUID(), icon: .ic24Image, title: "Из документов", action: {}))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}

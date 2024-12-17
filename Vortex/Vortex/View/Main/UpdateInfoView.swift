//
//  UpdateInfoView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.05.2024.
//

import SwiftUI

struct UpdateInfoView: View {
    
    let text: String
    
    var body: some View {
        
        ZStack {
            
            Color.mainColorsGrayLightest
                .cornerRadius(90)
            
            HStack(spacing: 12) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                    
                    Image.ic24AlertCircleRed
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                Text(text)
                    .font(.textBodyMR14180())
                    .lineLimit(2)
                    .foregroundColor(.mainColorsBlack)
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame( height: 52)
        .padding(.horizontal, 8)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}

struct UpdateInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UpdateInfoView(text: .updateInfoText)
    }
}

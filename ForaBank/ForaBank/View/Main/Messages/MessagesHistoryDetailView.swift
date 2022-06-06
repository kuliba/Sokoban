//
//  MessagesHistoryDetailView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.06.2022.
//

import SwiftUI

struct MessagesHistoryDetailView: View {
    
    let model: MessagesHistoryDetailViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.mainColorsGrayLightest
                .frame(height: 250)
            
            VStack(spacing: 20) {
                
                model.icon
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.mainColorsGray)
                
                Text(model.title)
                    .font(.textH4M16240())
                    .foregroundColor(.mainColorsBlack)
                
                Text(model.content)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsBlack)
            }.padding(.bottom)
        }
    }
    
    internal init(model: MessagesHistoryDetailViewModel) {
        
        self.model = model
    }
}

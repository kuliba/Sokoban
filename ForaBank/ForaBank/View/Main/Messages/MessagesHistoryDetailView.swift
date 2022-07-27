//
//  MessagesHistoryDetailView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.06.2022.
//

import SwiftUI

struct MessagesHistoryDetailView: View {
    
    let model: MessagesHistoryDetailViewModel
    let maxHight = UIScreen.main.bounds.height - 400
    @State var textHeight: CGFloat = 0
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            model.icon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.iconWhite)
                .background(Circle().frame(width: 40, height: 40).foregroundColor(.bGIconRedLight))
                .frame(width: 32, height: 32)
                .background(Circle().frame(width: 64, height: 64).foregroundColor(.bGIconRedLight))
                .padding(32)
            
            Text(model.title)
                .font(.textH4M16240())
                .foregroundColor(.mainColorsBlack)
            
            MessageTextView(text: model.content)
                .frame(height: MessageTextView.calculatedHeight(for: model.content, width: UIScreen.main.bounds.width), alignment: .center)
                .padding(.horizontal, 10)
                .padding(.bottom, 100)
            
        }.padding(.vertical, 25)
    }
    
    internal init(model: MessagesHistoryDetailViewModel) {
        
        self.model = model
    }
}

struct ContentLengthPreference: PreferenceKey {
    
   static var defaultValue: CGFloat { 0 }
   
   static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = nextValue()
   }
}

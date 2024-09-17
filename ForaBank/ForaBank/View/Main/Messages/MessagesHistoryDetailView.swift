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
    let handleLink: (URL) -> Void
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            model.icon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.iconWhite)
                .background(Circle().frame(width: 40, height: 40).foregroundColor(.bgIconRedLight))
                .frame(width: 32, height: 32)
                .background(Circle().frame(width: 64, height: 64).foregroundColor(.bgIconRedLight))
                .padding(32)
                .accessibilityIdentifier("MessageHistoryDetailIcon")
            
            Text(model.title)
                .font(.textH4M16240())
                .foregroundColor(.mainColorsBlack)
                .accessibilityIdentifier("MessageHistoryDetailTitle")
            
            MessageTextView(text: model.content, onLinkTap: { url in
                
                handleLink(url)
            })
            .frame(height: MessageTextView.calculatedHeight(for: model.content, width: UIScreen.main.bounds.width), alignment: .center)
            .padding(.horizontal, 10)
            .padding(.bottom, 100)
            .accessibilityIdentifier("MessageHistoryDetailText")
        }.padding(.vertical, 25)
    }
}

struct ContentLengthPreference: PreferenceKey {
    
   static var defaultValue: CGFloat { 0 }
   
   static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = nextValue()
   }
}

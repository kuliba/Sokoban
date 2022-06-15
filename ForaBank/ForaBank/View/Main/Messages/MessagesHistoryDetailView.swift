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
                .frame(width: 32, height: 32)
                .foregroundColor(.mainColorsGray)
                .background(Circle().frame(width: 64, height: 64).foregroundColor(.bGIconRedLight))
                .padding(32)
            
            Text(model.title)
                .font(.textH4M16240())
                .foregroundColor(.mainColorsBlack)
            
            ScrollView(showsIndicators: false) {
                Text(model.content)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsBlack)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear.preference(key: ContentLengthPreference.self,
                                                   value: proxy.size.height)
                        }
                    )
            }
            .frame( height: self.textHeight > maxHight ? maxHight : self.textHeight )
            .onPreferenceChange(ContentLengthPreference.self) { value in
                self.textHeight = value }
            
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

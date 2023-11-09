//
//  InputView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import SwiftUI

// MARK: - View

struct InputView: View {
    
    @State private var text: String = ""
    let model: InputViewModel
    
    var body: some View {
    
        let binding = Binding<String>(get: {
            
            model.updateValue(self.text)
            return self.text
            
        }, set: {
            
            self.text = $0
        })
        
        HStack(alignment: .top, spacing: 16) {

            iconView
                .frame(width: 24, height: 24)
                .padding(.top, 5)

            content
                .padding(.trailing, 16)
            
            Spacer()
        }
        .padding(.init(top: 13, leading: 16, bottom: 7, trailing: 16))
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
    }
    
    private var content: some View {
        
        VStack(alignment: .leading, spacing: 11) {
            
            titleView
            
            textFiled
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        
        Image(model.parameter.icon)
            .resizable()
            .renderingMode(.original)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private var titleView: some View {
        
        Text(model.parameter.title)
            .font(.body)
            .foregroundColor(.gray.opacity(0.4))
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                )
            )
    }
    
    @ViewBuilder
    private var textFiled: some View {
            
        TextField(
            model.parameter.title,
            text: $text
        )
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(model: .init(
            parameter: .init(
                value: "123456",
                title: "Введите код",
                icon: "SystemIcon"
            ), updateValue: { _ in }))
    }
}

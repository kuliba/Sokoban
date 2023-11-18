//
//  InputView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import SwiftUI

// MARK: - View

public struct InputView: View {
    
    @State private var text: String = ""
    let model: InputViewModel
    let configuration: InputConfiguration
    
    public var body: some View {
    
        let binding = Binding<String>(get: {
            
            model.updateValue(self.text)
            return self.text
            
        }, set: {
            
            self.text = $0
        })
        
        HStack(alignment: .top, spacing: 16) {

            VStack {
                
                Spacer()
                
                iconView
                    .frame(width: 24, height: 24)
                
                Spacer()
            }

            content
                .padding(.trailing, 16)
            
            Spacer()
        }
        .padding(.init(top: 13, leading: 16, bottom: 13, trailing: 16))
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
        
        model.icon
            .resizable()
            .frame(width: 24, height: 24, alignment: .center)
            .foregroundColor(configuration.iconColor)
    }
    
    @ViewBuilder
    private var titleView: some View {
        
        Text(model.parameter.title)
            .font(configuration.titleFont)
            .foregroundColor(configuration.titleColor)
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

public extension InputView {
    
    struct InputConfiguration {

        let titleFont: Font
        let titleColor: Color
        let iconColor: Color
        
        public init(
            titleFont: Font,
            titleColor: Color,
            iconColor: Color
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.iconColor = iconColor
        }
    }
}

struct InputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InputView(model: .init(
            parameter: .init(
                value: "123456",
                title: "Введите код"
            ),
            icon: .init(systemName: "photo.fill"),
            updateValue: { _ in }),
            configuration: .init(
                titleFont: .body,
                titleColor: .black,
                iconColor: .black
            ))
    }
}

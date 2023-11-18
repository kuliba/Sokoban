//
//  InputView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import SwiftUI

// MARK: - View

struct InputView: View {
    
    @State private var text = ""
    
    let title: String
    let commit: (String) -> Void
    let configuration: InputConfiguration
    
    var body: some View {
        
        let textField = TextField(title, text: $text)
        
        LabeledView(
            title: title,
            configuration: configuration,
            makeLabel: { textField }
        )
        .onChange(of: text, perform: commit)
    }
}

public struct LabeledView<Label: View>: View {
    
    typealias MakeLabel = () -> Label
    
    let title: String
    let configuration: InputConfiguration
    let makeLabel: MakeLabel
    
    public var body: some View {
        
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
            
            makeLabel()
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        
        // TODO: check fallback icon in design
        Image(imageData: .named(configuration.iconName), fallback: .checkmark)
            .resizable()
            .frame(width: 24, height: 24, alignment: .center)
            .foregroundColor(configuration.iconColor)
    }
    
    @ViewBuilder
    private var titleView: some View {
        
        Text(title)
            .font(configuration.titleFont)
            .foregroundColor(configuration.titleColor)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                )
            )
    }
}

public struct InputConfiguration {

    let titleFont: Font
    let titleColor: Color
    let iconColor: Color
    let iconName: String
    
    public init(
        titleFont: Font,
        titleColor: Color,
        iconColor: Color,
        iconName: String
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.iconName = iconName
    }
}

struct InputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        LabeledView(
            title: "Введите код",
            configuration: .init(
                titleFont: .body,
                titleColor: .black,
                iconColor: .black,
                iconName: "photo.fill"
            ),
            makeLabel: { Text("TextField") }
        )
    }
}

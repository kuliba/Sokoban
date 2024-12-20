//
//  LabeledView.swift
//  
//
//  Created by Дмитрий Савушкин on 18.11.2023.
//

import SwiftUI

struct LabeledView<Label: View>: View {
    
    typealias MakeLabel = () -> Label
    
    let title: String
    let configuration: InputConfiguration
    let warning: String?
    let makeLabel: MakeLabel
    
    var body: some View {
        
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
        
        VStack(alignment: .leading, spacing: 2) {
            
            titleView
            
            makeLabel()
            
            if let warning {
                
                Text(warning)
                    .font(configuration.warningFont)
                    .foregroundColor(configuration.warningColor)
            }
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

struct LabeledView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        LabeledView(
            title: "Введите код",
            configuration: .init(
                titleFont: .body,
                titleColor: .black,
                iconColor: .black,
                iconName: "photo.fill",
                warningFont: .body,
                warningColor: .red,
                textFieldFont: .body,
                textFieldColor: .accentColor,
                textFieldTintColor: .black,
                textFieldBackgroundColor: .gray,
                textFieldPlaceholderColor: .gray
            ),
            warning: nil,
            makeLabel: { Text("TextField") }
        )
    }
}

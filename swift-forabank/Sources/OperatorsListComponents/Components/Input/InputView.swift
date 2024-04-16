//
//  InputView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI

struct InputView: View {
    
    @State private var text: String = ""
    let inputState: InputState
    let inputEvent: (InputEvent) -> Void
    let config: InputConfigView
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                inputState.image()
                    .resizable()
                    .frame(width: config.imageSize.rawValue, height: config.imageSize.rawValue, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(config.title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    TextField(config.placeholder, text: $text)
                }
            }
            
            if let hint = config.hint {
                
                HStack(alignment: .center, spacing: 16) {
                    
                    Color.clear
                        .frame(width: config.imageSize.rawValue, height: config.imageSize.rawValue, alignment: .leading)
                    
                    Text(hint)
                        .font(config.hintFont)
                        .foregroundColor(config.hintColor)
                }
            }
        }
        .padding(.horizontal, config.imageSize == .small ? 16 : 12)
        .padding(.vertical, 13)
        .background(config.backgroundColor)
        .cornerRadius(12)
    }
    
    struct InputConfigView {
        
        let title: String
        let titleFont: Font
        let titleColor: Color
        
        let textFieldFont: Font
        
        let placeholder: String
        
        let hint: String?
        let hintFont: Font
        let hintColor: Color
        
        let backgroundColor: Color
        
        let imageSize: ImageSize
        
        enum ImageSize: CGFloat {
            
            case small = 24
            case large = 32
        }
    }
}

private extension InputView.InputConfigView {
    
    static let preview: Self = .init(
        title: "Лицевой счет",
        titleFont: .title3,
        titleColor: .gray,
        textFieldFont: .body,
        placeholder: "Введите лицевой счет",
        hint: nil,
        hintFont: .body,
        hintColor: .gray,
        backgroundColor: .gray.opacity(0.1),
        imageSize: .large
    )
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InputView(
                inputState: .init(image: { .init(systemName: "photo.artframe") }),
                inputEvent: { _ in },
                config: .preview
            )
            .padding(20)
            
            InputView(
                inputState: .init(image: { .init(systemName: "photo.artframe") }),
                inputEvent: { _ in },
                config: .preview
            )
            .padding(20)
        }
    }
}

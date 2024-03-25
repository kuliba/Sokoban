//
//  InputView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI

public struct InputView: View {
    
    @State private var text: String = ""
    let state: InputState
    let event: (InputEvent) -> Void
    let config: Config
    
    public init(
        state: InputState,
        event: @escaping (InputEvent) -> Void,
        config: InputView.Config
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                state.image()
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
    
    public struct Config {
        
        public let title: String
        public let titleFont: Font
        public let titleColor: Color
        
        public let textFieldFont: Font
        
        public let placeholder: String
        
        public let hint: String?
        public let hintFont: Font
        public let hintColor: Color
        
        public let backgroundColor: Color
        
        public let imageSize: ImageSize
        
        public init(
            title: String,
            titleFont: Font,
            titleColor: Color,
            textFieldFont: Font,
            placeholder: String,
            hint: String? = nil,
            hintFont: Font,
            hintColor: Color,
            backgroundColor: Color,
            imageSize: InputView.Config.ImageSize
        ) {
            self.title = title
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.textFieldFont = textFieldFont
            self.placeholder = placeholder
            self.hint = hint
            self.hintFont = hintFont
            self.hintColor = hintColor
            self.backgroundColor = backgroundColor
            self.imageSize = imageSize
        }
        
        public enum ImageSize: CGFloat {
            
            case small = 24
            case large = 32
        }
    }
}

public extension InputView.Config {
    
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
                state: .init(image: { .init(systemName: "photo.artframe") }),
                event: { _ in },
                config: .preview
            )
            .padding(20)
            
            InputView(
                state: .init(image: { .init(systemName: "photo.artframe") }),
                event: { _ in },
                config: .preview
            )
            .padding(20)
        }
    }
}

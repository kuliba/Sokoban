//
//  StickerView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

// MARK: - View

struct StickerView: View {
    
    let viewModel: StickerViewModel
    let config: StickerViewConfiguration
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(config.rectangleColor)
            
            VStack(alignment: .leading, spacing: 20) {
                
                HeaderView(
                    viewModel: viewModel.header,
                    config: config.configHeader
                )
                
                HStack(alignment: .top, spacing: 20) {
                    
                    Image("StickerPreview")
                        .resizable()
                        .frame(width: 112, height: 72, alignment: .center)
                    
                    VStack {
                        
                        ForEach(viewModel.options) { option in
                            OptionView(
                                viewModel: option,
                                config: config.configOption
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension StickerView {
    
    // MARK: - Header
    
    struct HeaderView: View {
        
        let viewModel: StickerViewModel.HeaderViewModel
        let config: StickerViewConfiguration.Header
        
        var body: some View {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    Text(viewModel.detailTitle)
                        .font(config.descriptionFont)
                        .foregroundColor(config.descriptionColor)
                }
                
                Spacer()
                
            }.padding([.leading, .trailing, .top], 20)
        }
    }
    
    // MARK: - Option
    
    struct OptionView: View {
        
        let viewModel: StickerViewModel.OptionViewModel
        let config: StickerViewConfiguration.Option
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title)
                    .font(config.titleFont)
                    .foregroundColor(config.titleColor)
                
                HStack {
                    
                    if let name = viewModel.icon.name {
                        
                        Image(name)
                            .renderingMode(.template)
                            .foregroundColor(config.iconColor)
                    }
                    
                    Text(viewModel.description)
                        .font(config.optionFont)
                        .foregroundColor(config.optionColor)
                }
            }
        }
    }
}

public struct StickerViewConfiguration {
    
    let rectangleColor: Color
    let configHeader: Header
    let configOption: Option
    
    public init(
        rectangleColor: Color,
        configHeader: Header,
        configOption: Option
    ) {
        self.rectangleColor = rectangleColor
        self.configHeader = configHeader
        self.configOption = configOption
    }
    
    public struct Header {
        
        let titleFont: Font
        let titleColor: Color
        let descriptionFont: Font
        let descriptionColor: Color
        
        public init(
            titleFont: Font,
            titleColor: Color,
            descriptionFont: Font,
            descriptionColor: Color
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.descriptionFont = descriptionFont
            self.descriptionColor = descriptionColor
        }
    }
    
    public struct Option {
        
        let titleFont: Font
        let titleColor: Color
        
        let iconColor: Color
        
        let descriptionFont: Font
        let descriptionColor: Color
        
        let optionFont: Font
        let optionColor: Color
        
        public init(
            titleFont: Font,
            titleColor: Color,
            iconColor: Color,
            descriptionFont: Font,
            descriptionColor: Color,
            optionFont: Font,
            optionColor: Color
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.iconColor = iconColor
            self.descriptionFont = descriptionFont
            self.descriptionColor = descriptionColor
            self.optionColor = optionColor
            self.optionFont = optionFont
        }
    }
}

extension Operation.Parameter.Sticker: Identifiable {
    
    public var id: Self { self }
}

struct ParameterStickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        StickerView(
            viewModel: .init(
                header: .init(
                    title: "header",
                    detailTitle: "detailTitle"
                ),
                sticker: .data(.empty),
                options: [.init(
                    title: "option title",
                    icon: .data(.empty),
                    description: "description",
                    iconColor: ""
                )]),
            config: .init(
                rectangleColor: .black,
                configHeader: .init(
                    titleFont: .body,
                    titleColor: .blue,
                    descriptionFont: .body,
                    descriptionColor: .accentColor
                ),
                configOption: .init(
                    titleFont: .body,
                    titleColor: .black,
                    iconColor: .blue,
                    descriptionFont: .body,
                    descriptionColor: .accentColor,
                    optionFont: .body,
                    optionColor: .black
                ))
        )
    }
}

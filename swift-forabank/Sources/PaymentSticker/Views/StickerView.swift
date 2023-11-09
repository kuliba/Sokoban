//
//  StickerView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

// MARK: - View

struct StickerView<OpenAccountCardView: View>: View {
    
    let viewModel: StickerViewModel
    let openAccountCardView: () -> OpenAccountCardView
    let config: ParameterStickerViewConfig
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(config.rectangleColor)
            
            VStack(alignment: .leading) {
                
                HeaderView(
                    viewModel: viewModel.header,
                    config: config.configHeader
                )
                
                HStack(alignment: .top, spacing: 20) {
                    
                    openAccountCardView()
                    
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
        .frame(height: 200)
    }
}

extension StickerView {
    
    // MARK: - Header
    
    struct HeaderView: View {
        
        let viewModel: StickerViewModel.HeaderViewModel
        let config: ParameterStickerViewConfig.Header
        
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
        let config: ParameterStickerViewConfig.Option
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title)
                    .font(config.titleFont)
                    .foregroundColor(config.titleColor)
                
                HStack {
                    
                    viewModel.icon
                        .renderingMode(.template)
                        .foregroundColor(config.iconColor)
                    
                    Text(viewModel.description)
                        .font(config.descriptionFont)
                        .foregroundColor(config.descriptionColor)
                }
            }
        }
    }
}

struct ParameterStickerViewConfig {
    
    let rectangleColor: Color
    let configHeader: Header
    let configOption: Option
    
    struct Header {
        
        let titleFont: Font
        let titleColor: Color
        let descriptionFont: Font
        let descriptionColor: Color
    }
    
    struct Option {
        
        let titleFont: Font
        let titleColor: Color
        
        let iconColor: Color
        
        let descriptionFont: Font
        let descriptionColor: Color
    }
}

extension Operation.Parameter.Sticker: Identifiable {
    
    public var id: Self { self }
}

extension ParameterStickerViewConfig {
    
    static let `default`: Self = .init(
        rectangleColor: .gray,
        configHeader: .init(
            titleFont: .body,
            titleColor: .accentColor,
            descriptionFont: .body,
            descriptionColor: .accentColor
        ),
        configOption: .init(
            titleFont: .body,
            titleColor: .accentColor,
            iconColor: .accentColor,
            descriptionFont: .body,
            descriptionColor: .accentColor
        )
    )
}
struct ParameterStickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        StickerView(
            viewModel: .init(
                header: .init(
                    title: "header",
                    detailTitle: "detailTitle"
            ),
                options: [.init(
                    title: "option title",
                    icon: .init("Arrow Circle"),
                    description: "description",
                    iconColor: .green
                )]),
            openAccountCardView: {
                Color.red.frame(width: 120)
            },                 
            config: .default)
    }
}

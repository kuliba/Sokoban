//
//  HeaderView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import SwiftUI

public struct HeaderView: View {
    
    public typealias Config = HeaderViewConfig
    
    let header: Header
    let config: Config
    let imageFactory: ImageViewFactory
    
    public init(
        header: Header,
        config: Config,
        imageFactory: ImageViewFactory
    ) {
        self.header = header
        self.config = config
        self.imageFactory = imageFactory
    }
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            header.imageUrl.map(imageFactory.makeBannerImageView)
                .aspectRatio(contentMode: .fill)
            
            textView()
                .padding(.leading, config.layout.textViewLeadingPadding)
                .padding(.trailing, config.layout.textViewTrailingPadding)
        }
    }
}

private extension HeaderView {
    
    func textView() -> some View {
        
        VStack(spacing: config.layout.textViewVerticalSpacing) {
            
            header.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: config.layout.textViewOptionsVerticalSpacing) {
                
                ForEach(header.options, id: \.self, content: optionView)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func optionView(
        _ option: String
    ) -> some View {
        
        HStack(alignment: .center, spacing: config.layout.itemOption.horizontalSpacing) {
            
            Circle()
                .foregroundStyle(config.optionPlaceholder)
                .frame(width: config.layout.itemOption.circleRadius, height: config.layout.itemOption.circleRadius, alignment: .center)
            
            Text(option)
                .frame(maxWidth:
                        config.layout.itemOption.optionWidth, alignment: .leading)
                .font(config.option.textFont)
                .foregroundStyle(config.option.textColor)
        }
    }
}

#Preview {
    
    ScrollView(.vertical, showsIndicators: false) {
        
        LazyVStack(spacing: 16) {
            
            HeaderView(
                header: .preview,
                config: .preview,
                imageFactory: .default
            )
        }
    }
}

private extension HeaderViewConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .body,
            textColor: .black
        ),
        optionPlaceholder: .black,
        option: .init(
            textFont: .body,
            textColor: .red
        ),
        layout: .init(
            itemOption: .init(
                circleRadius: 5,
                horizontalSpacing: 5,
                optionWidth: 150
            ),
            textViewLeadingPadding: 16,
            textViewOptionsVerticalSpacing: 20,
            textViewTrailingPadding: 15,
            textViewVerticalSpacing: 26
        )
    )
}

private extension Header {
    
    static let preview: Self = .init(
        title: "titile", 
        navTitle: "navTitle",
        navSubtitle: "navSubtitle",
        options: ["option"],
        imageUrl: "1"
    )
}

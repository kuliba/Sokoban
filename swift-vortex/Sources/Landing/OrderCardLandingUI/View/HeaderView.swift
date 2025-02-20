//
//  HeaderView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import SwiftUI
import UIPrimitives
import HeaderLandingComponent

struct HeaderView: View {
    
    typealias Config = HeaderViewConfig
    
    let header: Header
    let config: Config
    let imageFactory: ImageViewFactory
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            header.md5Hash.map(imageFactory.makeIconView)
            
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
        
        //TODO: constants extract to config
        HStack(alignment: .center, spacing: config.layout.itemOption.horizontalSpacing) {
            
            Circle()
                .foregroundStyle(config.optionPlaceholder)
                .frame(width: 5, height: 5, alignment: .center)
            
            Text(option)
                .frame(maxWidth: 150, alignment: .leading)
        }
    }
}

struct Header {
    
    let title: String
    let options: [String]
    let md5Hash: String?
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
        option: .init(textFont: .body, textColor: .red),
        layout: .init(
            itemOption: .init(
                horizontalSpacing: 5
            ),
            textViewLeadingPadding: 16,
            textViewOptionsVerticalSpacing: 20,
            textViewTrailingPadding: 15,
            textViewVerticalSpacing: 26
        )
    )
}

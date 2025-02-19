//
//  HeaderView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import SwiftUI
import UIPrimitives

struct HeaderView: View {
    
    typealias Model = Header
    typealias Config = HeaderViewConfig
    
    let model: Model
    let config: Config
    let imageFactory: ImageViewFactory
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            if let md5Hash = model.md5Hash {
                
                imageFactory.makeIconView(md5Hash)
            }
            
            textView()
                .padding(.leading, config.layout.textViewLeadingPadding)
                .padding(.trailing, config.layout.textViewTrailingPadding)
        }
    }
}

private extension HeaderView {
    
    func textView() -> some View {
        
        //TODO: constants extract to config
        VStack(spacing: 26) {
            
            model.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                
                ForEach(model.options, id: \.self, content: optionView)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func optionView(
        _ option: String
    ) -> some View {
        
        //TODO: constants extract to config
        HStack(alignment: .center, spacing: 5) {
            
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
                model: .preview,
                config: .init(
                    title: .init(
                        textFont: .body,
                        textColor: .black
                    ),
                    optionPlaceholder: .black,
                    layout: .init(
                        textViewLeadingPadding: 16,
                        textViewTrailingPadding: 15
                    )
                ),
                imageFactory: .default
            )
        }
    }
}

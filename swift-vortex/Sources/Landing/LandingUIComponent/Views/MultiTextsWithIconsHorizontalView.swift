//
//  MultiTextsWithIconsHorizontalView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

typealias ComponentMTWIH = UILanding.Multi.TextsWithIconsHorizontal
typealias ConfigMTWIH = UILanding.Multi.TextsWithIconsHorizontal.Config

struct MultiTextsWithIconsHorizontalView: View {
    
    @ObservedObject var model: ViewModel
    let config: ConfigMTWIH
    
    var body: some View {
        
        HStack {
            
            ForEach(model.data.lists) {
                
                ItemView(
                    item: $0,
                    image: model.image(byMd5Hash: $0.md5hash),
                    config: config)
            }
        }
        .padding(.horizontal, config.padding.horizontal)
        .padding(.vertical, config.padding.vertical)
    }
}

extension MultiTextsWithIconsHorizontalView {
    
    typealias Item = ComponentMTWIH.Item
    
    struct ItemView: View {
        
        let item: Item
        let image: Image?
        let config: ConfigMTWIH
        
        var body: some View {
            
            HStack {
                
                image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: config.size, height: config.size)
                
                if let textItem = item.title {
                    
                    Text(textItem)
                        .font(config.font)
                        .foregroundColor(config.color)
                        .accessibilityIdentifier("MultiTextsWithIconsHorizontalItemText")
                }
            }
            .padding(.vertical, config.padding.itemVertical)
            .accessibilityIdentifier("MultiTextsWithIconsHorizontalItem")
        }
    }
}

struct MultiTextsWithIconsHorizontalView_Previews: PreviewProvider {
    static var previews: some View {
        
        MultiTextsWithIconsHorizontalView(
            model: .init(
                data: .init(
                    lists: [
                        .defaultItemOne,
                        .defaultItemTwo
                    ]),
                images: .defaultValue),
            config: .defaultValueBlack
        )
    }
}

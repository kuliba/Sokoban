//
//  MultiTextsWithIconsHorizontalView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

typealias ComponentMTWIH = Landing.MultiTextsWithIconsHorizontal
typealias ConfigMTWIH = Landing.MultiTextsWithIconsHorizontal.Config

struct MultiTextsWithIconsHorizontalView: View {
    
    let model: ComponentMTWIH
    let config: ConfigMTWIH
    
    var body: some View {
        
        HStack {
            
            ForEach(model.lists) {
                
                ItemView(
                    item: $0,
                    config: config)
            }
        }
    }
}

extension MultiTextsWithIconsHorizontalView {
    
    typealias Item = ComponentMTWIH.Item
    
    struct ItemView: View {
        
        let item: Item
        let config: ConfigMTWIH
        
        var body: some View {
            
            HStack {
                
                item.image
                
                if let textItem = item.title {
                    
                    Text(textItem)
                        .font(config.font)
                        .foregroundColor(config.color)
                }
            }
        }
    }
}

struct MultiTextsWithIconsHorizontalView_Previews: PreviewProvider {
    static var previews: some View {
        
        MultiTextsWithIconsHorizontalView(
            model: .init(lists: [
                .defaultItemOne,
                .defaultItemTwo
            ]),
            config: .defaultValueBlack
        )
    }
}

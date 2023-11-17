//
//  MultiTextsWithIconsHorizontalView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiTextsWithIconsHorizontalView: View {
    
    let model: MultiTextsWithIconsHorizontalViewModel
    let config: Config
    
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
    
    typealias Item = MultiTextsWithIconsHorizontalViewModel.Item
    
    struct ItemView: View {
        
        let item: Item
        let config: Config
        
        var body: some View {
            
            HStack {
                
                item.image
                
                if let textItem = item.title {
                    
                    Text(textItem.title)
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
            model: .init(
                lists: .defaultValue),
            config: .defaultValueBlack
        )
    }
}

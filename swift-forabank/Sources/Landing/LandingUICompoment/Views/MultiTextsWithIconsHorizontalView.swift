//
//  MultiTextsWithIconsHorizontalView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiTextsWithIconsHorizontalView: View {
    
    let model: MultiTextsWithIconsHorizontalViewModel
    
    var body: some View {
        
        HStack {
            
            ForEach(model.lists) {
                
                ItemView(item: $0)
            }
        }
    }
}

extension MultiTextsWithIconsHorizontalView {
    
    typealias Item = MultiTextsWithIconsHorizontalViewModel.Item
    
    struct ItemView: View {
        
        let item: Item
        
        var body: some View {
            
            HStack {
                
                item.image
                
                if let textItem = item.title {
                    
                    Text(textItem.title)
                        .font(textItem.font)
                        .foregroundColor(textItem.textColor)
                }
            }
        }
    }
}

struct MultiTextsWithIconsHorizontalView_Previews: PreviewProvider {
    static var previews: some View {
        
        MultiTextsWithIconsHorizontalView(
            model: .init(lists: .defaultValue)
        )
    }
}

//
//  BlockHorizontalRectangularView.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import SwiftUI
import Combine
import UIPrimitives

struct BlockHorizontalRectangularView: View {
    
    let model: ViewModel
    let config: UILanding.BlockHorizontalRectangular.Config
        
    var body: some View {
            
            ScrollView(.horizontal, showsIndicators: false) {
               
                HStack(spacing: config.spacing) {
                    ForEach(model.data.list, content: itemView)
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
    }
    
    private func itemView (item: UILanding.BlockHorizontalRectangular.Item) -> some View {
        
        ItemView(
            item: item,
            config: config
        )
    }
}

extension BlockHorizontalRectangularView {
    
    struct ItemView: View {
        
        let item: UILanding.BlockHorizontalRectangular.Item
        let config: UILanding.BlockHorizontalRectangular.Config
        
        var body: some View {
            // TODO: - add view
            Text("BlockHorizontalRectangular")
        }
    }
}

struct BlockHorizontalRectangularView_Previews: PreviewProvider {
    static var previews: some View {
        
        BlockHorizontalRectangularView(
            model: .defaultValue,
            config: .default)
    }
}

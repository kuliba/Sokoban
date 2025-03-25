//
//  PlaceholderConfig.swift
//
//
//  Created by Дмитрий Савушкин on 25.03.2025.
//

import SwiftUI

struct PlaceholderLandingViewConfig {
    
    let cover: Cover
    let items: Items
    let list: Item
    let dropDownList: DropDownList
    let heroButton: Button
    let hpadding: CGFloat
    let vpadding: CGFloat
    let background: Color
    let cornerRadius: CGFloat
    
    struct Button {
        
        let height: CGFloat
        let cornerRadius: CGFloat
        let hpadding: CGFloat
    }
    struct DropDownList {
        
        let colorItem: Color
        let itemIconSize: CGFloat
        let lineHeight: CGFloat
        let cornerRadius: CGFloat
        let vspacing: CGFloat
        let itemsCount: Int
        let hpadding: CGFloat
        let hspacingItem: CGFloat
    }
    
    struct Item {
        
        let vspacing: CGFloat
        let countItems: Int
        let colorItem: Color
        let itemHeight: CGFloat
        let cornerRadius: CGFloat
    }
    
    struct Items {
        
        let verticalSpacing: CGFloat
        let itemColor: Color
        let titleItemHeight: CGFloat
        let countItems: Int
        let item: Item
        
        struct Item {
            
            let color: Color
            let iconSize: CGFloat
            let hspacing: CGFloat
            let vspacing: CGFloat
            let cornerRadius: CGFloat
            let heightTitle: CGFloat
            let heightSubtitle: CGFloat
        }
    }
    
    struct Cover {
        
        let verticalSpacing: CGFloat
        let coverColor: Color
        let itemsSpacing: CGFloat
        let itemsLeadingPadding: CGFloat
        let item: Item
        let vspacingItems: CGFloat
        
        struct Item {
            
            let color: Color
            let height: CGFloat
            let weight: CGFloat
            let cornerRadius: CGFloat
        }
    }
}

//
//  PlaceholderConfig.swift
//
//
//  Created by Дмитрий Савушкин on 25.03.2025.
//

import SwiftUI

struct PlaceholderConfig {
    
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

extension PlaceholderConfig {
    
    static let preview: Self = .init(
        cover: .init(
            verticalSpacing: 20,
            coverColor: Color.gray,
            itemsSpacing: 32,
            itemsLeadingPadding: 16,
            item: .init(
                color: Color.gray,
                height: 100,
                weight: 8,
                cornerRadius: 90
            ),
            vspacingItems: 12
        ),
        items: .init(
            verticalSpacing: 8,
            itemColor:  Color.gray,
            titleItemHeight: 24,
            countItems: 4,
            item: .init(
                color: Color.gray,
                iconSize: 40,
                hspacing: 16,
                vspacing: 6,
                cornerRadius: 90,
                heightTitle: 14,
                heightSubtitle: 18
            )
        ),
        list: .init(
            vspacing: 36,
            countItems: 4,
            colorItem: Color.gray,
            itemHeight: 24,
            cornerRadius: 90
        ),
        dropDownList: .init(
            colorItem: Color.gray,
            itemIconSize: 24,
            lineHeight: 8,
            cornerRadius: 90,
            vspacing: 16,
            itemsCount: 2,
            hpadding: 16,
            hspacingItem: 16
        ),
        heroButton: .init(
            height: 56,
            cornerRadius: 12,
            hpadding: 16
        ),
        hpadding: 16,
        vpadding: 12,
        background: Color.gray,
        cornerRadius: 12
    )
}

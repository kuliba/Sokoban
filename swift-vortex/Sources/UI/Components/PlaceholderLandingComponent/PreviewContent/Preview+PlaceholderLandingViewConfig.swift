//
//  Preview+PlaceholderLandingViewConfig.swift
//
//
//  Created by Дмитрий Савушкин on 25.03.2025.
//

import SwiftUI

extension PlaceholderLandingViewConfig {
    
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

//
//  ProductLandingConfig.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SharedConfigs
import SwiftUI

public struct ProductLandingConfig {
    
    let buttonsConfig: ButtonsConfig
    let conditionButtonConfig: ConditionButtonConfig
    let imageCoverConfig: ImageCoverConfig
    let item: ItemConfig
    let orderButtonConfig: OrderButtonConfig
    let titleDark: TextConfig
    let titleLight: TextConfig
    
    public init(
        buttonsConfig: ProductLandingConfig.ButtonsConfig,
        conditionButtonConfig: ProductLandingConfig.ConditionButtonConfig,
        item: ProductLandingConfig.ItemConfig,
        imageCoverConfig: ProductLandingConfig.ImageCoverConfig,
        orderButtonConfig: ProductLandingConfig.OrderButtonConfig,
        titleDark: TextConfig,
        titleLight: TextConfig
    ) {
        self.buttonsConfig = buttonsConfig
        self.conditionButtonConfig = conditionButtonConfig
        self.item = item
        self.imageCoverConfig = imageCoverConfig
        self.orderButtonConfig = orderButtonConfig
        self.titleDark = titleDark
        self.titleLight = titleLight
    }
    
    public struct ButtonsConfig {
        
        let buttonsPadding: CGFloat
        let buttonsSpacing: CGFloat
        let buttonsHeight: CGFloat
        
        public init(
            buttonsPadding: CGFloat,
            buttonsSpacing: CGFloat,
            buttonsHeight: CGFloat
        ) {
            self.buttonsPadding = buttonsPadding
            self.buttonsSpacing = buttonsSpacing
            self.buttonsHeight = buttonsHeight
        }
    }
    
    public struct ImageCoverConfig {
        
        let height: CGFloat
        let cornerRadius: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        
        public init(
            height: CGFloat,
            cornerRadius: CGFloat,
            horizontalPadding: CGFloat,
            verticalPadding: CGFloat
        ) {
            self.height = height
            self.cornerRadius = cornerRadius
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
        }
    }
    
    public struct OrderButtonConfig {
        
        let background: Color
        let cornerRadius: CGFloat
        let title: TitleConfig
        
        public init(
            background: Color,
            cornerRadius: CGFloat,
            title: TitleConfig
        ) {
            self.background = background
            self.cornerRadius = cornerRadius
            self.title = title
        }
    }
    
    public struct ConditionButtonConfig {
        
        let icon: Image
        let foregroundColorDark: Color
        let foregroundColorLight: Color
        let spacing: CGFloat
        let frame: CGFloat
        let title: String
        let titleDark: TextConfig
        let titleLight: TextConfig
        
        public init(
            icon: Image,
            foregroundColorDark: Color,
            foregroundColorLight: Color,
            spacing: CGFloat,
            frame: CGFloat,
            title: String,
            titleDark: TextConfig,
            titleLight: TextConfig
        ) {
            self.icon = icon
            self.foregroundColorDark = foregroundColorDark
            self.foregroundColorLight = foregroundColorLight
            self.spacing = spacing
            self.frame = frame
            self.title = title
            self.titleDark = titleDark
            self.titleLight = titleLight
        }
    }
    
    public struct ItemConfig {
        
        let circle: CGFloat
        let titleDark: TextConfig
        let titleLight: TextConfig
        let itemPadding: CGFloat
        
        public init(
            circle: CGFloat,
            titleDark: TextConfig,
            titleLight: TextConfig,
            itemPadding: CGFloat
        ) {
            self.circle = circle
            self.titleDark = titleDark
            self.titleLight = titleLight
            self.itemPadding = itemPadding
        }
    }
}

//
//  ProductLandingConfig.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SharedConfigs
import SwiftUI

public struct ProductLandingConfig {
    
    let background: Color
    let buttonsConfig: ButtonsConfig
    let conditionButtonConfig: ConditionButtonConfig
    let item: ItemConfig
    let imageCoverConfig: ImageCoverConfig
    let orderButtonConfig: OrderButtonConfig
    let title: TextConfig
    
    public init(
        background: Color,
        buttonsConfig: ProductLandingConfig.ButtonsConfig,
        conditionButtonConfig: ProductLandingConfig.ConditionButtonConfig,
        item: ProductLandingConfig.ItemConfig,
        imageCoverConfig: ProductLandingConfig.ImageCoverConfig,
        orderButtonConfig: ProductLandingConfig.OrderButtonConfig,
        title: TextConfig
    ) {
        self.background = background
        self.buttonsConfig = buttonsConfig
        self.conditionButtonConfig = conditionButtonConfig
        self.item = item
        self.imageCoverConfig = imageCoverConfig
        self.orderButtonConfig = orderButtonConfig
        self.title = title
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
        let spacing: CGFloat
        let frame: CGFloat
        let title: TitleConfig
        
        public init(
            icon: Image,
            spacing: CGFloat,
            frame: CGFloat,
            title: TitleConfig
        ) {
            self.icon = icon
            self.spacing = spacing
            self.frame = frame
            self.title = title
        }
    }
    
    public struct ItemConfig {
        
        let circle: CGFloat
        let title: TextConfig
        let itemPadding: CGFloat
        
        public init(
            circle: CGFloat,
            title: TextConfig,
            itemPadding: CGFloat
        ) {
            self.circle = circle
            self.title = title
            self.itemPadding = itemPadding
        }
    }
}

//
//  OrderSavingsAccountConfig.swift
//
//
//  Created by Andryusina Nataly on 26.11.2024.
//

import SwiftUI
import SharedConfigs
import PaymentComponents

public struct OrderSavingsAccountConfig {

    let amount: AmountConfig
    let background: Color
    let backImage: Image
    let cornerRadius: CGFloat
    let header: TextWithConfig
    let income: Income
    let openButton: OpenButton
    let order: Order
    let padding: CGFloat
    let topUp: TopUp
    
    public init(
        amount: AmountConfig,
        background: Color,
        backImage: Image,
        cornerRadius: CGFloat,
        header: TextWithConfig,
        income: Income,
        openButton: OpenButton,
        order: Order,
        padding: CGFloat,
        topUp: TopUp
    ) {
        self.amount = amount
        self.background = background
        self.backImage = backImage
        self.cornerRadius = cornerRadius
        self.header = header
        self.income = income
        self.openButton = openButton
        self.order = order
        self.padding = padding
        self.topUp = topUp
    }
    
    public struct OpenButton {
        
        let background: Color
        let cornerRadius: CGFloat
        let height: CGFloat
        let label: String
        let title: TextConfig
        
        public init(
            background: Color,
            cornerRadius: CGFloat,
            height: CGFloat,
            label: String,
            title: TextConfig
        ) {
            self.background = background
            self.cornerRadius = cornerRadius
            self.height = height
            self.label = label
            self.title = title
        }
    }
    
    public struct TextWithConfig {
        
        let text: String
        let config: TextConfig
        
        public init(
            text: String,
            config: TextConfig
        ) {
            self.text = text
            self.config = config
        }
    }
    
    public struct TopUp {
        
        let description: TextWithConfig
        let image: Image
        let subtitle: TextWithConfig
        let title: TextWithConfig
        let toggle: ToggleConfig
        
        public init(
            description: TextWithConfig,
            image: Image,
            subtitle: TextWithConfig,
            title: TextWithConfig,
            toggle: ToggleConfig
        ) {
            self.description = description
            self.image = image
            self.subtitle = subtitle
            self.title = title
            self.toggle = toggle
        }
    }
        
    public struct Income {
        
        let image: Image
        let imageSize: CGSize
        let title: TextWithConfig
        let subtitle: TextConfig
        
        public init(
            image: Image,
            imageSize: CGSize,
            title: TextWithConfig,
            subtitle: TextConfig
        ) {
            self.image = image
            self.imageSize = imageSize
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    public struct Order {
        
        let card: CGSize
        let header: TitleWithSubtitle
        let image: Image
        let imageSize: CGSize
        let options: Options
        
        public init(
            card: CGSize,
            header: TitleWithSubtitle,
            image: Image,
            imageSize: CGSize,
            options: Options
        ) {
            self.card = card
            self.header = header
            self.image = image
            self.imageSize = imageSize
            self.options = options
        }
    }
    
    public struct Options {
        
        let headlines: Headlines
        let config: TitleWithSubtitle
        
        public init(
            headlines: Headlines,
            config: TitleWithSubtitle
        ) {
            self.headlines = headlines
            self.config = config
        }
    }
    
    public struct Headlines {
        
        let open: String
        let service: String
        
        public init(
            open: String,
            service: String
        ) {
            self.open = open
            self.service = service
        }
    }
    
    public struct TitleWithSubtitle {
        
        let title: TextConfig
        let subtitle: TextConfig
        
        public init(
            title: TextConfig,
            subtitle: TextConfig
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}


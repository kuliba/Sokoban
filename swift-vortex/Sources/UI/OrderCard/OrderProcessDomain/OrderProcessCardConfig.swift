//
//  OrderProcessCardConfig.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import SwiftUI
import SharedConfigs
import PaymentComponents
import LinkableText
import UIPrimitives

public struct OrderProcessCardConfig {
    
    let background: Color
    let cornerRadius: CGFloat
    let header: TextWithConfig
    let income: Income
    let openButton: OpenButton
    let order: Order
    let padding: CGFloat
    let shimmering: Color
    let topUp: TopUp
    
    public init(
        background: Color,
        cornerRadius: CGFloat,
        header: TextWithConfig,
        income: Income,
        openButton: OpenButton,
        order: Order,
        padding: CGFloat,
        shimmering: Color,
        topUp: TopUp
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.header = header
        self.income = income
        self.openButton = openButton
        self.order = order
        self.padding = padding
        self.shimmering = shimmering
        self.topUp = topUp
    }
    
    public struct OpenButton {
        
        let background: Colors
        let cornerRadius: CGFloat
        let height: CGFloat
        let labels: Labels
        let title: TextConfig

        public struct Labels {
            
            let open: String
            let confirm: String
            
            public init(
                open: String,
                confirm: String
            ) {
                self.open = open
                self.confirm = confirm
            }
        }
        
        public struct Colors {
            
            let active: Color
            let inactive: Color
            
            public init(
                active: Color,
                inactive: Color
            ) {
                self.active = active
                self.inactive = inactive
            }
        }
        
        public init(
            background: Colors,
            cornerRadius: CGFloat,
            height: CGFloat,
            labels: Labels,
            title: TextConfig
        ) {
            self.background = background
            self.cornerRadius = cornerRadius
            self.height = height
            self.labels = labels
            self.title = title
        }
    }
        
    public struct TopUp {
        
        let amount: AmountInfo
        let description: TextWithConfig
        let image: Image
        let subtitle: TextWithConfig
        let title: TextWithConfig
        let toggle: ToggleConfig
        
        public struct AmountInfo {
            
            let amount: TextWithConfig
            let fee: TextWithConfig
            let value: TextConfig
            
            public init(
                amount: TextWithConfig,
                fee: TextWithConfig,
                value: TextConfig
            ) {
                self.amount = amount
                self.fee = fee
                self.value = value
            }
        }
        
        public init(
            amount: AmountInfo,
            description: TextWithConfig,
            image: Image,
            subtitle: TextWithConfig,
            title: TextWithConfig,
            toggle: ToggleConfig
        ) {
            self.amount = amount
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

public struct TextWithConfig: Equatable {
    
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

public struct ToggleConfig {
    
    let size: CGSize
    let padding: CGFloat
    let lineWidth: CGFloat
    let colors: Colors
    
    public struct Colors {
        
        let on: Color
        let off: Color
        
        public init(on: Color, off: Color) {
            self.on = on
            self.off = off
        }
    }
    
    public init(
        size: CGSize = .init(width: 51, height: 31),
        padding: CGFloat = 5,
        lineWidth: CGFloat = 1,
        colors: Colors
    ) {
        self.size = size
        self.padding = padding
        self.lineWidth = lineWidth
        self.colors = colors
    }
}

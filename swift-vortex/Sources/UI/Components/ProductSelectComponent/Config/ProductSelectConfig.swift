//
//  ProductSelectConfig.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SharedConfigs
import SwiftUI
import CarouselComponent

public struct ProductSelectConfig {
    
    let amount: TextConfig
    public let card: Card
    let chevron: Chevron
    let footer: TextConfig
    let header: TextConfig
    let missingSelected: MissingSelected
    let title: TextConfig
    let carouselConfig: CarouselComponentConfig
    
    public init(
        amount: TextConfig,
        card: Card,
        chevron: Chevron,
        footer: TextConfig,
        header: TextConfig,
        missingSelected: MissingSelected,
        title: TextConfig,
        carouselConfig: CarouselComponentConfig
    ) {
        self.amount = amount
        self.card = card
        self.chevron = chevron
        self.footer = footer
        self.header = header
        self.missingSelected = missingSelected
        self.title = title
        self.carouselConfig = carouselConfig
    }
}

public extension ProductSelectConfig {
    
    struct Card {
        
        let amount: TextConfig
        let cardSize: CGSize
        let number: TextConfig
        let title: TextConfig
        let selectedImage: Image
        
        public init(
            amount: TextConfig,
            cardSize: CGSize = .init(width: 112, height: 71),
            number: TextConfig,
            title: TextConfig,
            selectedImage: Image
        ) {
            self.amount = amount
            self.cardSize = cardSize
            self.number = number
            self.title = title
            self.selectedImage = selectedImage
        }
    }
    
    struct Chevron {
        
        let color: Color
        let image: Image
        
        public init(
            color: Color,
            image: Image
        ) {
            self.color = color
            self.image = image
        }
    }
    
    struct MissingSelected {
        
        let backgroundColor: Color
        let foregroundColor: Color
        let image: Image
        let title: TextConfig
        
        public init(
            backgroundColor: Color,
            foregroundColor: Color,
            image: Image,
            title: TextConfig
        ) {
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.image = image
            self.title = title
        }
    }
}

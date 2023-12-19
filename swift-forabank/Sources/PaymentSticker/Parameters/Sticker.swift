//
//  Sticker.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

import Foundation

extension Operation.Parameter {
    
    public struct Sticker: Hashable {
        
        let title: String
        let description: String
        let image: ImageData
        let options: [PriceOption]
        
        public init(
            title: String,
            description: String,
            image: ImageData,
            options: [PriceOption]
        ) {
            self.title = title
            self.description = description
            self.image = image
            self.options = options
        }
        
        public struct PriceOption: Hashable {
            
            let title: String
            let price: Double
            let description: String
            
            public init(
                title: String,
                price: Double,
                description: String
            ) {
                self.title = title
                self.price = price
                self.description = description
            }
        }
    }
}

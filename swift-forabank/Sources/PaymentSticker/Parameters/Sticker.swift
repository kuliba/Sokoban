//
//  Sticker.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    public struct Sticker: Hashable {
        
        let title: String
        let description: String
        let image: ImageData
        let options: [Option]
        
        public init(
            title: String,
            description: String,
            image: ImageData,
            options: [Operation.Parameter.Sticker.Option]
        ) {
            self.title = title
            self.description = description
            self.image = image
            self.options = options
        }
        
        public struct Option: Hashable {
            
            let title: String
            let description: String
            
            public init(
                title: String,
                description: String
            ) {
                self.title = title
                self.description = description
            }
        }
    }
}

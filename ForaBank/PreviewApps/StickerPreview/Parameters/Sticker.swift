//
//  Sticker.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    struct Sticker: Hashable {
        
        let title: String
        let description: String
        let options: [Option]
        
        struct Option: Hashable {
            
            let title: String
            let description: String
        }
    }
}

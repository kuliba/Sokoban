//
//  Amount.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

public extension Operation.Parameter {
    
    struct Amount: Hashable {
        
        let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
}

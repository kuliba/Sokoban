//
//  Hint.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    public struct Tip: Hashable {
        
        let title: String
        
        public init(
            title: String
        ) {
            self.title = title
        }
    }
}

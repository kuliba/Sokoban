//
//  Amount.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

public extension Operation.Parameter {
    
    struct Amount: Hashable {
        
        let state: State
        let value: String
        
        public init(
            state: State = .userInteraction,
            value: String
        ) {
            self.state = state
            self.value = value
        }
        
        public enum State {
            
            case loading
            case userInteraction
        }
    }
}

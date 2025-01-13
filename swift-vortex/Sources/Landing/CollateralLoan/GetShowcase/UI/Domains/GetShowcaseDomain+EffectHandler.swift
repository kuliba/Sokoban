//
//  GetShowcaseDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public final class EffectHandler {
        
        let load: Load
        
        public init(
            load: @escaping Load
        ) {
            self.load = load
        }

        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case .load:
                load { dispatch(.loaded($0)) }
            }
        }

        public typealias Dispatch = (Event) -> Void
        public typealias Load = (@escaping Completion) -> Void
        public typealias Completion = (Result) -> Void
    }
}

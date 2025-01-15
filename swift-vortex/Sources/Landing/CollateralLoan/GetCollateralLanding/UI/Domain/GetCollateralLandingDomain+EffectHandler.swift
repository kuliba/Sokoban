//
//  GetCollateralLandingDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 14.01.2025.
//

extension GetCollateralLandingDomain {
    
    public final class EffectHandler {
        
        private let landingId: LandingId
        private let load: Load
        
        public init(
            landingId: LandingId,
            load: @escaping Load
        ) {
            self.landingId = landingId
            self.load = load
        }

        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case .load:
                load(landingId) { dispatch(.loaded($0)) }
            }
        }

        public typealias LandingId = String
        public typealias Dispatch = (Event) -> Void
        public typealias Load = (LandingId, @escaping Completion) -> Void
        public typealias Completion = (Result) -> Void
    }
}

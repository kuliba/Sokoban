//
//  GetCollateralLandingDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 14.01.2025.
//

extension GetCollateralLandingDomain {
    
    public final class EffectHandler<InformerPayload> {
        
        private let landingID: LandingID
        private let load: Load
        
        public init(
            landingID: LandingID,
            load: @escaping Load
        ) {
            self.landingID = landingID
            self.load = load
        }

        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case .load:
                load(landingID) { dispatch(.loaded($0)) }
            }
        }

        public typealias LandingID = String
        public typealias Dispatch = (Event<InformerPayload>) -> Void
        public typealias Load = (LandingID, @escaping Completion) -> Void
        public typealias Completion = (Result<InformerPayload>) -> Void
    }
}

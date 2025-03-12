//
//  CardLandingContentDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 12.03.2025.
//

import OrderCardLandingComponent
import RxViewModel

enum CardLandingContentDomain<Landing> {}

extension CardLandingContentDomain {
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias State = LandingState<Landing>
    typealias Event = LandingEvent<Landing>
    typealias Effect = LandingEffect
    
    typealias Reducer = LandingReducer<Landing>
    typealias EffectHandler = LandingEffectHandler<Landing>
}

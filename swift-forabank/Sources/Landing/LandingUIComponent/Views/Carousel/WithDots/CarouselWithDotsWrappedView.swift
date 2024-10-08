//
//  CarouselWithDotsWrappedView.swift
//  
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias CarouselWithDotsViewModel = RxViewModel<CarouselWithDotsState, LandingEvent, CarouselEffect>

struct CarouselWithDotsWrappedView: View {
    
    @ObservedObject var model: Model
    let factory: Factory
    let config: Config
    
    public init(
        model: Model,
        factory: Factory,
        config: Config
    ) {
        self.model = model
        self.factory = factory
        self.config = config
    }

    public var body: some View {
        
        CarouselWithDotsView(
            state: model.state,
            event: model.event(_:),
            factory: factory,
            config: config)
    }
}

extension CarouselWithDotsWrappedView {
    
    typealias Model = CarouselWithDotsViewModel
    typealias Config = UILanding.Carousel.CarouselWithDots.Config
    typealias Factory = ViewFactory
}

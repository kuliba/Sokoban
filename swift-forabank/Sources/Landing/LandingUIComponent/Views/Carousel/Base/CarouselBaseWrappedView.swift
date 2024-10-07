//
//  CarouselBaseWrappedView.swift
//  
//
//  Created by Andryusina Nataly on 05.10.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias CarouselBaseViewModel = RxViewModel<CarouselBaseState, LandingEvent, CarouselEffect>

struct CarouselBaseWrappedView: View {
    
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
        
        CarouselBaseView(
            state: model.state,
            event: model.event(_:),
            factory: factory,
            config: config)
    }
}

extension CarouselBaseWrappedView {
    
    typealias Model = CarouselBaseViewModel
    typealias Config = UILanding.Carousel.CarouselBase.Config
    typealias Factory = ViewFactory
}

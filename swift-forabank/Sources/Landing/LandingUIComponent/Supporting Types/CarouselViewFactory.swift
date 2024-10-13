//
//  CarouselViewFactory.swift
//
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import SwiftUI

public struct CarouselViewFactory {

    let makeCarouselBaseView: MakeCarouselBaseView
    let makeCarouselWithDotsView: MakeCarouselWithDotsView
    let makeCarouselWithTabsView: MakeCarouselWithTabsView
    let refreshAction: () -> Void
    
    public init(
        makeCarouselBaseView: @escaping MakeCarouselBaseView,
        makeCarouselWithDotsView: @escaping MakeCarouselWithDotsView,
        makeCarouselWithTabsView: @escaping MakeCarouselWithTabsView,
        refreshAction: @escaping () -> Void
    ) {
        self.makeCarouselBaseView = makeCarouselBaseView
        self.makeCarouselWithDotsView = makeCarouselWithDotsView
        self.makeCarouselWithTabsView = makeCarouselWithTabsView
        self.refreshAction = refreshAction
    }
}

public extension CarouselViewFactory {
    
    typealias MakeCarouselBaseView = (UILanding.Carousel.CarouselBase) -> CarouselBaseView
    typealias MakeCarouselWithDotsView = (UILanding.Carousel.CarouselWithDots) -> CarouselWithDotsView
    typealias MakeCarouselWithTabsView = (UILanding.Carousel.CarouselWithTabs) -> CarouselWithTabsView
}

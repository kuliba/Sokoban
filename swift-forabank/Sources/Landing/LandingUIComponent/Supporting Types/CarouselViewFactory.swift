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
    
    public init(
        makeCarouselBaseView: @escaping MakeCarouselBaseView,
        makeCarouselWithDotsView: @escaping MakeCarouselWithDotsView,
        makeCarouselWithTabsView: @escaping MakeCarouselWithTabsView
    ) {
        self.makeCarouselBaseView = makeCarouselBaseView
        self.makeCarouselWithDotsView = makeCarouselWithDotsView
        self.makeCarouselWithTabsView = makeCarouselWithTabsView
    }

}

public extension CarouselViewFactory {
        
    typealias MakeCarouselBaseView = () -> EmptyView
    typealias MakeCarouselWithDotsView = () -> EmptyView
    typealias MakeCarouselWithTabsView = () -> EmptyView
}

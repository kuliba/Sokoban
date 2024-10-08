//
//  ViewFactory.swift
//
//
//  Created by Andryusina Nataly on 21.06.2024.
//

public struct ViewFactory {

    let makeImageViewFactory: ImageViewFactory
    let makeCarouselViewFactory: CarouselViewFactory

    public init(
        makeImageViewFactory: ImageViewFactory,
        makeCarouselViewFactory: CarouselViewFactory
    ) {
        self.makeImageViewFactory = makeImageViewFactory
        self.makeCarouselViewFactory = makeCarouselViewFactory
    }
}

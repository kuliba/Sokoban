//
//  ViewFactory.swift
//
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import UIPrimitives

public struct ViewFactory {

    let makeIconView: MakeIconView
    let makeBannerImageView: MakeBannerImageView
    
    public init(
        makeIconView: @escaping MakeIconView,
        makeBannerImageView: @escaping MakeBannerImageView
    ) {
        self.makeIconView = makeIconView
        self.makeBannerImageView = makeBannerImageView
    }
}

public extension ViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias MakeBannerImageView = (String) -> UIPrimitives.AsyncImage
}

//
// ImageViewFactory.swift
//
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import Foundation
import UIPrimitives

public struct ImageViewFactory {

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

public extension ImageViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias MakeBannerImageView = (String) -> UIPrimitives.AsyncImage
}

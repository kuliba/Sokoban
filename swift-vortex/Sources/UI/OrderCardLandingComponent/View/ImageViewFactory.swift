//
//  ImageViewFactory.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import UIPrimitives
import SwiftUI

public struct ImageViewFactory {
    
    let makeBannerImageView: MakeBannerImageView
    
    public init(
        makeBannerImageView: @escaping MakeBannerImageView
    ) {
        self.makeBannerImageView = makeBannerImageView
    }
}

public extension ImageViewFactory {
    
    typealias MakeBannerImageView = (String) -> UIPrimitives.AsyncImage
}

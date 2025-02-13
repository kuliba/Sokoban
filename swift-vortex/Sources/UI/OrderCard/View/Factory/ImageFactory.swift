//
//  ImageFactory.swift
//  
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation
import SwiftUI
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

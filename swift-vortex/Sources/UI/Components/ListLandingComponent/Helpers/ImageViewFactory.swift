//
//  ImageViewFactory.swift
//  
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation
import Combine
import SwiftUI
import UIPrimitives

public struct ImageViewFactory {

    public let makeIconView: MakeIconView
    public let makeBannerImageView: MakeBannerImageView
    
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

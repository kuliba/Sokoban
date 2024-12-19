//
//  ImageViewModel.swift
//  
//
//  Created by Andryusina Nataly on 12.09.2023.
//

import SwiftUI

public enum ImageViewModel {
        
    case placeholder(ImageRequest)
    case image(ImageRequest, Image)
}

public extension ImageViewModel {
    
    var request: ImageRequest {
        
        switch self {
            
        case let .placeholder(request), let .image(request, _):
            return request
        }
    }
    
    var image: Image? {
        
        if case let .image(_, image) = self {
            return image
        }
        
        return nil
    }
}

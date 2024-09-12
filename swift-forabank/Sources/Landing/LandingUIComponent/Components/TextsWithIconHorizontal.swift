//
//  TextsWithIconHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension UILanding {
    
    struct TextsWithIconHorizontal: Equatable {
        
        let md5hash: String
        let title: String
        let contentCenterAndPull: Bool
        
        public init(
            md5hash: String,
            title: String,
            contentCenterAndPull: Bool
        ) {
            self.md5hash = md5hash
            self.title = title
            self.contentCenterAndPull = contentCenterAndPull
        }
    }
}

extension TextsWithIconHorizontalView {
    
    final class ViewModel: ObservableObject {
        
        typealias TextsWithIconHorizontal = UILanding.TextsWithIconHorizontal
        
        @Published private(set) var data: TextsWithIconHorizontal
        
        @Published private(set) var images: [String: Image] = [:]
        
        init(
            data: TextsWithIconHorizontal,
            images: [String: Image]
        ) {
            self.data = data
            self.images = images
        }
        
        func image(byMd5Hash: String, imagesFromConfig: [String: Image]) -> Image? {
            
            if let image = imagesFromConfig[byMd5Hash] {
                return image
            }
            
            return images[byMd5Hash]
        }
    }
}

extension UILanding.TextsWithIconHorizontal {
    
    func imageRequests() -> [ImageRequest] {
        
        return [ImageRequest.md5Hash(self.md5hash)]
    }
}

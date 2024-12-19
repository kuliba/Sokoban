//
//  ImageSvgData.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Tagged
import Combine
import SwiftUI

public extension UILanding {
    
    struct ImageSvg: Equatable {
        
        let backgroundColor: BackgroundColor
        let md5hash: Md5hash
        
        public init(backgroundColor: BackgroundColor, md5hash: Md5hash) {
            self.backgroundColor = backgroundColor
            self.md5hash = md5hash
        }
        
        public typealias BackgroundColor = Tagged<_BackgroundColor, String>
        public typealias Md5hash = Tagged<_Md5hash, String>

        public enum _Md5hash {}
        public enum _BackgroundColor {}
    }
}

extension UILanding.ImageSvg {
    
    final class ViewModel: ObservableObject {
        
        typealias ImageSvg = UILanding.ImageSvg
        @Published private(set) var data: ImageSvg
        
        @Published private(set) var images: [String: Image] = [:]
        
        init(
            data: ImageSvg,
            images: [String: Image]
        ) {
            self.data = data
            self.images = images
        }
        
        func image(byMd5Hash: String) -> Image? {
            
            return images[byMd5Hash]
        }
    }
}


extension UILanding.ImageSvg {
    
    func imageRequests() -> [ImageRequest] {
        
        return [ImageRequest.md5Hash(self.md5hash.rawValue)]
    }
}

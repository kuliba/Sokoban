//
//  IconWithTwoTextLines.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension UILanding {
    
    struct IconWithTwoTextLines: Equatable {
        
        public let md5hash: String
        public let title, subTitle: String?
        
        public init(
            md5hash: String,
            title: String?,
            subTitle: String?
        ) {
            
            self.md5hash = md5hash
            self.title = title
            self.subTitle = subTitle
        }
    }
}

extension IconWithTwoTextLinesView {
    
    final class ViewModel: ObservableObject {
        
        typealias IconWithTwoTextLines = UILanding.IconWithTwoTextLines
        
        @Published private(set) var data: IconWithTwoTextLines
        
        @Published private(set) var images: [String: Image] = [:]
        
        init(
            data: IconWithTwoTextLines,
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

extension UILanding.IconWithTwoTextLines {
    
    func imageRequests() -> [ImageRequest] {
        
        return [ImageRequest.md5Hash(self.md5hash)]
    }
}

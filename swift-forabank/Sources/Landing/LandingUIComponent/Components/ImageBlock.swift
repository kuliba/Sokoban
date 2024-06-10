//
//  ImageBlock.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Foundation
import Tagged
import Combine
import CombineSchedulers
import SwiftUI

public extension UILanding {
    
    struct ImageBlock: Equatable {
        
        public let id: UUID
        public let placeholder: Placeholder
        public let backgroundColor: BackgroundColor
        public let link: Link
        
        public init(id: UUID = UUID(), placeholder: Placeholder, backgroundColor: BackgroundColor, link: Link) {
            self.id = id
            self.placeholder = placeholder
            self.backgroundColor = backgroundColor
            self.link = link
        }
        
        public typealias Placeholder = Tagged<_Placeholder, Bool>
        public typealias BackgroundColor = Tagged<_BackgroundColor, String>
        public typealias Link = Tagged<_Link, String>
        
        public enum _Placeholder {}
        public enum _BackgroundColor {}
        public enum _Link {}
    }
}

extension UILanding.ImageBlock {
    
    final class ViewModel: ObservableObject {
        
        typealias ImageBlock = UILanding.ImageBlock
        @Published private(set) var data: ImageBlock
        
        @Published private(set) var images: [String: Image] = [:]
        
        init(
            data: ImageBlock,
            images: [String: Image]
        ) {
            self.data = data
            self.images = images
        }
        
        func image(byLink: String) -> Image? {
            
            return images[byLink]
        }
    }
}

extension UILanding.ImageBlock {
    
    func imageRequests() -> [ImageRequest] {
        
        return [ImageRequest.url(self.link.rawValue)]
    }
}

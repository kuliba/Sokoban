//
//  ImageSvgCodable.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension CodableLanding {
    
    struct ImageSvg: Equatable, Codable {
        
        public let backgroundColor: BackgroundColor
        public let md5hash: Md5hash
        
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

//
//  ResponseMapper+GetAuthorizedZoneClientInformData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 27.09.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetAuthorizedZoneClientInformDataResponse = SerialStamped<String, GetAuthorizedZoneClientInformData>
}

extension ResponseMapper {
    
    public struct GetAuthorizedZoneClientInformData: Equatable {
        
        public let category: String
        public let title: String
        public let svgImage: String
        public let text: String
        
        public init(
            category: String,
            title: String,
            svgImage: String,
            text: String
        ) {
            self.category = category
            self.title = title
            self.svgImage = svgImage
            self.text = text
        }
        
        enum CodingKeys: String, CodingKey {
            case category, title, text
            case svgImage = "svg_image"
        }
    }
}

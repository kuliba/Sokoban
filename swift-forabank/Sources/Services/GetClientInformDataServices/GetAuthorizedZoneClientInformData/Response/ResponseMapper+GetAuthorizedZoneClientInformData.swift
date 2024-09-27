//
//  ResponseMapper+GetAuthorizedZoneClientInformData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 27.09.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetAuthorizedZoneClientInformDataResponse = SerialStamped<String, Authorized>
}

extension ResponseMapper {
    
    public struct Authorized: Equatable {
        
        let category: String
        let title: String
        let svg_image: String
        let text: String
        
        public init(
            category: String,
            title: String,
            svg_image: String,
            text: String
        ) {
            self.category = category
            self.title = title
            self.svg_image = svg_image
            self.text = text
        }
    }
}

//
//  OptionWithMapImage.swift
//  
//
//  Created by Andryusina Nataly on 08.06.2023.
//

import Foundation
import SwiftUI

public struct OptionWithMapImage: Identifiable, Equatable {
    
    public let id: Int
    public let value: String
    public let mapImage: MapImage
    public let title: String
    
    public init(id: Int, value: String, mapImage: MapImage, title: String) {
        
        self.id = id
        self.value = value
        self.mapImage = mapImage
        self.title = title
    }
}

public enum MapImage: Equatable {
    
    case placeholder
    case image(Image)
}


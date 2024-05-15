//
//  Info.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import SwiftUI

public struct Info {
    
    public typealias ImagePublisher = CurrentValueSubject<Image, Never>
    
    let id: ID
    let value: String
    let title: String
    let image: ImagePublisher
    let style: Style
    
    public init(
        id: ID,
        value: String,
        title: String,
        image: ImagePublisher,
        style: Style
    ) {
        self.id = id
        self.value = value
        self.title = title
        self.image = image
        self.style = style
    }
}

public extension Info {
    
    enum ID: Equatable {
        
        case amount, brandName, recipientBank
    }

    enum Style {
        
        case expanded
        case compressed
    }
}

//
//  Info.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import SwiftUI

public struct Info {
    
    public typealias ID = GetSberQRDataIDs.InfoID
    public typealias ImagePublisher = AnyPublisher<Image, Never>
    
    let id: ID
    let value: String
    let title: String
    let image: ImagePublisher
    
    public init(
        id: ID,
        value: String,
        title: String,
        image: ImagePublisher
    ) {
        self.id = id
        self.value = value
        self.title = title
        self.image = image
    }
}

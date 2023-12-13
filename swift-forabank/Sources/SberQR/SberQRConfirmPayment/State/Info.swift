//
//  Info.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

public struct Info {
    
    public typealias ID = GetSberQRDataResponse.Parameter.Info.ID
    
    let id: ID
    let value: String
    let title: String
    let image: (@escaping (Image) -> Void) -> Void
    
    public init(
        id: ID,
        value: String,
        title: String,
        image: @escaping (@escaping (Image) -> Void) -> Void
    ) {
        self.id = id
        self.value = value
        self.title = title
        self.image = image
    }
}

//
//  Operator.swift
//  
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct Operator: Equatable, Identifiable {
    
    public var id: String
    public let title: String
    let subtitle: String?
    let image: Image?
    
    public init(
        id: String,
        title: String,
        subtitle: String?,
        image: Image?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    public init(
        _operatorGroup: _OperatorGroup
    ) {
        
        self.id = _operatorGroup.id
        self.title = _operatorGroup.title
        self.subtitle = _operatorGroup.description
        self.image = nil
    }
}

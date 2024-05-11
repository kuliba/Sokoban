//
//  Operator.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct Operator<Icon>: Identifiable {
    
    public var id: String
    public let title: String
    public let subtitle: String?
    public let icon: Icon
    
    public init(
        id: String,
        title: String,
        subtitle: String?,
        icon: Icon
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

extension Operator: Equatable where Icon: Equatable {}

public extension Operator where Icon == String {
    
    init(_ operatorGroup: _OperatorGroup) {
        
        self.id = operatorGroup.id
        self.title = operatorGroup.title
        self.subtitle = operatorGroup.description
        self.icon = operatorGroup.md5hash
    }
}

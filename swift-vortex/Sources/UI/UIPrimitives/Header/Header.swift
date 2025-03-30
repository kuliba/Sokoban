//
//  Header.swift
//  
//
//  Created by Igor Malyarov on 30.03.2025.
//

/// A model representing a header with a title and an optional subtitle.
public struct Header: Equatable {
    
    public let title: String
    public let subtitle: String?
    
    /// Initializes a `Header` with the given title and optional subtitle.
    public init(
        title: String,
        subtitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}

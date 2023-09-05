//
//  Landing.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public struct Landing: Equatable {
    
    public let header: [LandingComponent]
    public let main: [LandingComponent]
    public let footer: [LandingComponent]
    
    // TODO: add details
    
    public init(
        header: [LandingComponent],
        main: [LandingComponent],
        footer: [LandingComponent]
    ) {
        self.header = header
        self.main = main
        self.footer = footer
    }
}

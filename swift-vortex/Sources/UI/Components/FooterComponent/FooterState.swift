//
//  FooterState.swift
//
//
//  Created by Дмитрий Савушкин on 05.03.2024.
//

import SwiftUI

public enum FooterState {
    
    case footer(Footer)
    case failure(Failure)
    
    public struct Footer {
        
        let title: String
        let description: String
        let subtitle: String
        
        public init(
            title: String,
            description: String,
            subtitle: String
        ) {
            self.title = title
            self.description = description
            self.subtitle = subtitle
        }
    }

    public struct Failure {
        
        let image: Image
        let description: String
        
        public init(
            image: Image,
            description: String
        ) {
            self.image = image
            self.description = description
        }
    }
}

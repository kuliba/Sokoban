//
//  LatestPayment.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct LatestPayment: Equatable, Identifiable {
    
    public var id: String { title }
    let image: Image?
    let title: String
    let amount: String
    
    public init(
        image: Image?,
        title: String,
        amount: String
    ) {
        self.image = image
        self.title = title
        self.amount = amount
    }
    
    public struct LatestPaymentConfig {
        
        let defaultImage: Image
        let backgroundColor: Color
        
        public init(
            defaultImage: Image,
            backgroundColor: Color
        ) {
            self.defaultImage = defaultImage
            self.backgroundColor = backgroundColor
        }
    }
}

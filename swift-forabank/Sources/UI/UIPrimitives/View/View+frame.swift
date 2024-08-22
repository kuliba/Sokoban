//
//  View+frame.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

public extension View {
    
    func frame(_ size: CGSize) -> some View {
        
        self.frame(width: size.width, height: size.height)
    }
}

//
//  View+frame.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

public extension View {
    
    @inlinable
    func frame(_ size: CGSize) -> some View {
        
        self.frame(width: size.width, height: size.height)
    }
    
    @inlinable
    func height(_ height: CGFloat) -> some View {
        
        frame(height: height)
    }
    
    @inlinable
    func width(_ width: CGFloat) -> some View {
        
        frame(width: width)
    }
}

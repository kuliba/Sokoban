//
//  View+frame.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI

extension View {
    
    func frame(_ size: CGSize) -> some View {
        
        frame(width: size.width, height: size.height)
    }
}

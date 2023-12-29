//
//  View+size.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

extension View {
    
    func frame(_ size: CGSize) -> some View {
        
        frame(width: size.width, height: size.height)
    }
}

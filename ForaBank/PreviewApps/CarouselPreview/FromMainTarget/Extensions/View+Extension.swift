//
//  View+Extension.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import SwiftUI

extension View {
    
    /// SwiftUI `frame` overload.
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        
        self.frame(width: size.width, height: size.height)
    }
}

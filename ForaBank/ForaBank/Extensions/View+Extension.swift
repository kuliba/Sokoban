//
//  View+Extension.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import SwiftUI

extension View {

    @ViewBuilder
    func ignoreKeyboard() -> some View {

        ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        
        switch isHidden {
        case true: self.hidden()
        case false: self
        }
    }
}

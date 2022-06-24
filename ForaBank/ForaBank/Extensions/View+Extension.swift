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
        if #available(iOS 14.0, *) {
            ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            self
        }
    }
}

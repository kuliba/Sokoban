//
//  TitleConfig+render.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

public extension TitleConfig {
 
    func render(
        alignment: TextAlignment = .leading
    ) -> some View {
        
        text.text(withConfig: config, alignment: alignment)
    }
}

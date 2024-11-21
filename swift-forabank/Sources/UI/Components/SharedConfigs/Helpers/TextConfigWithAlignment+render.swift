//
//  TextConfigWithAlignment+render.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

public extension TextConfigWithAlignment {
 
    func render() -> some View {
        
        text.text(withConfig: config, alignment: alignment)
    }
}

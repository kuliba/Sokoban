//
//  Images+preview.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

extension Config.Images {
    
    static let preview: Self = .init(
        valueMasked: Image(systemName: "eye"),
        valueShown : Image(systemName: "eye.slash"),
        checkOn: Image(systemName: "checkmark.square"),
        checkOff: Image(systemName: "rectangle"),
        info: Image(systemName: "info.circle")
    )
}

//
//  Images+preview.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

extension Config.Images {
    
    static let preview: Self = .init(
        numberMasked: Image(systemName: "eye"),
        cvvMasked : Image(systemName: "eye"),
        number: Image(systemName: "eye.slash"),
        cvv : Image(systemName: "eye.slash"),
        checkOn: Image(systemName: "checkmark.square"),
        checkOff: Image(systemName: "rectangle")
    )
}

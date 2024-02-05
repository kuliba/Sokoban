//
//  Images+preview.swift
//  
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import SwiftUI

extension CardGuardian.Config.Images {
    
    static let preview: Self = .init(
        toggleLock: Image(systemName: "lock"),
        changePin: Image(systemName: "asterisk"),
        showOnMain: Image(systemName: "eye")
    )
}

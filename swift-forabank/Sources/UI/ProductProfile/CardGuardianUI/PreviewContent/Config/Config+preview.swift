//
//  Config+preview.swift
//  
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import SwiftUI

extension CardGuardian.Config {
    
    public static let preview: Self = .init(
        images: .preview,
        paddings: .preview,
        sizes: .preview,
        colors: .preview,
        fonts: .preview
    )
    
    public static let previewBlockHide: Self = .init(
        images: .previewBlockHide,
        paddings: .preview,
        sizes: .preview,
        colors: .preview,
        fonts: .preview
    )
}

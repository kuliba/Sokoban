//
//  SheetConfig+preview.swift
//
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import SwiftUI

extension SheetConfig {
    
    public static let preview: Self = .init(
        image: Image(systemName: "doc.text"),
        paddings: .preview,
        imageSizes: .image,
        buttonSizes: .button,
        colors: .preview,
        fonts: .preview
    )
}

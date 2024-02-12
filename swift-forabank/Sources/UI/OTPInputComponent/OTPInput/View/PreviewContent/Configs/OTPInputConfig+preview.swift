//
//  OTPInputConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import UIPrimitives

public extension OTPInputConfig {
    
    static let preview: Self = .init(
        button: .preview,
        digitModel: .preview,
        resend: .preview,
        subtitle: .init(
            textFont: .footnote,
            textColor: .green
        ),
        timer: .init(
            textFont: .headline,
            textColor: .orange
        ),
        title: .init(
            textFont: .title3.bold(),
            textColor: .pink
        )
    )
}

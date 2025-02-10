//
//  StatefulButtonConfig+preview.swift
//
//
//  Created by Igor Malyarov on 10.02.2025.
//

extension StatefulButtonConfig {
    
    static let preview: Self = .init(
        active: .active,
        inactive: .inactive
    )
}

extension _ButtonStateConfig {
    
    static let active: Self = .init(
        backgroundColor: .green,
        title: .init(
            text: "Active",
            config: .init(
                textFont: .title3,
                textColor: .yellow
            )
        )
    )
    
    static let inactive: Self = .init(
        backgroundColor: .orange,
        title: .init(
            text: "Inactive",
            config: .init(
                textFont: .title2,
                textColor: .black
            )
        )
    )
}

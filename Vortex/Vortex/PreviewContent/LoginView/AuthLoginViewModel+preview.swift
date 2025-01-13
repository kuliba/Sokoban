//
//  AuthLoginViewModel+preview.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.09.2023.
//


extension AuthLoginViewModel {
    
    static let preview: AuthLoginViewModel = .init(
        .emptyMock,
        buttons: [
            .init(.abroad, action: {}),
            .init(.card, action: {})
        ],
        shouldUpdateVersion: { _ in return false },
        rootActions: .emptyMock,
        onRegister: {}
    )
}

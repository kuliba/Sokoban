//
//  AuthLoginViewModel+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.09.2023.
//


extension AuthLoginViewModel {
    
    static let preview: AuthLoginViewModel = .init(
        header: .init(),
        buttons: [
            .init(.abroad, action: {}),
            .init(.card, action: {})
        ],
        rootActions: .emptyMock,
        model: .emptyMock
    )
}

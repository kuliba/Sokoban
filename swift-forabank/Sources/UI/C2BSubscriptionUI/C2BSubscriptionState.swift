//
//  C2BSubscriptionState.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldDomain
import UIPrimitives

public struct C2BSubscriptionState {

    public typealias TapAlert = AlertModelOf<C2BSubscriptionEvent.AlertEvent>

    public let getC2BSubResponse: GetC2BSubResponse
    public var textFieldState: TextFieldState
    public var tapAlert: TapAlert?
    
    public init(
        getC2BSubResponse: GetC2BSubResponse,
        textFieldState: TextFieldState = .placeholder("Поиск"),
        tapAlert: TapAlert? = nil
    ) {
        self.getC2BSubResponse = getC2BSubResponse
        self.textFieldState = textFieldState
        self.tapAlert = tapAlert
    }
}

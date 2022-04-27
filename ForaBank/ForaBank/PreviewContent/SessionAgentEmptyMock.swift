//
//  SessionAgentEmptyMock.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2022.
//

import Foundation
import Combine

class SessionAgentEmptyMock: SessionAgentProtocol {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let sessionState: CurrentValueSubject<SessionState, Never> = .init(.inactive)

}

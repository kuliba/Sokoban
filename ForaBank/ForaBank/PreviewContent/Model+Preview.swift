//
//  Model+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation

extension Model {
    
    static let emptyMock = Model(serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock(), keychainAgent: KeychainAgentMock())
}

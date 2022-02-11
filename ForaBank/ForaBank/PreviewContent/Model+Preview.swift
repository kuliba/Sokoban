//
//  Model+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation

extension Model {
    
    static let emptyMock = Model(serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock())
}

extension ImageData {
    
    static let serviceSample = ImageData(data: Data())
    static let parameterSample = ImageData(data: Data())
}

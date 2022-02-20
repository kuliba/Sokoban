//
//  Model+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation
import UIKit

extension Model {
    
    static let emptyMock = Model(serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock())
}

extension ImageData {
    
    static let serviceSample = ImageData(with: UIImage(named: "Payments Service Sample")!)!
    static let parameterSample = ImageData(with: UIImage(named: "Payments List Sample")!)!
}

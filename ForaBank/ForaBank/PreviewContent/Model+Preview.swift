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
    static let parameterDocument = ImageData(with: UIImage(named: "Payments Icon Document")!)!
    static let parameterHash = ImageData(with: UIImage(named: "Payments Icon Hash")!)!
    static let parameterLocation = ImageData(with: UIImage(named: "Payments Icon Location")!)!
    static let parameterSMS = ImageData(with: UIImage(named: "Payments Icon SMS")!)!
}

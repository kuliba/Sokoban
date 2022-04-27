//
//  Model+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation
import UIKit

extension Model {
    
    static let emptyMock = Model(sessionAgent: SessionAgentEmptyMock(), serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock(), keychainAgent: KeychainAgentMock(), settingsAgent: SettingsAgentMock(), biometricAgent: BiometricAgentMock())
    
    static let productsMock: Model = {
        
        let model = Model(sessionAgent: SessionAgentEmptyMock(), serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock(), keychainAgent: KeychainAgentMock(), settingsAgent: SettingsAgentMock(), biometricAgent: BiometricAgentMock())
        
        let bundle = Bundle(for: Model.self)
        let url = bundle.url(forResource: "ProductsListSample", withExtension: "json")!
        let json = try! Data(contentsOf: url)
        let decoder = JSONDecoder.serverDate
        let productsData = try! decoder.decode([ProductData].self, from: json)
        
        model.products.value = model.reduce(products: model.products.value, with: productsData)
        
        return model
    }()
}

extension ImageData {
    
    static let serviceSample = ImageData(with: UIImage(named: "Payments Service Sample")!)!
    static let serviceFMS = ImageData(with: UIImage(named: "Payments Service FMS")!)!
    static let serviceFNS = ImageData(with: UIImage(named: "Payments Service FNS")!)!
    static let serviceFSSP = ImageData(with: UIImage(named: "Payments Service FSSP")!)!
    static let parameterSample = ImageData(with: UIImage(named: "Payments List Sample")!)!
    static let parameterDocument = ImageData(with: UIImage(named: "Payments Icon Document")!)!
    static let parameterHash = ImageData(with: UIImage(named: "Payments Icon Hash")!)!
    static let parameterLocation = ImageData(with: UIImage(named: "Payments Icon Location")!)!
    static let parameterSMS = ImageData(with: UIImage(named: "Payments Icon SMS")!)!
}

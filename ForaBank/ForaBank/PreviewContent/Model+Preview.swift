//
//  Model+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation

extension Model {
    
    static let emptyMock = Model(serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock(), keychainAgent: KeychainAgentMock(), settingsAgent: SettingsAgentMock(), biometricAgent: BiometricAgentMock())
    
    static let productsMock: Model = {
        
        let model = Model(serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock())
        
        let bundle = Bundle(for: Model.self)
        let url = bundle.url(forResource: "ProductsListSample", withExtension: "json")!
        let json = try! Data(contentsOf: url)
        let decoder = JSONDecoder.serverDate
        let productsData = try! decoder.decode([ProductData].self, from: json)
        
        model.products.value = model.reduce(products: model.products.value, with: productsData)
        
        return model
    }()
}

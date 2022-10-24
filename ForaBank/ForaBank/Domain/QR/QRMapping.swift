//
//  QRMapping.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRMapping: Codable {
    
//    let operators: [QROperator]
    
    let allParameters: [QRParameter]
    
    enum CodingKeys: String, CodingKey {
        
        case allParameters = "general"
//        case operators
    }
}

struct QROperator: Codable {
    
    let `operator`: String
    let parameters: [QRParameter]
}

extension QRMapping {
    
    public static var operators: QRMapping = {
        let decoder = JSONDecoder.serverDate
        let url = Bundle(identifier: "ru.forabank.sense")!.url(forResource: "QRMapping", withExtension: "json")!
        let json = try! Data(contentsOf: url)
        let result = try! decoder.decode(QRMapping.self, from: json)
        return result
    }()
}

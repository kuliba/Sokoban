//
//  OperatorGroupData+test.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

@testable import ForaBank

extension OperatorGroupData {
    
    static func test(
        city: String? = nil,
        code: String,
        isGroup: Bool = false,
        logotypeList: [LogotypeData] = [],
        name: String,
        operators: [OperatorData] = [],
        region: String? = nil,
        synonymList: [String] = []
    ) -> Self {
        
        .init(
            city: city,
            code: code,
            isGroup: isGroup,
            logotypeList: logotypeList,
            name: name,
            operators: operators,
            region: region,
            synonymList: synonymList
        )
    }
}

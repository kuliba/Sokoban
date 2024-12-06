//
//  OperatorData+test.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

@testable import ForaBank

extension OperatorGroupData.OperatorData {
    
    static func test(
        city: String? = nil,
        code: String,
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String,
        parameterList: [ParameterData] = [],
        parentCode: String,
        region: String? = nil,
        synonymList: [String] = []
    ) -> Self {
        
        .init(
            city: city,
            code: code,
            isGroup: isGroup,
            logotypeList: logotypeList,
            name: name,
            parameterList: parameterList,
            parentCode: parentCode,
            region: region,
            synonymList: synonymList
        )
    }
}

//
//  makeServerErrorData.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

func makeServerErrorData(
    statusCode: Int = 7506,
    errorMessage: String = "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
) -> Data {
    
    try! JSONSerialization.data(withJSONObject: [
        "statusCode": statusCode,
        "errorMessage": errorMessage
    ] as [String: Any])
}

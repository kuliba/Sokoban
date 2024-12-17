//
//  ResponseMapper+mapGetAllLatestPaymentsResponse.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.06.2024.
//

import XCTest

@testable import ForaBank
import XCTest

final class ResponseMapper_mapGetAllLatestPaymentsResponseTests: XCTestCase {
    
    func test_map_shouldDeliverEmptyOnNon200() throws {
        
        let non200Codes = [199, 201, 399, 400, 401, 404, 500]
        
        for code in non200Codes {
            
            let result = map(
                anyData(),
                anyHTTPURLResponse(with: code)
            )
            
            XCTAssertTrue(result.isEmpty)
        }
    }
    
    func test_map_shouldDeliverValueOnResponse200() throws {
        
        let data = Data(String.validData.utf8)
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(data, response200)
        
        XCTAssertEqual(result.count, 1)
        let first = try XCTUnwrap(result.first)
        
        XCTAssertNoDiff(first, .init(
            title: "ПАО Калужская сбытовая компания",
            amount: 999,
            md5Hash: "aeacabf71618e6f66aac16ed3b1922f3",
            puref: "iFora||KSK"
        ))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> [ResponseMapper.LatestServicePayment] {
        
        ResponseMapper.mapGetAllLatestPaymentsResponse(data, httpURLResponse)
    }

    private struct Response: Encodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: Data?
    }
}

private extension String {
    
    static let validData = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": [
        {
            "paymentDate": "04.09.2023 16:51:53",
            "date": 1693835513315,
            "type": "service",
            "amount": 999.00,
            "puref": "iFora||KSK",
            "lpName": null,
            "md5hash": "aeacabf71618e6f66aac16ed3b1922f3",
            "name": "ПАО Калужская сбытовая компания",
            "additionalList": [
                {
                    "fieldName": "account",
                    "fieldValue": "110110581",
                    "fieldTitle": null,
                    "svgImage": null,
                    "recycle": null,
                    "typeIdParameterList": null
                }
            ]
        }
    ]
}
"""
}

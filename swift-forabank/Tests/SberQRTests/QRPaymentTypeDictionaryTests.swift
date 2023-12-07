//
//  QRPaymentTypeDictionaryTests.swift
//  
//
//  Created by Igor Malyarov on 15.11.2023.
//

import XCTest

struct QRPaymentTypeDictionary {
    
    let serial: String
    private let dict: Dictionary<String, String>
    
    init(
        serial: String,
        dict: Dictionary<String, String>
    ) {
        self.serial = serial
        self.dict = dict
    }
}
 
extension QRPaymentTypeDictionary {
    
    func isSberQR(_ key: String) -> Bool {
        
        dict[key, default: ""] == "SBERQR"
    }
    
    func isSberQR(_ url: URL) -> Bool {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let key = components.host
        else { return false }
        
        return isSberQR(key)
    }
}

enum ResponseMapper {}

extension ResponseMapper {
    
    static func mapQRPaymentTypeJSON(data: Data) throws -> QRPaymentTypeDictionary {
        
        #warning("happy path only")
        let response = try JSONDecoder().decode(Response.self, from: data)
        
        return response.qrPaymentTypeDictionary
    }
    
    private struct Response: Decodable {
        
        let statusCode: Int
        let data: _Data
        
        struct _Data: Decodable {
            
            let serial: String
            let list: [Pair]
            
            struct Pair: Decodable {
                
                let content: String
                let paymentType: String
            }
        }
        
        var qrPaymentTypeDictionary: QRPaymentTypeDictionary {
            
            let pairs = data.list.map { ($0.content, $0.paymentType) }
            let dict = Dictionary(uniqueKeysWithValues: pairs)
            
            return .init(
                serial: data.serial,
                dict: dict
            )
        }
    }
}

final class QRPaymentTypeDictionaryTests: XCTestCase {
    
    func test_isSberQR() throws {
        
        let dict = try mapQRPaymentTypeJSON()
        
        XCTAssertFalse(dict.isSberQR("__.ru"))
        
        XCTAssert(dict.isSberQR("platimultiqr.ru"))
        XCTAssert(dict.isSberQR("multiqrpay.ru"))
        XCTAssert(dict.isSberQR("platiqr.ru"))
        XCTAssert(dict.isSberQR("ift.multiqr.ru"))
        XCTAssert(dict.isSberQR("sberbank.ru/qr"))
        XCTAssert(dict.isSberQR("pay.multiqr.ru"))
        XCTAssert(dict.isSberQR("multiqr.ru"))
    }
    
    func test_isSberQR_shouldReturnFalseForNonSberURL() throws {
        
        let dict = try mapQRPaymentTypeJSON()
        let anyURL = anyURL()
        
        XCTAssertFalse(dict.isSberQR(anyURL))
    }
    
    func test_isSberQR_shouldReturnTrueForSberURL() throws {
        
        let dict = try mapQRPaymentTypeJSON()
        let sberQRURL = try XCTUnwrap(URL(string: platiqr_ru()))

        XCTAssert(dict.isSberQR(sberQRURL))
    }
    
    // MARK: - Helpers
    
    private func mapQRPaymentTypeJSON() throws -> QRPaymentTypeDictionary {
        
        try ResponseMapper.mapQRPaymentTypeJSON(data: qrPaymentTypeJSON())
    }
    
    private func qrPaymentTypeJSON() throws -> Data {
        
        try Data(contentsOf: XCTUnwrap(qrPaymentTypeURL))
    }
    
    private func platiqr_ru() -> String {
        
        "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822"
    }
}

private func anyURL(
    _ string: String = UUID().uuidString
) -> URL {
    
    .init(string: string)!
}

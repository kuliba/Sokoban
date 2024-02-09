//
//  HTTPClientStub+fastPaymentsSettings.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.02.2024.
//

import FastPaymentsSettings
import Foundation

extension HTTPClientStub {
    
    static let fastPaymentsSettings: HTTPClientStub = .init([
        .fastPaymentContractFindList: .fastPaymentContractFindList(.a1),
        .getClientConsentMe2MePull: .getClientConsentMe2MePull(.b2),
        .getBankDefault: .getBankDefault(.c1),
    ])
    
    private convenience init(
        _ stub: [URLPath: Filename]
    ) {
        self.init(stub: stub.mapValues {
            
            $0.data.response(statusCode: 200)
        })
    }
    
    private convenience init(
        _ stub: [URLPath: (statusCode: Int, data: Data)]
    ) {
        self.init(stub: stub.mapValues {
            
            $0.data.response(statusCode: $0.statusCode)
        })
    }
}

private extension URLPath {
    
    static let fastPaymentContractFindList: Self = "/rest/fastPaymentContractFindList"
    static let getClientConsentMe2MePull: Self = "/rest/getClientConsentMe2MePull"
    static let getBankDefault: Self = "/rest/getBankDefault"
}

private protocol Filenamed {
    
    var filename: String { get }
}

private enum Filename {
    
    case fastPaymentContractFindList(FastPaymentContractFindList)
    case getClientConsentMe2MePull(GetClientConsentMe2MePull)
    case getBankDefault(GetBankDefault)
    
    enum FastPaymentContractFindList: String, Filenamed {
        
        case a1, a2, a3, a4, a5
        
        var filename: String { "fastPaymentContractFindList\(rawValue.uppercased())" }
    }
    
    enum GetClientConsentMe2MePull: String, Filenamed {
        
        case b1, b2, b3, b4
        
        var filename: String { "getClientConsentMe2MePull\(rawValue.uppercased())" }
    }
    
    enum GetBankDefault: String, Filenamed {
        
        case c1, c2, c3, c4, c5
        
        var filename: String { "getBankDefault\(rawValue.uppercased())" }
    }
    
    var filename: String {
        
        switch self {
        case let .fastPaymentContractFindList(fastPaymentContractFindList):
            return fastPaymentContractFindList.filename
        
        case let .getClientConsentMe2MePull(getClientConsentMe2MePull):
            return getClientConsentMe2MePull.filename
        
        case let .getBankDefault(getBankDefault):
            return getBankDefault.filename
        }
    }
    
    var data: Data { .json(self.filename)  }
}

private extension Data {
    
    static let error: HTTPClient.Response = Data.empty.response(statusCode: 201)
    
    static let emptyServerResponse: HTTPClient.Response = Data.json(string: .emptyServerResponse).response()
    
    static let errorServerResponse: HTTPClient.Response = Data.json(string: .errorServerResponse).response()
    
    private static func json(string: String) -> Self {
        
        .init(string.utf8)
    }
    
    static func json(
        _ filename: String,
        ext: String = "json"
    ) -> Data {
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext)
        else {
            fatalError("Failed to find file \"\(filename).\(ext)\" in the bundle.")
        }
        
        guard let data = try? Data(contentsOf: url)
        else {
            fatalError("Failed to get data from file \"\(filename).\(ext)\" in the bundle.")
        }

        return data
    }
    
    func response(
        url: URL = .init(string: "some-url")!,
        statusCode: Int = 200
    ) -> HTTPClient.Response {
        
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        return (self, response)
    }
}

private extension String {
    
    static let emptyServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": []
}
"""
    
    static let errorServerResponse = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка (код 4044). Свяжитесь с поддержкой банка для уточнения",
    "data": null
}
"""
    
    static let fastPaymentContractFindList_a1 = "fastPaymentContractFindListA1"
    static let fastPaymentContractFindList_a2 = "fastPaymentContractFindListA2"
    static let fastPaymentContractFindList_a3 = "fastPaymentContractFindListA3"
    static let fastPaymentContractFindList_a4 = "fastPaymentContractFindListA4"
    static let fastPaymentContractFindList_a5 = "fastPaymentContractFindListA5"
    
    static let getClientConsentMe2MePull_b1 = "getClientConsentMe2MePullB1"
    static let getClientConsentMe2MePull_b2 = "getClientConsentMe2MePullB2"
    static let getClientConsentMe2MePull_b3 = "getClientConsentMe2MePullB3"
    static let getClientConsentMe2MePull_b4 = "getClientConsentMe2MePullB4"

    static let getBankDefault_c1 = "getBankDefaultC1"
    static let getBankDefault_c2 = "getBankDefaultC2"
    static let getBankDefault_c3 = "getBankDefaultC3"
    static let getBankDefault_c4 = "getBankDefaultC4"
    static let getBankDefault_c5 = "getBankDefaultC5"
}

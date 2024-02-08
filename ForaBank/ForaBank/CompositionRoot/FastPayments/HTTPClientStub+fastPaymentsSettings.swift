//
//  HTTPClientStub+fastPaymentsSettings.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.02.2024.
//

import FastPaymentsSettings
import Foundation

extension FPSEndpointStub {
    
    /// Change this stub with feature flag set to `.active(.stub)` to test.
    static let `default`: Self = .init(
        fastPaymentContractFindList: .a1,
        getClientConsentMe2MePull: .b1,
        getBankDefault: .c1,
        updateFastPaymentContract: .d1
    )
}

extension HTTPClientStub {
    
    static func fastPaymentsSettings(
        _ stub: FPSEndpointStub = .default,
        delay: TimeInterval = 1
    ) -> HTTPClientStub {
        
        let stub = stub.httpClientStub.mapValues { $0.response(statusCode: 200) }
        
        return .init(stub: stub, delay: delay)
    }
    
    private convenience init(
        _ stub: [URLPath: (statusCode: Int, data: Data)],
        delay: TimeInterval = 1
    ) {
        self.init(
            stub: stub.mapValues { $0.data.response(statusCode: $0.statusCode) },
            delay: delay
        )
    }
}

struct FPSEndpointStub {
    
    let fastPaymentContractFindList: FPSEndpoint.FastPaymentContractFindList
    let getClientConsentMe2MePull: FPSEndpoint.GetClientConsentMe2MePull
    let getBankDefault: FPSEndpoint.GetBankDefault
    let updateFastPaymentContract: FPSEndpoint.UpdateFastPaymentContract
    
    var httpClientStub: [URLPath: Data] {
        
        let pairs: [(URLPath, String)] = [
            (fastPaymentContractFindList.urlPath, fastPaymentContractFindList.filename),
            (getClientConsentMe2MePull.urlPath, getClientConsentMe2MePull.filename),
            (getBankDefault.urlPath, getBankDefault.filename),
            (updateFastPaymentContract.urlPath, updateFastPaymentContract.filename),
        ]
        let mapped = pairs.map { ($0.0, Data.json($0.1)) }
        
        return .init(uniqueKeysWithValues: mapped)
    }
}

private protocol Endpointed {
    
    var endpoint: Services.Endpoint { get }
}

extension RawRepresentable where RawValue == String, Self: Endpointed {
    
    var filename: String { "\(endpoint.serviceName.rawValue)\(rawValue.uppercased())" }
    var urlPath: URLPath { .init(endpoint.path) }
}

enum FPSEndpoint {
    
    case fastPaymentContractFindList(FastPaymentContractFindList)
    case getClientConsentMe2MePull(GetClientConsentMe2MePull)
    case getBankDefault(GetBankDefault)
    case updateFastPaymentContract(UpdateFastPaymentContract)
    
    enum FastPaymentContractFindList: String, Endpointed {
        
        case a1, a2, a3, a4, a5
        
        var endpoint: Services.Endpoint { .fastPaymentContractFindList }
    }
    
    enum GetClientConsentMe2MePull: String, Endpointed {
        
        case b1, b2, b3, b4
        
        var endpoint: Services.Endpoint { .getClientConsentMe2MePull }
    }
    
    enum GetBankDefault: String, Endpointed {
        
        case c1, c2, c3, c4, c5
        
        var endpoint: Services.Endpoint { .getBankDefault }
    }
    
    enum UpdateFastPaymentContract: String, Endpointed {
        
        case d1, d2, d3
        
        var endpoint: Services.Endpoint { .updateFastPaymentContract }
    }
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
}

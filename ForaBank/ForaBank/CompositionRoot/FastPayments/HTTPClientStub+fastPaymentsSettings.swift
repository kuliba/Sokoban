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
        fastPaymentContractFindList: [.a3, .a1, .a2, .a1, .a2, .a1],
        getClientConsentMe2MePull: [.b3],
        getBankDefault: [.c2],
        updateFastPaymentContract: [.d1, .d1, .d1, .d1],
        prepareSetBankDefault: [.f1],
        makeSetBankDefault: [.g4],
        changeClientConsentMe2MePull: [.h1],
        getC2BSub: [.j1]
    )
}

extension HTTPClientStub {
    
    static func fastPaymentsSettings(
        _ stub: FPSEndpointStub = .default,
        delay: DispatchTimeInterval = .seconds(1)
    ) -> HTTPClientStub {
        
        .init(stub.httpClientStub, delay: delay)
    }
}

struct FPSEndpointStub {
    
    let fastPaymentContractFindList: [FPSEndpoint.FastPaymentContractFindList]
    let getClientConsentMe2MePull: [FPSEndpoint.GetClientConsentMe2MePull]
    let getBankDefault: [FPSEndpoint.GetBankDefault]
    let updateFastPaymentContract: [FPSEndpoint.UpdateFastPaymentContract]
    let prepareSetBankDefault: [FPSEndpoint.PrepareSetBankDefault]
    let makeSetBankDefault: [FPSEndpoint.MakeSetBankDefault]
    let changeClientConsentMe2MePull: [FPSEndpoint.ChangeClientConsentMe2MePull]
    let getC2BSub: [FPSEndpoint.GetC2BSub]
    
    var httpClientStub: [Services.Endpoint.ServiceName: [Data]] {
        
        let stub: [Services.Endpoint.ServiceName: [String]] = [
            .fastPaymentContractFindList: fastPaymentContractFindList.map(\.filename),
            .getClientConsentMe2MePull: getClientConsentMe2MePull.map(\.filename),
            .getBankDefault: getBankDefault.map(\.filename),
            .makeSetBankDefault: makeSetBankDefault.map(\.filename),
            .updateFastPaymentContract: updateFastPaymentContract.map(\.filename),
            .prepareSetBankDefault: prepareSetBankDefault.map(\.filename),
            .changeClientConsentMe2MePull: changeClientConsentMe2MePull.map(\.filename),
            .getC2BSub: getC2BSub.map(\.filename),
        ]
        
        return stub.mapValues { $0.map { Data.json($0) }}
    }
}

private protocol Serviceable {
    
    var service: Services.Endpoint.ServiceName { get }
}

extension RawRepresentable where RawValue == String, Self: Serviceable {
    
    var filename: String { "\(service.rawValue)\(rawValue.uppercased())" }
}

enum FPSEndpoint {
    
    case fastPaymentContractFindList(FastPaymentContractFindList)
    case getClientConsentMe2MePull(GetClientConsentMe2MePull)
    case getBankDefault(GetBankDefault)
    case updateFastPaymentContract(UpdateFastPaymentContract)
    
    enum FastPaymentContractFindList: String, Serviceable {
        
        case a1, a2, a3, a4, a5
        
        var service: Services.Endpoint.ServiceName { .fastPaymentContractFindList }
    }
    
    enum GetClientConsentMe2MePull: String, Serviceable {
        
        case b1, b2, b3, b4
        
        var service: Services.Endpoint.ServiceName { .getClientConsentMe2MePull }
    }
    
    enum GetBankDefault: String, Serviceable {
        
        case c1, c2, c3, c4, c5
        
        var service: Services.Endpoint.ServiceName { .getBankDefault }
    }
    
    enum UpdateFastPaymentContract: String, Serviceable {
        
        case d1, d2, d3
        
        var service: Services.Endpoint.ServiceName { .updateFastPaymentContract }
    }
    
    enum PrepareSetBankDefault: String, Serviceable {
        
        case f1, f2, f3
        
        var service: Services.Endpoint.ServiceName { .prepareSetBankDefault }
    }
    
    enum MakeSetBankDefault: String, Serviceable {
        
        case g1, g2, g3, g4
        
        var service: Services.Endpoint.ServiceName { .makeSetBankDefault }
    }
    
    enum ChangeClientConsentMe2MePull: String, Serviceable {
        
        case h1, h2, h3
        
        var service: Services.Endpoint.ServiceName { .changeClientConsentMe2MePull }
    }
    
    enum GetC2BSub: String, Serviceable {
        
        case j1, j2, j3, j4
        
        var service: Services.Endpoint.ServiceName { .getC2BSub }
    }
}

extension Data {
    
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

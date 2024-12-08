//
//  ArrayOfCodableServicePaymentOperatorTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

@testable import Vortex
import RemoteServices
import XCTest

final class ArrayOfCodableServicePaymentOperatorTests: XCTestCase {
    
    func test_toModel_shouldDeliverEmptyOnEmpty() {
        
        assert([], to: [])
    }
    
    func test_toModel_shouldDeliverOneOnOne() {
        
        let provider = makeProvider()
        
        assert([provider], to: [.init(
            id: provider.id,
            inn: provider.inn,
            md5Hash: provider.md5Hash,
            name: provider.name,
            type: provider.type,
            sortedOrder: 0
        )])
    }
    
    func test_toModel_shouldSortCyrillicNameAlphabetically() {
        
        let provider1 = makeProvider(name: "бразилия")
        let provider2 = makeProvider(name: "армения")
        
        assert([provider1, provider2], names: [
            "армения",
            "бразилия"
        ])
    }
    
    func test_toModel_shouldSortCyrillicNameAlphabetically2() {
        
        let provider1 = makeProvider(name: "армения")
        let provider2 = makeProvider(name: "бразилия")
        
        assert([provider1, provider2], names: [
            "армения",
            "бразилия"
        ])
    }
    
    func test_toModel_shouldSortCyrillicNameAlphabetically3() {
        
        let provider1 = makeProvider(name: "Aрмения")
        let provider2 = makeProvider(name: "армения")
        
        assert([provider1, provider2], names: [
            "армения",
            "Aрмения"
        ])
    }
    
    func test_toModel_shouldSortByCyrillicBeforeDigit() {
        
        let provider1 = makeProvider(name: "1армения")
        let provider2 = makeProvider(name: "армения")
        
        assert([provider1, provider2], names: [
            "армения",
            "1армения"
        ])
    }
    
    func test_toModel_shouldSortByCyrillicBeforeLatin() {
        
        let provider1 = makeProvider(name: "armenia")
        let provider2 = makeProvider(name: "армения")
        
        assert([provider1, provider2], names: [
            "армения",
            "armenia"
        ])
    }
    
    func test_toModel_shouldSortByCyrillicBeforeLatin2() {
        
        let provider1 = makeProvider(name: "армеnia")
        let provider2 = makeProvider(name: "армения")
        
        assert([provider1, provider2], names: [
            "армения",
            "армеnia"
        ])
    }
    
    func test_toModel_shouldSortByINNOnSameName() {
        
        let provider1 = makeProvider(inn: "1", name: "Абв")
        let provider2 = makeProvider(inn: "0", name: "Абв")
        
        assert([provider1, provider2], inns: [
            "0",
            "1"
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Provider = RemoteServices.ResponseMapper.ServicePaymentProvider
    private typealias Model = CodableServicePaymentOperator
    
    private func toModel(
        _ providers: [Provider]
    ) -> [Model] {
        
        return .init(providers: providers)
    }
    
    private func makeProvider(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        name: String = anyMessage(),
        type: String = anyMessage()
    ) -> Provider {
        
        makeServicePaymentProvider(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type)
    }
    
    private func assert(
        _ providers: [Provider],
        to expectedModels: [Model],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(toModel(providers), expectedModels, file: file, line: line)
    }
    
    private func assert(
        _ providers: [Provider],
        names expectedNames: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(toModel(providers).map(\.name), expectedNames, file: file, line: line)
    }
    
    private func assert(
        _ providers: [Provider],
        inns expectedINNs: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(toModel(providers).map(\.inn), expectedINNs, file: file, line: line)
    }
}

extension XCTestCase {
    
    func makeServicePaymentProvider(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        name: String = anyMessage(),
        type: String = anyMessage()
    ) -> RemoteServices.ResponseMapper.ServicePaymentProvider {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type)
    }
}

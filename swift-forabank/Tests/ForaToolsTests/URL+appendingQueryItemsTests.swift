//
//  URL+appendingQueryItemsTests.swift
//
//
//  Created by Igor Malyarov on 07.09.2024.
//

import ForaTools
import XCTest

final class URL_appendingQueryItemsTests: XCTestCase {
    
    func test_appendingQueryItems_shouldNotChangeURLOnEmptyParameters() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let url = try baseURL.appendingQueryItems(parameters: [:])
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url")
    }
    
    func test_appendingQueryItems_shouldNotChangeURLOnEmptyKey() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let url = try baseURL.appendingQueryItems(parameters: ["": anyMessage()])
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url")
    }
    
    func test_appendingQueryItems_shouldNotChangeURLOnEmptyValue() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let url = try baseURL.appendingQueryItems(parameters: [anyMessage(): ""])
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url")
    }
    
    func test_appendingQueryItems_oneParameter() throws {
        
        let (randomKey, randomValue) = (anyMessage(), anyMessage())
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = [randomKey: randomValue]
        let url = try baseURL.appendingQueryItems(parameters: parameters)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?\(randomKey)=\(randomValue)")
    }
    
    func test_appendingQueryItems_twoParameters() throws {
        
        let (randomKey1, randomValue1) = (anyMessage(), anyMessage())
        let (randomKey2, randomValue2) = (anyMessage(), anyMessage())
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = [
            randomKey1: randomValue1,
            randomKey2: randomValue2
        ]
        let url = try baseURL.appendingQueryItems(parameters: parameters)
        
        XCTAssert(url.absoluteString.hasPrefix("https://any-url?"))
        XCTAssert(url.absoluteString.contains("\(randomKey1)=\(randomValue1)"))
        XCTAssert(url.absoluteString.contains("\(randomKey2)=\(randomValue2)"))
        
        let queryComponents = try XCTUnwrap(url.query).split(separator: "&")
        XCTAssertNoDiff(queryComponents.count, 2)
    }
    
    func test_appendingQueryItems_mix() throws {
        
        let (randomKey1, randomValue1) = (anyMessage(), anyMessage())
        let (randomKey2, randomValue2) = (anyMessage(), anyMessage())
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = [
            "": anyMessage(),
            randomKey1: randomValue1,
            anyMessage(): "",
            randomKey2: randomValue2
        ]
        let url = try baseURL.appendingQueryItems(parameters: parameters)
        
        XCTAssert(url.absoluteString.hasPrefix("https://any-url?"))
        XCTAssert(url.absoluteString.contains("\(randomKey1)=\(randomValue1)"))
        XCTAssert(url.absoluteString.contains("\(randomKey2)=\(randomValue2)"))
        
        let queryComponents = try XCTUnwrap(url.query).split(separator: "&")
        XCTAssertNoDiff(queryComponents.count, 2)
    }
    
    func test_appendingQueryItems_largeNumberOfParameters() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = (1...10_000).map { ("key\($0)", "value\($0)") }
        
        let url = try baseURL.appendingQueryItems(parameters: .init(uniqueKeysWithValues: parameters))
        
        let queryComponents = try XCTUnwrap(url.query).split(separator: "&")
        XCTAssertNoDiff(queryComponents.count, 10_000)
    }
    
    func test_appendingQueryItems_specialCharactersInParameters() throws {
        
        let specialKey = "key with spaces & symbols"
        let expectedEncodedKey = "key%20with%20spaces%20%26%20symbols"
        let specialValue = "value with spaces & symbols"
        let expectedEncodedValue = "value%20with%20spaces%20%26%20symbols"
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = [specialKey: specialValue]
        
        let url = try baseURL.appendingQueryItems(parameters: parameters)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?\(expectedEncodedKey)=\(expectedEncodedValue)")
    }
    
    func test_appendingQueryItems_unicodeCharacters() throws {
        
        let specialKey = "ключ"
        let specialValue = "значение"
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = [specialKey: specialValue]
        
        let url = try baseURL.appendingQueryItems(parameters: parameters)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?%D0%BA%D0%BB%D1%8E%D1%87=%D0%B7%D0%BD%D0%B0%D1%87%D0%B5%D0%BD%D0%B8%D0%B5")
    }
}

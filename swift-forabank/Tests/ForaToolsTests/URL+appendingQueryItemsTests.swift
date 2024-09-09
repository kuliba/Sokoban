//
//  URL+appendingQueryItemsTests.swift
//
//
//  Created by Igor Malyarov on 07.09.2024.
//

import ForaTools
import XCTest

final class URL_appendingQueryItemsTests: XCTestCase {
    
    func test_appendingQueryItems_noParameters() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let url = try baseURL.appendingQueryItems(parameters: [], value: anyMessage())
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url")
    }
    
    func test_appendingQueryItems_oneParameter() throws {
        
        let randomValue = anyMessage()
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = ["isPhonePayments"]
        let url = try baseURL.appendingQueryItems(parameters: parameters, value: randomValue)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?isPhonePayments=\(randomValue)")
    }
    
    func test_appendingQueryItems_twoParameters() throws {
        
        let randomValue = anyMessage()
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = ["isPhonePayments", "isCountriesPayments"]
        let url = try baseURL.appendingQueryItems(parameters: parameters, value: randomValue)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?isPhonePayments=\(randomValue)&isCountriesPayments=\(randomValue)")
    }
    
    func test_appendingQueryItems_largeNumberOfParameters() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = (1...1_000).map { "param\($0)" }
        let resultURL = try baseURL.appendingQueryItems(parameters: parameters, value: "value")
        
        let query = try XCTUnwrap(resultURL.query)
        
        let queryComponents = query.split(separator: "&")
        XCTAssertNoDiff(queryComponents.count, 1_000)
    }
    
    func test_appendingQueryItems_specialCharactersInParameters() throws {
        
        let specialValue = "value with spaces & symbols"
        let expectedEncodedValue = "value%20with%20spaces%20%26%20symbols"
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = ["is PhonePayments", "isCountries&Payments"]
        let url = try baseURL.appendingQueryItems(parameters: parameters, value: specialValue)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?is%20PhonePayments=\(expectedEncodedValue)&isCountries%26Payments=\(expectedEncodedValue)")
    }
    
    func test_appendingQueryItems_shouldNotChangeURLOnEmptyParameterName() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = [""]
        let url = try baseURL.appendingQueryItems(parameters: parameters, value: "value")
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url")
    }
    
    func test_appendingQueryItems_shouldNotChangeURLOnEmptyValue() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = ["isPhonePayments"]
        let url = try baseURL.appendingQueryItems(parameters: parameters, value: "")
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url")
    }
    
    func test_appendingQueryItems_shouldIncludeOnlyValidParamsWhenMixed() throws {
        
        let baseURL = try XCTUnwrap(URL(string: "https://any-url"))
        let parameters = ["isPhonePayments", "", "isCountriesPayments", ""]
        let url = try baseURL.appendingQueryItems(parameters: parameters, value: "abc")
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?isPhonePayments=abc&isCountriesPayments=abc")
    }
}

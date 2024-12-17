//
//  RootViewModelFactory+composeServiceCategoryRemoteLoadTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.12.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_composeServiceCategoryRemoteLoadTests: RootViewModelFactoryServiceCategoryTests {
    
    func test_shouldDeliverFailureOnNilSerialHTTPClientFailure() {
        
        expect(
            nil,
            forSerial: nil,
            on: { $0.complete(with: anyError()) }
        )
    }
    
    func test_shouldDeliverFailureOnNonNilSerialHTTPClientFailure() {
        
        expect(
            nil,
            forSerial: anyMessage(),
            on: { $0.complete(with: anyError()) }
        )
    }
    
    func test_shouldDeliverFailureOnNilSerialHTTPClientSuccessInvalidData() {
        
        expect(
            nil,
            forSerial: nil,
            on: { $0.complete(with: .emptyJSON) }
        )
    }
    
    func test_shouldDeliverFailureOnNonNilSerialHTTPClientSuccessInvalidData() {
        
        expect(
            nil,
            forSerial: anyMessage(),
            on: { $0.complete(with: .emptyJSON) }
        )
    }
    
    func test_shouldDeliverSuccessOnNilSerialHTTPClientSuccessValidData() {
        
        expect(
            stampedCategories(),
            forSerial: nil,
            on: { $0.complete(with: self.validJSON()) }
        )
    }
    
    func test_shouldDeliverFailureOnSameSerialHTTPClientSuccessValidData() {
        
        let sameSerial = serial()
        
        expect(
            nil,
            forSerial: sameSerial,
            on: { $0.complete(with: self.validJSON()) }
        )
    }
    
    func test_shouldDeliverSuccessOnDifferentSerialHTTPClientSuccessValidData() {
        
        expect(
            stampedCategories(),
            forSerial: anyMessage(),
            on: { $0.complete(with: self.validJSON()) }
        )
    }
    
    // MARK: - Helpers
    
    private func validJSON() -> Data {
        
        getServiceCategoryListJSON()
    }
    
    private func expect(
        _ expectedStamped: Stamped?,
        forSerial serial: String? = nil,
        on action: @escaping (HTTPClientSpy) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
        let (sut, httpClient, _) = makeSUT(file: file, line: line)
        let composer = sut.nanoServiceComposer
        let remoteLoad = composer.composeServiceCategoryRemoteLoad()
        let exp = expectation(description: "wait for load completion")
        
        remoteLoad(serial) {
            
            httpClient.expectRequests(withLastPathComponents: [
                "getServiceCategoryList",
            ])
            
            XCTAssertNoDiff(try? $0.get(), expectedStamped, "Expected \(String(describing: expectedStamped)), but got \($0) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action(httpClient)
        
        wait(for: [exp], timeout: 1.0)
    }
}

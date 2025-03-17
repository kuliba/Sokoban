//
//  RootViewModelFactory+getPrintFormTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.03.2025.
//

@testable import Vortex
import PDFKit
import XCTest

final class RootViewModelFactory_getPrintFormTests: RootViewModelFactoryTests {
    
    func test_getPrintForm_shouldCallHTTPClient() {
        
        let (sut, httpClient, _) = makeSUT()
        
        sut.getPrintForm(paymentOperationDetailID: .random(in: 1...100), printFormType: anyMessage()) { _ in }
        
        httpClient.expectRequests(withLastPathComponents: ["getPrintForm"])
    }
    
    func test_getPrintForm_shouldDeliverNil_onHTTPClientFailure() {
        
        let (sut, httpClient, _) = makeSUT()
        
        getPrintForm(sut: sut) {
            XCTAssertNil(try? $0.get())
        } on: {
            httpClient.complete(with: anyError())
        }
    }
    
    func test_getPrintForm_shouldDeliverNil_onNonPDFData() {
        
        let (sut, httpClient, _) = makeSUT()
        
        getPrintForm(sut: sut) {
            XCTAssertNil(try? $0.get())
        } on: {
            httpClient.complete(with: .json(anyMessage()))
        }
    }
    
    func test_getPrintForm_shouldDeliverDocument_onValidResponse() throws {
        
        let (sut, httpClient, _) = makeSUT()
        
        getPrintForm(sut: sut) {
            XCTAssertNotNil($0)
        } on: {
            try? httpClient.complete(with: makeMinimalTestPDFData())
        }
    }
    
    // MARK: - Helpers
    
    private func getPrintForm(
        sut: SUT,
        id: Int = .random(in: 1...100),
        type: String = anyMessage(),
        assert: @escaping (Result<PDFDocument, Error>) -> Void = { _ in },
        on action: () -> Void,
        timeout: TimeInterval = 1.0
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getPrintForm(
            paymentOperationDetailID: id,
            printFormType: type
        ) {
            assert($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

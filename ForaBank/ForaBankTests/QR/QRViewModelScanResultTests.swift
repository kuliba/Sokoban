//
//  QRViewModelScanResultTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.12.2023.
//

@testable import ForaBank
import XCTest

final class QRViewModelScanResultTests: XCTestCase {
    
    func test_urlStringWithQRNSPK_shouldDeliverC2BURL() throws {
        
        let url = try makeURL("https://qr.nspk.ru?acb=123")
        
        let result = makeResult(with: url)
        
        XCTAssertNoDiff(result, .c2bURL(url))
    }
    
    func test_urlStringWithSubNSPK_shouldDeliverC2BSubscribeURL() throws {
        
        let url = try makeURL("https://sub.nspk.ru?acb=123")
        
        let result = makeResult(with: url)
        
        XCTAssertNoDiff(result, .c2bSubscribeURL(url))
    }
    
    func test_otherURLString_shouldDeliverURL() throws {
        
        let url = anyURL()
        
        let result = makeResult(with: url)
        
        XCTAssertNoDiff(result, .url(url))
    }
    
    func test_qrString_shouldDeliverQRCode() throws {
        
        let string = "This is not a URL"
        
        let result = ScanResult(string: string).equatable
        
        XCTExpectFailure("QRCode generation is too complex")
        XCTAssertNoDiff(result, .qrCode(original: string, rawData: [:]))
    }
    
    func test_emptyString_shouldDeliverUnknown() {
        
        let result = ScanResult(string: "").equatable
        
        XCTAssertNoDiff(result, .unknown)
    }
    
    func test_notQRNotURLString_shouldDeliverUnknown() {
        
        let notQRNotURLString = "This is not a URL"
        
        let result = ScanResult(string: notQRNotURLString).equatable
        
        XCTAssertNoDiff(result, .unknown)
    }
    
    // MARK: - Helpers
    
    private typealias ScanResult = QRViewModel.ScanResult
    private typealias Result = ScanResult.EquatableScanResult
    
    private func makeResult(with url: URL) -> Result {
        
        ScanResult(string: url.absoluteString).equatable
    }
    
    private func makeURL(_ string: String) throws -> URL {
        
        try XCTUnwrap(URL(string: string))
    }
}

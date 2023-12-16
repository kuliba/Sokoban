//
//  QRResolverTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import ForaBank
import XCTest

final class QRResolverTests: XCTestCase {
    
    func test_resolve_shouldReturnSberQROnIsSberQRStubTrue() {
        
        let url = anyURL()
        let resolved = resolve(url.absoluteString, isSberQRStub: true)
        
        XCTAssertNoDiff(resolved, .sberQR(url))
    }
    
    func test_resolve_shouldNotReturnSberQROnIsSberQRStubFalse() {
        
        let url = anyURL()
        let resolved = resolve(url.absoluteString, isSberQRStub: false)
        
        XCTAssertNotEqual(resolved, .sberQR(url))
    }
    
    func test_urlStringWithQRNSPK_shouldDeliverC2BURL() {
        
        let url = anyURL(string: "https://qr.nspk.ru?acb=123")
        
        XCTAssertNoDiff(resolve(url), .c2bURL(url))
    }
    
    func test_urlStringWithSubNSPK_shouldDeliverC2BSubscribeURL() {
        
        let url = anyURL(string: "https://sub.nspk.ru?acb=123")
        
        XCTAssertNoDiff(resolve(url), .c2bSubscribeURL(url))
    }
    
    func test_otherURLString_shouldDeliverURL() {
        
        let url = anyURL()
        
        XCTAssertNoDiff(resolve(url), .url(url))
    }
    
    func test_qrString_shouldDeliverQRCode() {
        
        let string = "This is not a URL"
        
        let resolved = resolve(string)
        
        XCTExpectFailure("QRCode generation is too complex")
        XCTAssertNoDiff(resolved, .qrCode(original: string, rawData: [:]))
    }
    
    func test_emptyString_shouldDeliverUnknown() {
        
        XCTAssertNoDiff(resolve(""), .unknown)
    }
    
    func test_notQRNotURLString_shouldDeliverUnknown() {
        
        let notQRNotURLString = "This is not a URL"
        
        XCTAssertNoDiff(resolve(notQRNotURLString), .unknown)
    }
    
    // MARK: - Helpers
    
    private func resolve(
        _ url: URL,
        isSberQRStub: Bool = false
    ) -> QRViewModel.ScanResult.EquatableScanResult {
        
        resolve(url.absoluteString, isSberQRStub: isSberQRStub)
    }
    
    private func resolve(
        _ urlString: String,
        isSberQRStub: Bool = false
    ) -> QRViewModel.ScanResult.EquatableScanResult {
        
        let resolver = QRResolver(isSberQR: { _ in isSberQRStub })
        
        return resolver.resolve(string: urlString).equatable
    }
}

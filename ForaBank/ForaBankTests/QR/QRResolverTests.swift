//
//  QRResolverTests.swift
//  VortexTests
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
    
    func test_emptyString_shouldDeliverUnknown() {
        
        XCTAssertNoDiff(resolve(""), .unknown)
    }
    
    func test_notQRNotURLString_shouldDeliverUnknown() {
        
        let notQRNotURLString = "This is not a URL"
        
        XCTAssertNoDiff(resolve(notQRNotURLString), .unknown)
    }
    
    func  test_defaultURLString_shouldDeliverURL() {
        
        XCTAssertNoDiff(resolve(anyURL(string: "forabank.ru")), .url(anyURL(string: "forabank.ru")))
    }
    
    func test_validQRCodeStringNotURL_shouldDeliverQRCode_whenST00011() {
       
        XCTAssertEqual(resolve(.qr1), .qrCode(original: .qr1, rawData: getRawData(.qr1)))
    }
    
    func test_validQRCodeStringNotURL_shouldDeliverQRCode_whenST00012() {
        
        XCTAssertEqual(resolve(.qr2), .qrCode(original: .qr2, rawData: getRawData(.qr2)))
    }
    
    func test_validQRCodeStringNotURL_shouldDeliverQRCode_whenUrlWithBadEncodedName() {
        
        XCTAssertEqual(
            resolve(.qrResolveURLOrigin),
            .qrCode(original: .qrResolveURLOrigin, rawData: getRawData(.qrResolveURLOrigin))
        )
    }
    
    func test_validQRCodeStringNotURL_shouldDeliverQRCode_whenUrlWithoutAmount() {
        
        XCTAssertEqual(
            resolve(.qrResolveURLCustom1),
            .qrCode(original: .qrResolveURLCustom1, rawData: getRawData(.qrResolveURLCustom1))
        )
    }
    
    func test_validQRCodeStringNotURL_shouldDeliverQRCode_whenUrlWithAmount() {
        
        XCTAssertEqual(
            resolve(.qrResolveURLCustom2),
            .qrCode(original: .qrResolveURLCustom2, rawData: getRawData(.qrResolveURLCustom2))
        )
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
    
    private func getRawData(_ str: String) -> [String: String] {
         
         let stringData = QRCode.separatedString(string: str)
         let rawData = QRCode.rawDataMapping(qrStringData: stringData)
         
         return rawData
     }
}

extension QRViewModel.ScanResult {
    
    var equatable: EquatableScanResult {
        
        switch self {
        case let .qrCode(qrCode):
            return .qrCode(original: qrCode.original, rawData: qrCode.rawData)

        case let .c2bURL(c2bURL):
            return .c2bURL(c2bURL)

        case let .c2bSubscribeURL(c2bSubscribeURL):
            return .c2bSubscribeURL(c2bSubscribeURL)

        case let .sberQR(url):
            return .sberQR(url)
            
        case let .url(url):
            return .url(url)
            
        case .unknown:
            return .unknown
        }
    }
    
    enum EquatableScanResult: Equatable {
        
        case qrCode(original: String, rawData: [String : String])
        case c2bURL(URL)
        case c2bSubscribeURL(URL)
        case sberQR(URL)
        case url(URL)
        case unknown
    }
}

private extension String {
    
    static let qr1 = "ST00011|PayeeINN=1234567890|category=1|ServiceName=3006|addAmount=0"
    static let qr2 = "ST00012|PayeeINN=1234567890|category=1|ServiceName=3006|bic=123456798|addAmount=0"
    static let qrResolveURLOrigin = "ST00012%7CName=%D0%90%D0%9E%20%D0%A3%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D1%8F%D1%8E%D1%89%D0%B0%D1%8F%20%D0%BE%D1%80%D0%B3%D0 ... Amount=0"
    static let qrResolveURLCustom1 = "ST00012%7CName=%D0%90%D0%9E%20%D0%A3%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D1%8F%D1%8E%D1%89%D0%B0%D1%8F%20%D0%BE%D1%80%D0%B3%D0"
    static let qrResolveURLCustom2 = "ST00012%7CName=%D0%90%D0%9E%20%D0%A3%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D1%8F%D1%8E%D1%89%D0%B0%D1%8F%20%D0%BE%D1%80%D0%B3%D0Amount=0"
    
    static let qr3 = "ST00012|Name=АО Управляющая организация многоквартирными домами Ленинского района|PersonalAcc=40702810702910000312|BankName=АО  'АЛЬФА-БАНК' г. Москва|BIC=044525593|CorrespAcc=30101810200000000593|PayeeINN=7606066274|KPP=760601001|Sum=383296|Purpose=квитанция за ЖКУ|lastName=|payerAddress=Свердлова ул., д.102, кв.44|persAcc=502045019|paymPeriod=01.2024|category=1|ServiceName=5000|addAmount=0"
    
    static let qr6 = "https://platiqr.ru/?uuid=22428"
    static let containsST = "ST000"
}

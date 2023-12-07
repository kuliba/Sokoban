//
//  RequestFactory+getSberQRDataTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import ForaBank
import XCTest

final class RequestFactory_getSberQRDataTests: XCTestCase {
    
    func test_createGetSberQRRequest_shouldThrowOnEmptyLink() throws {
        
        XCTAssertThrowsError(
            try createGetSberQRRequest(linkString: "")
        ) {
            XCTAssertNoDiff(
                $0 as? RequestFactory.QRDataError,
                .emptyLink
            )
        }
    }
    
    func test_createGetSberQRRequest_shouldSetRequestURL() throws {
        
        let (_, request) = try createGetSberQRRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/binding/v1/getSberQRData"
        )
    }
    
    func test_createGetSberQRRequest_shouldSetRequestMethodToPost() throws {
        
        let (_, request) = try createGetSberQRRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createGetSberQRRequest_shouldSetRequestBody() throws {
        
        let (qrLink, request) = try createGetSberQRRequest()
        let data = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(DecodableQRLink.self, from: data)
        
        XCTAssertNoDiff(qrLink, decodedRequest.qrLink)
    }
    
    // MARK: - Helpers
    
    private func createGetSberQRRequest(
        linkString: String = UUID().uuidString
    ) throws -> (
        qrLink: QRLink,
        request: URLRequest
    ) {
        let link = anyQrLink(link: linkString)
        let request = try RequestFactory.createGetSberQRRequest(link)
        
        return (link, request)
    }
    
    private func anyQrLink(
        link: String = UUID().uuidString
    ) -> QRLink {
        
        .init(link: .init(link))
    }
    
    private struct DecodableQRLink: Decodable {
        
        let linkString: String
        
        enum CodingKeys: String, CodingKey {
            
            case linkString = "QRLink"
        }
        
        init(_ link: QRLink) {
            
            self.linkString = link.link.rawValue
        }
        
        var qrLink: QRLink {
            
            .init(link: .init(linkString))
        }
    }
}

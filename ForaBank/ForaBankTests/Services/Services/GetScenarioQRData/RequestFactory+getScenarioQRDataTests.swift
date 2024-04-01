//
//  RequestFactory+getScenarioQRDataTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 26.09.2023.
//

@testable import ForaBank
import XCTest

final class Services_getScenarioQRDataTests: XCTestCase {
        
    // MARK: - makeGetScenarioQRRequest
    
    func test_makeGetScenarioQRRequest_shouldThrowOnEmptyLink() throws {
        
        XCTAssertThrowsError(
            try makeGetScenarioQRRequest(linkString: "")
        ) {
            XCTAssertNoDiff(
                $0 as? RequestFactory.QRDataError,
                .emptyLink
            )
        }
    }
    
    func test_makeGetScenarioQRRequest_shouldSetRequestURL() throws {
        
        let (_, request) = try makeGetScenarioQRRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/binding/v1/getScenarioQRData"
        )
    }
    
    func test_makeGetScenarioQRRequest_shouldSetRequestMethodToPost() throws {
        
        let (_, request) = try makeGetScenarioQRRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeGetScenarioQRRequest_shouldSetRequestBody() throws {
        
        let (qrLink, request) = try makeGetScenarioQRRequest()
        let data = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(DecodableQRLink.self, from: data)
         
        XCTAssertNoDiff(qrLink, decodedRequest.qrLink)
    }
    
    // MARK: - Helpers
    
    private func makeGetScenarioQRRequest(
        linkString: String = "any link"
    ) throws -> (
        qrLink: QRLink,
        request: URLRequest
    ) {
        let link = anyQrLink(link: linkString)
        let request = try RequestFactory.getScenarioQRDataRequest(link)
        
        return (link, request)
    }
    
    private func anyQrLink(
        link: String = "any link"
    ) -> QRLink {
        
        .init(
            link: .init(link)
        )
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
            
            .init(
                link: .init(linkString)
            )
        }
    }

}

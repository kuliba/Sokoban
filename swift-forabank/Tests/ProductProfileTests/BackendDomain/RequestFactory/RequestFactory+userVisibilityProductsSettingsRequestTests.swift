//
//  RequestFactory+userVisibilityProductsSettingsRequestTests.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import ProductProfile
import XCTest
import Services

final class RequestFactory_userVisibilityProductsSettingsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetHTTPBody() throws {
        
        let payload = anyPayload()
        let request = try createRequest(payload: payload)
     
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.categoryType, payload.category.rawValue)
        XCTAssertNoDiff(body.products.count, payload.products.count)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let categoryType = Payload.ProductsVisibilityPayload.Category.card
        let id = 2222
        let visibility = false
        let request = try createRequest(payload: .init(category: categoryType, products: [.init(productID: .init(id), visibility: .init(visibility))]))
        
        try assertBody(of: request, hasJSON: """
        {
          "categoryType": \(categoryType),
          "products": [
            {
              "id": \(id),
              "visibility": \(visibility)
            }
          ]
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: Payload.ProductsVisibilityPayload = .init(category: .card, products: [.init(productID: 1, visibility: false)])
    ) throws -> URLRequest {
        
        return try RequestFactory.userVisibilityProductsSettingsRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ category: Payload.ProductsVisibilityPayload.Category = .card,
        _ products: [Payload.ProductsVisibilityPayload.Product] = [.init(productID: 12, visibility: true)]
    ) -> Payload.ProductsVisibilityPayload {
        
        .init(category: category, products: products)
    }
    
    private struct Body: Decodable {
        
        let categoryType: String
        let products: [BodyProduct]
        
        struct BodyProduct: Decodable {
            
            let id: Int
            let visibility: Bool
        }
    }
}

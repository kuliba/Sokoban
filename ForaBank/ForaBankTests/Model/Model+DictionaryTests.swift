//
//  Model+DictionaryTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 03.09.2024.
//

@testable import ForaBank
import XCTest

final class Model_DictionaryTests: XCTestCase {
        
    // MARK: - test handleGetBannerCatalogListV1Response

    func test_handleGetBannerCatalogListV1Response_responseFailure_shouldNotUpdateBanners() {
        
        let sut = makeSUT(banners: [])
        
        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV1Response(.test, .failure(.emptyResponse))
        
        XCTAssertNoDiff(sut.catalogBanners.value, [])
    }

    func test_handleGetBannerCatalogListV1Response_responseSuccessEptyData_shouldNotUpdateBanners() {
        
        let sut = makeSUT(banners: [])

        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV1Response(
            .test,
            .success(.init(statusCode: .ok, data: .init(bannerCatalogList: [], serial: ""), errorMessage: nil)))
        
        XCTAssertNoDiff(sut.catalogBanners.value, [])
    }

    func test_handleGetBannerCatalogListV1Response_responseSuccess_shouldUpdateBanners() {
        
        let sut = makeSUT(banners: [])

        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV1Response(
            .test,
            .success(.init(statusCode: .ok, data: .init(bannerCatalogList: [.banner], serial: ""), errorMessage: nil)))
        
        XCTAssertNoDiff(sut.catalogBanners.value, [.banner])
    }
    
    func test_handleGetBannerCatalogListV1Response_responseSuccessStatusNotOk_shouldNotUpdateBanners() {
        
        let sut = makeSUT(banners: [])

        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV1Response(
            .test,
            .success(.init(statusCode: .error(1), data: nil, errorMessage: nil)))
        
        XCTAssertNoDiff(sut.catalogBanners.value, [])
    }

    // MARK: - test handleGetBannerCatalogListV2Response

    func test_handleGetBannerCatalogListV2Response_responseNil_shouldNotUpdateBanners() {
        
        let sut = makeSUT(banners: [])
        
        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV2Response(.test, nil)
        
        XCTAssertNoDiff(sut.catalogBanners.value, [])
    }

    func test_handleGetBannerCatalogListV2Response_responseEmptyData_shouldNotUpdateBanners() {
        
        let sut = makeSUT(banners: [])

        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV2Response(.test, .init(bannerCatalogList: [], serial: ""))

        XCTAssertNoDiff(sut.catalogBanners.value, [])
    }

    func test_handleGetBannerCatalogListV2Response_responseNotNil_shouldUpdateBanners() {
        
        let sut = makeSUT(banners: [])

        XCTAssertNoDiff(sut.catalogBanners.value, [])

        sut.handleGetBannerCatalogListV2Response(.test, .init(bannerCatalogList: [.banner], serial: ""))
        
        XCTAssertNoDiff(sut.catalogBanners.value, [.banner])
    }

    // MARK: - Helpers
    
    private typealias SUT = Model
    private typealias BannerCatalogListResponse = Services.GetBannerCatalogListV1Response

    private func makeSUT(
        banners: [BannerCatalogListData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
                
        let sut = SUT.mockWithEmptyExcept()
        
        sut.catalogBanners.value = banners
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension ServerCommands.DictionaryController.GetBannerCatalogList {
    
    static let test: Self = .init(token: "", serial: "")
}

private extension BannerCatalogListData {
    
    static let banner: Self = .init(productName: "productName", conditions: [], imageEndpoint: "imageEndpoint", orderURL: nil, conditionURL: nil, action: .init(type: .openDeposit))
}

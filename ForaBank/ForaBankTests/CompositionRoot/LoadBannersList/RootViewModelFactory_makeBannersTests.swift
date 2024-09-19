//
//  RootViewModelFactory_makeBannersTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 10.09.2024.
//

@testable import ForaBank
import Banners
import LandingMapping
import PayHub
import XCTest

final class RootViewModelFactory_makeBannersTests: XCTestCase {

    func test_init_shouldNotCallCollaborators() {
        
        let (sut, bannersSpy, landingSpy) = makeSUT()
        
        XCTAssertEqual(bannersSpy.callCount, 0)
        XCTAssertEqual(landingSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }

    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, bannersSpy, _) = makeSUT()

        sut.content.bannerPicker.content.event(.load)
        
        XCTAssertEqual(bannersSpy.callCount, 1)
        XCTAssertNotNil(sut)
    }

    func test_shouldSetCategoryPickerContentStateToLoading() {
        
        let state = makeSUT().sut.content.bannerPicker.content.state
        
        XCTAssertTrue(state.isLoading)
    }

    // MARK: - Helpers
    
    private typealias SUT = BannersBinder
    private typealias LoadBannersSpy = Spy<Void, [BannerPickerSectionItem<BannerCatalogListData>], Never>
    private typealias LoadLandingSpy = Spy<String, Result<Landing, Error>, Never>

    private func makeSUT(
        bannerPickerPlaceholderCount: Int = 6,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadBannersSpy: LoadBannersSpy,
        loadLandingByTypeSpy: LoadLandingSpy
    ) {
        let loadBannersSpy = LoadBannersSpy()
        let loadLandingByTypeSpy = LoadLandingSpy()

        let sut = RootViewModelFactory.makeBanners(
            model: .mockWithEmptyExcept(),
            bannerPickerPlaceholderCount: bannerPickerPlaceholderCount,
            nanoServices: .init(
                loadBanners: loadBannersSpy.process(completion:),
                loadLandingByType: loadLandingByTypeSpy.process(_:completion:)
            ),
            mainScheduler: .immediate,
            backgroundScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadBannersSpy, file: file, line: line)
        trackForMemoryLeaks(loadLandingByTypeSpy, file: file, line: line)

        return (sut, loadBannersSpy, loadLandingByTypeSpy)
    }
}

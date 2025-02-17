//
//  RootViewModelFactory+makePaymentsTransfersPersonalContentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 20.08.2024.
//

@testable import Vortex
import PayHub
import PayHubUI
import XCTest

final class RootViewModelFactory_makePaymentsTransfersPersonalContentTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _,_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, _,_, spy) = makeSUT()
        
        sut.operationPicker.operationBinder?.content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetTemplatesAndExchangePrefix() {
        
        let sut = makeSUT().sut
        
        let prefix = sut.operationPicker.operationBinder?.content.state.elements.prefix(2)
        
        XCTAssertNoDiff(prefix, [.templates, .exchange])
    }
    
    func test_shouldSetCategoryPickerContentStateToLoading() throws {
        
        let state = try XCTUnwrap(makeSUT().sut.categoryPicker.sectionBinder?.content.state)
        
        XCTAssertTrue(state.isLoading)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Vortex.PaymentsTransfersPersonalDomain.Content
    private typealias LoadLatestSpy = Spy<Void, [Latest]?, Never>
    private typealias ContentDomain = CategoryPickerSectionDomain.ContentDomain
    private typealias LoadCategoriesSpy = Spy<Void, [ServiceCategory], Never>
    private typealias ReloadCategoriesSpy = Spy<(ItemListEvent<ServiceCategory>) -> Void, [ServiceCategory], Never>
    private typealias MakeQRModelSpy = CallSpy<Void, QRScannerModel>
    
    private func makeSUT(
        c2gFlag: C2GFlag = .inactive, // TODO: add tests assertions for active flag
        mapScanResult: @escaping RootViewModelFactory.MapScanResult = { _, completion in completion(.unknown) },
        makeQRResolve: @escaping RootViewModelFactory.MakeResolveQR = { _ in { _ in .unknown }},
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadCategoriesSpy: LoadCategoriesSpy,
        reloadCategoriesSpy: ReloadCategoriesSpy,
        loadLatestSpy: LoadLatestSpy
    ) {
        let loadCategoriesSpy = LoadCategoriesSpy()
        let reloadCategoriesSpy = ReloadCategoriesSpy()
        let loadLatestSpy = LoadLatestSpy()
        let factory = RootViewModelFactory(
            model: .mockWithEmptyExcept(),
            httpClient: HTTPClientSpy(),
            logger: LoggerSpy(),
            mapScanResult: mapScanResult,
            makeQRResolve: makeQRResolve,
            scanner: QRScannerViewModelSpy(),
            schedulers: .immediate
        )
        let sut = factory.makePaymentsTransfersPersonalContent(
            c2gFlag: c2gFlag,
            .init(
                loadCategories: loadCategoriesSpy.process(completion:),
                reloadCategories: reloadCategoriesSpy.process(_:completion:),
                loadAllLatest: loadLatestSpy.process(completion:)
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(reloadCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(loadLatestSpy, file: file, line: line)
        
        return (sut, loadCategoriesSpy, reloadCategoriesSpy, loadLatestSpy)
    }
}

// MARK: - DSL

extension LoadablePickerState {
    
    var elements: [Element] {
        
        items.compactMap {
            
            guard case let .element(identified) = $0
            else { return nil }
            
            return identified.element
        }
    }
}

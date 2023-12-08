//
//  SberQRFeatureViewModelTests.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import CombineSchedulers
import SberQR
import XCTest

final class SberQRFeatureViewModelTests: XCTestCase {
    
    func test_init_shouldSetDefaultInitialStateToLoading() {
        
        let sut = SUT(getSberQRData: { _,_ in })
        
        XCTAssertNoDiff(sut.state, .loading)
    }
    
    func test_init_shouldSeInitialState() {
        
        let statusCode = 401
        let invalidData = anyData()
        let initialState: SberQRFeatureState = .getSberQRDataError(.invalid(statusCode: statusCode, data: invalidData))
        let sut = makeSUT(initialState: initialState).sut
        
        XCTAssertNoDiff(sut.state, .getSberQRDataError(.invalid(statusCode: statusCode, data: invalidData)))
    }
    
    func test_init_shouldNotCallGetSberQRData() {
        
        let (_, _, serviceSpy) = makeSUT()
        
        XCTAssertNoDiff(serviceSpy.callCount, 0)
    }
    
    func test_loadSberQRData_shouldMCallGetSberQRDataWithURLString() {
        
        let url = anyURL()
        let (sut, _, serviceSpy) = makeSUT()
        
        sut.loadSberQRData(url: url)
        
        XCTAssertNoDiff(serviceSpy.payloads, [
            .init(qrLinkString: url.absoluteString)
        ])
    }
    
    func test_loadSberQRData_shouldDeliverInvalidErrorOnGetSberQRDataOtherError() {
        
        let statusCode = 400
        let data = anyData()
        let (sut, stateSpy, serviceSpy) = makeSUT()
        
        sut.loadSberQRData()
        XCTAssertNoDiff(stateSpy.values, [
            .loading
        ])
        
        serviceSpy.complete(with: .failure(.other(statusCode: statusCode, data: data)))
        XCTAssertNoDiff(stateSpy.values, [
            .loading,
            .getSberQRDataError(.invalid(statusCode: statusCode, data: data))
        ])
    }
    
    func test_loadSberQRData_shouldDeliverServerErrorOnGetSberQRDataServerError() {
        
        let statusCode = 400
        let errorMessage = "Server Failure"
        let (sut, stateSpy, serviceSpy) = makeSUT()
        
        sut.loadSberQRData()
        XCTAssertNoDiff(stateSpy.values, [
            .loading
        ])
        
        serviceSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        XCTAssertNoDiff(stateSpy.values, [
            .loading,
            .getSberQRDataError(.server(statusCode: statusCode, errorMessage: errorMessage))
        ])
    }
    
    func test_loadSberQRData_shouldDeliverScenarioQRDTOOnGetSberQRDataSuccess() {
        
        let response = anyGetSberQRDataResponse()
        let (sut, stateSpy, serviceSpy) = makeSUT()
        
        sut.loadSberQRData()
        XCTAssertNoDiff(stateSpy.values, [
            .loading
        ])
        serviceSpy.complete(with: .success(response))
        
        XCTAssertNoDiff(stateSpy.values, [
            .loading,
            .getSberQRDataResponse(response)
        ])
    }
    
    func test_loadSberQRData_shouldNotDeliverGetSberQRDataResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let stateSpy: StateSpy
        let serviceSpy: ServiceSpy
        (sut, stateSpy, serviceSpy) = makeSUT()
        
        sut?.loadSberQRData()
        sut = nil
        serviceSpy.complete(with: .failure(.other(statusCode: 400, data: anyData())))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(stateSpy.values, [
            .loading,
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SberQRFeatureViewModel
    private typealias StateSpy = ValueSpy<SberQRFeatureState>
    private typealias ServiceSpy = Spy<QRLink, GetSberQRDataResponse, SUT.ScenarioQRError>
    
    private func makeSUT(
        initialState: SberQRFeatureState = .loading,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        serviceSpy: ServiceSpy
    ) {
        let serviceSpy = ServiceSpy()
        let sut = SUT(
            initialState: initialState,
            getSberQRData: serviceSpy.process(_:completion:),
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, serviceSpy)
    }
    
    private func anyGetSberQRDataResponse(
    ) -> GetSberQRDataResponse {
        
        .init(
            qrcID: UUID().uuidString,
            parameters: [],
            required: []
        )
    }
}

private extension SberQRFeatureViewModel {
    
    func loadSberQRData() {
        
        loadSberQRData(url: anyURL())
    }
}

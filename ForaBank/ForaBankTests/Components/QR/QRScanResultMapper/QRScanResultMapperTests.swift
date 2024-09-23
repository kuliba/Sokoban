//
//  QRScanResultMapperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.08.2024.
//

@testable import ForaBank
import XCTest

final class QRScanResultMapperTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_mapScanResult_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let spy: GetOperatorsSpy
        (sut, spy) = makeSUT(qrMapping: anyQRMapping())
        var receivedResult: QRModelResult?
        
        sut?.mapScanResult(.qrCode(anyQR())) { receivedResult = $0 }
        sut = nil
        spy.complete(with: .none)
        
        XCTAssertNil(receivedResult)
    }
    
    func test_mapScanResult_shouldDeliverMappedMixedOnMixed() {
        
        let (qr, qrMapping) = (anyQR(), anyQRMapping())
        let mixed = makeMixed()
        let (sut, spy) = makeSUT(qrMapping: qrMapping)
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.mixed(mixed, qr, qrMapping))) {
            
            spy.complete(with: .mixed(mixed))
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedMultipleOnMultiple() {
        
        let (qr, qrMapping) = (anyQR(), anyQRMapping())
        let multiple = makeMultiple()
        let (sut, spy) = makeSUT(qrMapping: qrMapping)

        expect(sut, with: .qrCode(qr), delivers: .mapped(.multiple(multiple, qr, qrMapping))) {
            
            spy.complete(with: .multiple(multiple))
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedNoneOnNone() {
        
        let qr = anyQR()
        let (sut, spy) = makeSUT(qrMapping: anyQRMapping())
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.none(qr))) {
            
            spy.complete(with: .none)
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedSingleOnNonServiceOperator() {
        
        let (qr, qrMapping) = (anyQR(), anyQRMapping())
        let `operator` = makeOperator()
        let (sut, spy) = makeSUT(qrMapping: qrMapping)
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.single(`operator`, qr, qrMapping))) {
            
            spy.complete(with: .operator(`operator`))
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedServicePaymentSourceOnServiceOperatorQRWithSum() {
        
        let puref = anyMessage()
        let `operator` = makeOperator(
            code: puref,
            parentCode: serviceParentCode
        )
        let qr = anyQR(rawData: ["sum": "12345"])
        let (sut, spy) = makeSUT(qrMapping: anyQRMapping())
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.source(.servicePayment(
            puref: puref,
            additionalList: [],
            amount: 123.45
        )))) {
            spy.complete(with: .operator(`operator`))
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedServicePaymentSourceWithZeroAmountOnServiceOperatorQRWithoutSum() {
        
        let puref = anyMessage()
        let `operator` = makeOperator(
            code: puref,
            parentCode: serviceParentCode
        )
        let qr = anyQR()
        let (sut, spy) = makeSUT(qrMapping: anyQRMapping())
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.source(.servicePayment(
            puref: puref,
            additionalList: [],
            amount: 0
        )))) {
            spy.complete(with: .operator(`operator`))
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedServicePaymentSourceWithAdditionalListOnServiceOperator() {
        
        let puref = "account"
        let title = "title " + anyMessage()
        let `operator` = makeOperator(
            code: puref,
            parameterList: [
                .test(
                    id: puref, 
                    title: title,
                    inputFieldType: .account,
                    viewType: .input
                )
            ],
            parentCode: serviceParentCode
        )
        let persacc = "persacc " + anyMessage()
        let qr = anyQR(rawData: ["account": anyMessage(), "persacc": persacc])
        let (sut, spy) = makeSUT(qrMapping: anyQRMapping())
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.source(.servicePayment(
            puref: puref,
            additionalList: [
                .init(
                    fieldTitle: title,
                    fieldName: puref,
                    fieldValue: persacc,
                    svgImage: nil
                )
            ],
            amount: 0
        )))) {
            spy.complete(with: .operator(`operator`))
        }
    }
    
    func test_mapScanResult_shouldDeliverMappedProviderOnProvider() {
        
        let (qr, qrMapping) = (anyQR(), anyQRMapping())
        let provider = makeSegmentedProvider()
        let (sut, spy) = makeSUT(qrMapping: qrMapping)
        
        expect(sut, with: .qrCode(qr), delivers: .mapped(.provider(
            .init(provider: provider, qrCode: qr, qrMapping: qrMapping)
        ))) {
            spy.complete(with: .provider(provider))
        }
    }
    
    func test_mapScanResult_shouldDeliverFailureOnQRWithMissingQRMapping() {
        
        let qr = anyQR()
        let (sut, spy) = makeSUT(qrMapping: nil)
        
        expect(sut, with: .qrCode(qr), delivers: .failure(qr), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverC2BURLOnC2BURL() {
        
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .c2bURL(url), delivers: .c2bURL(url), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverC2BSubscribeURLOnC2BSubscribeURL() {
        
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .c2bSubscribeURL(url), delivers: .c2bSubscribeURL(url), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverSberQROnSberQR() {
        
        let sberQR = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .sberQR(sberQR), delivers: .sberQR(sberQR), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverURLOnURL() {
        
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .url(url), delivers: .url(url), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverUnknownOnUnknown() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .unknown, delivers: .unknown, on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRScanResultMapper
    private typealias LoadResult = SUT.MicroServices.LoadResult
    private typealias GetOperatorsSpy = Spy<(QRCode, QRMapping), LoadResult, Never>
    private typealias ScanResult = QRViewModel.ScanResult
    
    private func makeSUT(
        qrMapping: QRMapping? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: GetOperatorsSpy
    ) {
        let spy = GetOperatorsSpy()
        let sut = SUT(
            microServices: .init(
                getMapping: { return qrMapping },
                getOperators: { spy.process(($0, $1), completion: $2) }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyQRMapping(
        parameters: [QRParameter] = [],
        operators: [QROperator] = []
    ) -> QRMapping {
        
        return .init(parameters: parameters, operators: operators)
    }
    
    private func anyQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
    
    private func makeMixed(
        segment: String = anyMessage()
    ) -> QRModelResult.Mapped.MixedOperators {
        
        return .init(
            .operator(makeOperator(
                segment: segment
            )),
            .provider(.init(
                origin: makeProvider(),
                segment: segment
            ))
        )
    }
    
    private func makeOperator(
        code: String = anyMessage(),
        parameterList: [ParameterData] = [],
        parentCode: String = anyMessage(),
        segment: String = anyMessage()
    ) -> SegmentedOperatorData {
        
        return .init(
            origin: .test(
                code: code,
                name: anyMessage(),
                parameterList: parameterList,
                parentCode: parentCode,
                synonymList: [anyMessage()]
            ),
            segment: segment
        )
    }
    
    private var serviceParentCode: String { "iFora||1031001" }
    
    private func makeMultiple(
        segment: String = anyMessage()
    ) -> QRModelResult.Mapped.MultipleOperators {
        
        return .init(makeOperator(segment: segment), makeOperator(segment: segment))
    }
    
    private func makeProvider(
        id: String = anyMessage(),
        icon: String? = anyMessage(),
        inn: String? = anyMessage(),
        title: String = anyMessage(),
        segment: String = anyMessage()
    ) -> UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, segment: segment)
    }
    
    private func makeSegmentedProvider(
        origin: UtilityPaymentProvider? = nil,
        segment: String = anyMessage()
    ) -> SegmentedProvider {
        
        return .init(origin: origin ?? makeProvider(), segment: segment)
    }
    
    private func expect(
        _ sut: SUT,
        with scanResult: ScanResult,
        delivers expectedResult: QRModelResult,
        timeout: TimeInterval = 0.05,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.mapScanResult(scanResult) { receivedResult in
            
            XCTAssertNoDiff(receivedResult, expectedResult, "Expected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

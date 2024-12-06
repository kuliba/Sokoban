//
//  QRNavigationComposer+extTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.10.2024.
//

import CombineSchedulers

extension QRNavigationComposer {
    
    convenience init(
        httpClient: any HTTPClient,
        logger: any LoggerAgentProtocol,
        model: Model,
        createSberQRPayment: @escaping QRNavigationComposerMicroServicesComposer.CreateSberQRPayment,
        getSberQRData: @escaping QRNavigationComposerMicroServicesComposer.GetSberQRData,
        // static RootViewModelFactory.makeSegmentedPaymentProviderPickerFlowModel(httpClient:log:model:pageSize:flag:scheduler:)
        makeSegmented: @escaping QRNavigationComposerMicroServicesComposer.MakeSegmented,
        // static RootViewModelFactory.makeProviderServicePickerFlowModel(httpClient:log:model:pageSize:flag:scheduler:)
        makeServicePicker: @escaping MicroServices.MakeServicePicker,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let composer = QRNavigationComposerMicroServicesComposer(
            httpClient: httpClient,
            logger: logger,
            model: model,
            createSberQRPayment: createSberQRPayment,
            getSberQRData: getSberQRData,
            makeSegmented: makeSegmented,
            makeServicePicker: makeServicePicker,
            scanner: QRScannerViewModelSpy(),
            scheduler: scheduler
        )
        self.init(microServices: composer.compose())
    }
}

@testable import ForaBank
import XCTest

final class QRNavigationComposer_extTests: QRNavigationTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.createSberQRPayment.callCount, 0)
        XCTAssertEqual(spies.getSberQRData.callCount, 0)
        XCTAssertEqual(spies.makeProviderPicker.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - sberQR
    
    func test_makeSberQR_shouldDeliverFailureOnGetSberQRDataFailure() {
        
        let (sut, spies) = makeSUT()
        
        expect(
            sut,
            with: .sberQR(anyURL()),
            assert: {
                
                switch $0 {
                case let .sberQR(.failure(failure)):
                    XCTAssertNoDiff(failure, .init(title: "Ошибка", message: "Возникла техническая ошибка"))
                    
                default:
                    XCTFail("Expected failure, got \($0) instead.")
                }
            },
            on: { spies.getSberQRData.complete(with: anyError()) }
        )
    }
    
    func test_makeSberQR_shouldDeliverSberQROnProductAndGetSberQRDataSuccess() {
        
        let (sut, spies) = makeSUT(product: eligible())
        
        expect(
            sut,
            with: .sberQR(anyURL()),
            assert: {
                
                switch $0 {
                case .sberQR(.success):
                    break
                    
                default:
                    XCTFail("Expected success, got \($0) instead.")
                }
            },
            on: { spies.getSberQRData.complete(with: responseWithFixedAmount()) }
        )
    }
    
    // MARK: - makeServicePicker
    
    func test_makeServicePicker_shouldCallMakeServicePickerWithPayload() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(with: .mapped(.provider(payload)))
        
        XCTAssertNoDiff(spies.makeServicePicker.payloads, [payload])
    }
    
    func test_makeServicePicker_shouldDeliverServicePicker() {
        
        let servicePicker = makeAnywayServicePickerFlowModel()
        let (sut, spies) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(makePaymentProviderServicePickerPayload())),
            assert: {
                
                switch $0 {
                case let .servicePicker(node):
                    XCTAssert(node.model === servicePicker)
                    
                default:
                    XCTFail("Expected servicePicker, got \($0) instead.")
                }
            },
            on: { spies.makeServicePicker.complete(with: servicePicker) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRNavigationComposer
    
    private func makeSUT(
        product: ProductData? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let model: Model = .mockWithEmptyExcept()
        if let product {
            
            model.products.value.append(element: product, toValueOfKey: product.productType)
        }
        let spies = Spies(
            createSberQRPayment: .init(),
            getSberQRData: .init(),
            makeProviderPicker: .init(),
            makeServicePicker: .init()
        )
        let sut = SUT(
            httpClient: HTTPClientSpy(),
            logger: LoggerSpy(),
            model: model,
            createSberQRPayment: spies.createSberQRPayment.process(_:completion:),
            getSberQRData: spies.getSberQRData.process(_:completion:),
            makeSegmented: spies.makeProviderPicker.call,
            makeServicePicker: spies.makeServicePicker.process(_:completion:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.createSberQRPayment, file: file, line: line)
        trackForMemoryLeaks(spies.getSberQRData, file: file, line: line)
        trackForMemoryLeaks(spies.makeProviderPicker, file: file, line: line)
        trackForMemoryLeaks(spies.makeServicePicker, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: QRModelResult,
        assert: @escaping (QRNavigation) -> Void,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            payload: .qrResult(qrResult),
            notify: { _ in },
            completion: {
                
                assert($0)
                exp.fulfill()
            }
        )
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

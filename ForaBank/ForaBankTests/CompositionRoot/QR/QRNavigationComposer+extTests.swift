//
//  QRNavigationComposer+extTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.10.2024.
//

import CombineSchedulers

extension QRNavigationComposer {
    
    convenience init(
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
            logger: logger,
            model: model,
            createSberQRPayment: createSberQRPayment,
            getSberQRData: getSberQRData,
            makeSegmented: makeSegmented,
            makeServicePicker: makeServicePicker,
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
    
    func test_makeSberQR_shouldDeliverFailureOnFailure() {
        
        let (sut, spies) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.compose(
            payload: .qrResult(.sberQR(anyURL())), 
            notify: { _ in },
            completion: {
                
                switch $0 {
                case .sberQR(.failure(.init(title: "Ошибка", message: "Возникла техническая ошибка"))):
                    break
                    
                default:
                    XCTFail("Expected failure, got \($0) instead.")
                }
                
                exp.fulfill()
            }
        )
        
        spies.getSberQRData.complete(with: anyError())
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_makeSberQR_shouldDeliverSberQR() {
        
        let (sut, spies) = makeSUT(product: eligible())
        let exp = expectation(description: "wait for completion")
        
        sut.compose(
            payload: .qrResult(.sberQR(anyURL())), 
            notify: { _ in },
            completion: {
                
                switch $0 {
                case .sberQR(.success):
                    break
                    
                default:
                    XCTFail("Expected success, got \($0) instead.")
                }
                
                exp.fulfill()
            }
        )
        
        spies.getSberQRData.complete(with: responseWithFixedAmount())
        
        wait(for: [exp], timeout: 1)
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
}

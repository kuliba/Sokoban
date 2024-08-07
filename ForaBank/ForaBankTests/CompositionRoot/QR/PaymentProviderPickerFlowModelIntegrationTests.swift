//
//  PaymentProviderPickerFlowModelIntegrationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 04.08.2024.
//

@testable import ForaBank
import ForaTools
import XCTest

final class PaymentProviderPickerFlowModelIntegrationTests: XCTestCase {
    
    func test_init_shouldNotSetDestination() {
        
        let (sut, _,_) = makeSUT()
        
        XCTAssertNil(sut.state.destination)
    }
    
    func test_selectProvider_shouldSetDestination() {
        
        let (sut, _,_) = makeSUT()
        
        sut.select(makeSegmentedProvider())
        
        XCTAssertNotNil(sut.state.destination)
    }
    
    func test_servicePickerShouldDeliverAlertOnResponseFailure() throws {
        
        let (sut, _,_) = makeSUT()
        
        sut.select(makeSegmentedProvider())
        try sut.receive(.failure(.connectivityError))
        
        switch sut.servicePickerModel?.state.status {
        case .alert(.connectivity):
            break
            
        default:
            XCTFail("Expected alert on response failure.")
        }
    }
    
    func test_servicePickerGoToPaymentShouldSetStateToOutsidePayments() throws {
        
        let (sut, _,_) = makeSUT()
        
        sut.select(makeSegmentedProvider())
        sut.servicePickerModel?.event(.goTo(.payments))
        
        switch sut.state.status {
        case .outside(.payments):
            break
            
        default:
            XCTFail("Expected outside payments state.")
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowModel
    
    private func makeSUT(
        mix: MultiElementArray<SegmentedOperatorProvider>? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping = .init(parameters: [], operators: []),
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag = .init(.active(.stub)),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let httpClient = HTTPClientSpy()
        let make = RootViewModelFactory.makePaymentProviderPickerFlowModel(
            httpClient: httpClient,
            log: { _,_,_,_,_ in },
            model: model,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: .immediate
        )
        let mix = mix ?? .init(.provider(makeSegmentedProvider()), .provider(makeSegmentedProvider()))
        let sut = make(mix, qrCode ?? anyQR(), qrMapping)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, httpClient, model)
    }
    
    private func makeTwoProviders() -> (SegmentedProvider, SegmentedProvider) {
        
        return (makeSegmentedProvider(), makeSegmentedProvider())
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
    
    private func anyQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
}

// MARK: - DSL

private extension PaymentProviderPickerFlowModel {
    
    var servicePickerModel: AnywayServicePickerFlowModel? {
        
        guard case let .servicePicker(node) = state.destination
        else { return nil }
        
        return node.model
    }
    
    func select(_ provider: SegmentedProvider) {
        
        self.event(.select(.provider(provider)))
    }
    
    func load(
        services: [UtilityService],
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let servicePickerModel = try XCTUnwrap(servicePickerModel, "Expected to have service picker.", file: file, line: line)
        servicePickerModel.state.content.event(.loaded(services))
    }
    
    func receive(
        _ response: PaymentProviderServicePickerResult,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let servicePickerModel = try XCTUnwrap(servicePickerModel, "Expected to have service picker.", file: file, line: line)
        servicePickerModel.state.content.event(.response(response))
    }
}

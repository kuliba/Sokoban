//
//  MainViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.09.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class MainViewModelTests: XCTestCase {
    
    func test_tapTemplates_shouldSetLinkToTemplates() {
        
        let (sut, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.fastPayment?.tapTemplatesAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapTemplates_shouldNotSetLinkToNilOnTemplatesCloseUntilDelay() {
        
        let (sut, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        sut.fastPayment?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapTemplates_shouldSetLinkToNilOnTemplatesClose() {
        
        let (sut, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        sut.fastPayment?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait(timeout: 0.9)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates, nil])
    }
    
    func test_tapUserAccount_shouldSendGetSubscriptionRequest() {
        
        let (sut, model) = makeModelWithServerAgentStub(
            getC2bResponseStub: getC2bResponseStub()
        )
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.C2B.GetC2BSubscription.Request })
        XCTAssertNoDiff(spy.values.count, 0)
        XCTAssertNoDiff(model.subscriptions.value, nil)
        
        sut.tapUserAccount()
        
        XCTAssertNoDiff(spy.values.count, 1)
        XCTAssertNoDiff(
            model.subscriptions.value,
            .init(
                title: "title",
                subscriptionType: .control,
                emptySearch: nil,
                emptyList: nil,
                list: nil
            )
        )
    }
    
    // MARK: SBER QR
    
    func test_sberQR_shouldPresentErrorAlertOnGetSberQRDataInvalidFailure() throws {
        
        let (sut, _, _) = makeSUT(getSberQRDataResultStub: .failure(
            .invalid(statusCode: 200, data: anyData())
        ))
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
        
        try sut.scanAndWait()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            "Возникла техническая ошибка"
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnGetSberQRDataInvalidFailure() throws {
        
        let (sut, _, _) = makeSUT(getSberQRDataResultStub: .failure(
            .invalid(statusCode: 200, data: anyData())
        ))
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        
        try sut.scanAndWait()
        try sut.tapPrimaryAlertButton()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            "Возникла техническая ошибка",
            nil
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertOnGetSberQRDataServerFailure() throws {
        
        let (sut, _, _) = makeSUT(getSberQRDataResultStub: .failure(
            .server(statusCode: 200, errorMessage: UUID().uuidString)
        ))
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
        
        try sut.scanAndWait()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            "Возникла техническая ошибка"
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnGetSberQRDataServerFailure() throws {
        
        let (sut, _, _) = makeSUT(getSberQRDataResultStub: .failure(
            .server(statusCode: 200, errorMessage: UUID().uuidString)
        ))
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        
        try sut.scanAndWait()
        try sut.tapPrimaryAlertButton()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            "Возникла техническая ошибка",
            nil
        ])
    }
    
    func test_sberQR_shouldNotSetAlertOnSuccess() throws {
        
        let (sut, _, _) = makeSUT()
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        
        try sut.scanAndWait()
        
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
    }
    
    func test_sberQR_shouldNavigateToSberQRPaymentWithURLAndData() throws {
        
        let sberQRURL = anyURL()
        let sberQRData = anyGetSberQRDataResponse()
        let (sut, _, _) = makeSUT(
            getSberQRDataResultStub: .success(sberQRData)
        )
        let navigationSpy = ValueSpy(sut.$link.map(\.?.case))
        XCTAssertNoDiff(navigationSpy.values, [nil])
        
        try sut.scanAndWait(sberQRURL)
        
        XCTAssertNoDiff(navigationSpy.values, [
            nil,
            .sberQRPayment(sberQRURL, sberQRData)
        ])
    }
    
    func test_sberQR_shouldResetNavigationLinkOnSberQRPaymentFailure() throws {
        
        let sberQRURL = anyURL()
        let sberQRData = anyGetSberQRDataResponse()
        let sberQRError = anyError("SberQRPayment Failure")
        let (sut, _, spy) = makeSUT(
            getSberQRDataResultStub: .success(sberQRData)
        )
        let navigationSpy = ValueSpy(sut.$link.map(\.?.case))
        
        try sut.scanAndWait(sberQRURL)
        spy.complete(with: .failure(sberQRError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(navigationSpy.values, [
            nil,
            .sberQRPayment(sberQRURL, sberQRData),
            nil
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertOnSberQRPaymentFailure() throws {
        
        let sberQRError = anyError("SberQRPayment Failure")
        let (sut, _, spy) = makeSUT()
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        
        try sut.scanAndWait(anyURL())
        spy.complete(with: .failure(sberQRError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            "Возникла техническая ошибка"
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnSberQRPaymentFailure() throws {
        
        let sberQRError = anyError("SberQRPayment Failure")
        let (sut, _, spy) = makeSUT()
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        
        try sut.scanAndWait(anyURL())
        spy.complete(with: .failure(sberQRError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        try sut.tapPrimaryAlertButton()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            "Возникла техническая ошибка",
            nil
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        getSberQRDataResultStub: GetSberQRDataResult = .emptySuccess,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model,
        spy: SberQRPaymentSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let spy = SberQRPaymentSpy()
        let sut = MainViewModel(
            model,
            makeProductProfileViewModel: { _,_,_  in nil },
            makeQRScannerModel: {
                
                .init(
                    closeAction: $0,
                    qrResolver: QRViewModel.ScanResult.init
                )
            },
            getSberQRData: { _, completion in
                
                completion(getSberQRDataResultStub)
            },
            makeSberQRPaymentViewModel: spy.make,
            onRegister: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, model, spy)
    }
    
    private func makeModelWithServerAgentStub(
        getC2bResponseStub: [ServerAgentTestStub.Stub],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = ServerAgentTestStub(getC2bResponseStub)
        
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent
        )
        model.clientInfo.value = makeClientInfoDummy()
        
        let sut = MainViewModel(
            model,
            makeProductProfileViewModel: { _,_,_  in nil },
            makeQRScannerModel: {
                
                .init(
                    closeAction: $0,
                    qrResolver: QRViewModel.ScanResult.init
                )
            },
            getSberQRData: { _,_ in },
            makeSberQRPaymentViewModel: SberQRPaymentViewModel.init,
            onRegister: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func getC2bResponseStub() -> [ServerAgentTestStub.Stub] {
        
        [
            .getC2bSubscriptions(.success(.init(
                statusCode: .ok,
                errorMessage: nil,
                data: .init(
                    title: "title",
                    subscriptionType: .control,
                    emptySearch: nil,
                    emptyList: nil,
                    list: nil
                ))
            ))
        ]
    }
    
    private func makeClientInfoDummy() -> ClientInfoData {
        
        .init(
            id: 1,
            lastName: "lastName",
            firstName: "firstName",
            patronymic: "patronymic",
            birthDay: "birthDay",
            regSeries: "regSeries",
            regNumber: "regNumber",
            birthPlace: "birthPlace",
            dateOfIssue: "dateOfIssue",
            codeDepartment: "codeDepartment",
            regDepartment: "regDepartment",
            address: "address",
            addressInfo: nil,
            addressResidential: "addressResidential",
            addressResidentialInfo: nil,
            phone: "phone",
            phoneSMS: "phoneSMS",
            email: "email",
            inn: "inn",
            customName: "customName"
        )
    }
}

// MARK: - DSL

private extension MainViewModel {
    
    var fastPayment: MainSectionFastOperationView.ViewModel? {
        
        sections.compactMap {
            
            $0 as? MainSectionFastOperationView.ViewModel
        }
        .first
    }
    
    var templatesListViewModel: TemplatesListViewModel? {
        
        switch link {
        case let .templates(templatesListViewModel):
            return templatesListViewModel
            
        default:
            return nil
        }
    }
    
    var qrScanner: QRViewModel? {
        
        guard case let .qrScanner(qrScanner) = fullScreenSheet?.type
        else { return nil }
        
        return qrScanner
    }
}

private extension MainViewModel.Link {
    
    var `case`: Case? {
        
        switch self {
        case .templates:
            return .templates
            
        case let .sberQRPayment(sberQRPayment):
            return .sberQRPayment(
                sberQRPayment.sberQRURL,
                sberQRPayment.sberQRData
            )
            
        default:
            return .other
        }
    }
    
    enum Case: Equatable {
        
        case templates
        case sberQRPayment(URL, GetSberQRDataResponse)
        case other
    }
}

private extension MainSectionFastOperationView.ViewModel {
    
    func tapTemplatesAndWait(timeout: TimeInterval = 0.05) {
        
        let templatesAction = MainSectionViewModelAction.FastPayment.ButtonTapped.init(operationType: .templates)
        action.send(templatesAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func tapOpenScanner(timeout: TimeInterval = 0.05) {
        
        let openScannerAction = MainSectionViewModelAction.FastPayment.ButtonTapped.init(operationType: .byQr)
        action.send(openScannerAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension TemplatesListViewModel {
    
    func closeAndWait(timeout: TimeInterval = 0.05) {
        
        action.send(TemplatesListViewModelAction.CloseAction())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainViewModel {
    
    func tapPrimaryAlertButton(
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let alert = try XCTUnwrap(alert, "Expected to have alert but got nil.", file: file, line: line)
        alert.primary.action()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func tapUserAccount(timeout: TimeInterval = 0.05) {
        
        action.send(MainViewModelAction.ButtonTapped.UserAccount())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func scanAndWait(
        _ url: URL = anyURL(),
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let fastPayment = try XCTUnwrap(fastPayment, "Expected to have a fast payment section.", file: file, line: line)
        fastPayment.tapOpenScanner()
        
        let qrScanner = try XCTUnwrap(qrScanner, "Expected to have a QR Scanner but got nil.", file: file, line: line)
        let result = QRViewModelAction.Result(result: .sberQR(url))
        qrScanner.action.send(result)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

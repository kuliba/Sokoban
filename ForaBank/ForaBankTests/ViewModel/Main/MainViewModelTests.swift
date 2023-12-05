//
//  MainViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.09.2023.
//

@testable import ForaBank
import XCTest

final class MainViewModelTests: XCTestCase {
    
    func test_tapTemplates_shouldSetLinkToTemplates() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.fastPayment?.tapTemplatesAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapTemplates_shouldNotSetLinkToNilOnTemplatesCloseUntilDelay() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        sut.fastPayment?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapTemplates_shouldSetLinkToNilOnTemplatesClose() {
        
        let (sut, _) = makeSUT()
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
    
    func test_sberQR_shouldPresentErrorAlertOnGetSberQRDataFailure() throws {
        
        let (sut, _) = makeSUT(
            getSberQRDataResultStub: .failure(anyError())
        )
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
        
        try sut.scanAndWait()
                
        XCTAssertNoDiff(alertMessageSpy.values, [nil, "Возникла техническая ошибка"])
    }

    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnGetSberQRDataFailure() throws {
        
        let (sut, _) = makeSUT(
            getSberQRDataResultStub: .failure(anyError())
        )
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        
        try sut.scanAndWait()
        try sut.tapPrimaryAlertButton()
                
        XCTAssertNoDiff(alertMessageSpy.values, [nil, "Возникла техническая ошибка", nil])
    }

    func test_sberQR_should() throws {
        
        let (sut, _) = makeSUT(
//            getSberQRDataResultStub: .failure(anyError())
        )
        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
        
        try sut.scanAndWait()
                
        XCTAssertNoDiff(alertMessageSpy.values, [nil, "Возникла техническая ошибка"])
    }

    // MARK: - Helpers
    
    private func makeSUT(
        getSberQRDataResultStub: Result<Data, Error> = .success(.empty),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
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
            onRegister: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
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
        case .templates: return .templates
        default:         return .other
        }
    }
    
    enum Case: Equatable {
        
        case templates
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
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let fastPayment = try XCTUnwrap(fastPayment, "Expected to have a fast payment section.", file: file, line: line)
        fastPayment.tapOpenScanner()
        
        let qrScanner = try XCTUnwrap(qrScanner, "Expected to have a QR Scanner but got nil.", file: file, line: line)
        let result = QRViewModelAction.Result(result: .sberQR(anyURL()))
        qrScanner.action.send(result)

        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

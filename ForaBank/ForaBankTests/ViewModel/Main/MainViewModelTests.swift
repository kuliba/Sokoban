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
    
    typealias mainSectionVMAction = MainSectionViewModelAction.Products
    
    func test_productCarouselStickerDidTapped()  {
        
        let (sut, _) = makeSUTWithMainSectionProcutsViewVM()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        let sutActionSpy = ValueSpy(
            sut.productCarouselViewModel.action.compactMap { $0 as? ProductCarouselViewModelAction.Products.StickerDidTapped })
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(sutActionSpy.values.count, 0)
        
        sut.productCarouselViewModel.action.send(ProductCarouselViewModelAction.Products.StickerDidTapped())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(sutActionSpy.values.count, 1)
       
        XCTAssertNotNil(sutActionSpy.values.first)
    }
 
    func test_orderSticker_showsAlert_whenNoCards() {
        
        let localAgentDataStubClear: [String: Data] = [
            "Array<OperatorGroupData>": .init(),
        ]
        let localAgent = LocalAgentStub(stub: localAgentDataStubClear)
        let model = Model.mockWithEmptyExcept(
          localAgent: localAgent
        )
        
        let sut = MainViewModel(model, makeProductProfileViewModel: { _,_,_  in nil }, onRegister: {})
     
      sut.orderSticker()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
      XCTAssertNotNil(sut.alert)
    }
    
    // MARK: - Helpers
  
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = MainViewModel(model, makeProductProfileViewModel: { _,_,_  in nil }, onRegister: {})
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    typealias MainSectionViewVM = MainSectionProductsView.ViewModel
    typealias StickerViewModel = ProductCarouselView.StickerViewModel
    
    private func makeSUTWithMainSectionProcutsViewVM(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainSectionViewVM,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = MainSectionViewVM(model, stickerViewModel: nil)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
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
        
        let sut = MainViewModel(model, makeProductProfileViewModel: { _,_,_  in nil }, onRegister: {})
        
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
    
    var openProductSection: MainSectionOpenProductView.ViewModel? {
        
        sections.compactMap {
            
            $0 as? MainSectionOpenProductView.ViewModel
        }
        .first
    }
    
    var authProductsViewModel: AuthProductsViewModel? {
        
        switch link {
        case let .openCard(authProductsViewModel):
            return authProductsViewModel
            
        default:
            return nil
        }
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
}

private extension TemplatesListViewModel {
    
    func closeAndWait(timeout: TimeInterval = 0.05) {
        
        action.send(TemplatesListViewModelAction.CloseAction())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainViewModel {
    
    func tapUserAccount(timeout: TimeInterval = 0.05) {
        
        action.send(MainViewModelAction.ButtonTapped.UserAccount())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainViewModel {
    
    func closeAndWait(timeout: TimeInterval = 0.05) {
        
        action.send(MainViewModelAction.Close.Link())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionOpenProductView.ViewModel {
    
    func tapStickerAndWait(timeout: TimeInterval = 0.05) {
        let stickerAction = MainSectionViewModelAction.Products.StickerDidTapped()
        action.send(stickerAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainViewModel {
    
    func showStickerAndWait(timeout: TimeInterval = 0.05) {
        
        let stickerAction = MainSectionViewModelAction.Products.StickerDidTapped()
        action.send(stickerAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension ProductCardData {
    
    convenience init(id: Int, currency: Currency, ownerId: Int = 0, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active, loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil, statusPc: ProductData.StatusPC = .active, isMain: Bool = true) {
        
        self.init(id: id, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: ownerId, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: status, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: loanBaseParam, statusPc: statusPc, isMain: isMain, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

private extension MainViewModelTests {
    
    static let cardActiveMainDebitOnlyMain = ProductCardData(id: 11, currency: .rub, allowCredit: false)
    static let cardBlockedMainRub = ProductCardData(id: 12, currency: .rub, status: .blocked, statusPc: .blockedByBank)
    
    static let cardActiveAddUsdIsMainFalse = ProductCardData(id: 22, currency: .usd, isMain: false)
    static let cardActiveAddUsdIsMainTrue = ProductCardData(id: 21, currency: .usd)
}

private extension MainViewModelTests {
    
    static let cardProducts = [cardActiveAddUsdIsMainFalse,
                               cardActiveAddUsdIsMainTrue]
}

extension MainSectionViewModelAction.Products.StickerDidTapped: Equatable {
    public static func == (lhs: MainSectionViewModelAction.Products.StickerDidTapped, rhs: MainSectionViewModelAction.Products.StickerDidTapped) -> Bool { return true }
}

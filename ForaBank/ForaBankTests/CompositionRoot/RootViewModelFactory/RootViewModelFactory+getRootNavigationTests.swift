//
//  RootViewModelFactory+getRootNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.11.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_getRootNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - outside
    
    func test_outside_productProfile_shouldDeliverOutsideProductProfile() {
        
        let productID = makeProductID()
        
        expect(.outside(.productProfile(productID)), toDeliver: .outside(.productProfile(productID)))
    }
    
    func test_outside_tab_main_shouldDeliverOutsideTabMain() {
        
        expect(.outside(.tab(.main)), toDeliver: .outside(.tab(.main)))
    }
    
    func test_outside_tab_payments_shouldDeliverOutsideTabPayments() {
        
        expect(.outside(.tab(.payments)), toDeliver: .outside(.tab(.payments)))
    }
    
    // MARK: - scanQR
    
    func test_scanQR_shouldDeliverQRScanner() {
        
        expect(.scanQR, toDeliver: .scanQR)
    }
    
    func test_scanQR_shouldNotifyWithDismissOnCancel() {
        
        expect(.scanQR, toNotifyWith: [.dismiss]) {
            
            $0.scanQR?.event(.cancel)
        }
    }
    
    // MARK: - templates
    
    func test_templates_shouldDeliverTemplates() {
        
        expect(.templates, toDeliver: .templates)
    }
    
    func test_templates_shouldNotifyWithDismissOnDismissAction() {
        
        expect(.templates, toNotifyWith: [.dismiss]) {
            
            $0.templates?.state.content.dismissAction()
        }
    }
    
    func test_templates_shouldNotifyWithMainTabOnMainTabStatus() {
        
        expect(.templates, toNotifyWith: [.select(.outside(.tab(.main)))]) {
            
            $0.templates?.event(.flow(.init(status: .tab(.main))))
        }
    }
    
    func test_templates_shouldNotifyWithPaymentsTabOnPaymentsTabStatus() {
        
        expect(
            .templates,
            toNotifyWith: [.select(.outside(.tab(.payments)))]
        ) {
            $0.templates?.event(.flow(.init(status: .tab(.payments))))
        }
    }
    
    func test_templates_shouldNotifyWithProductIDOnProductIDStatus() {
        
        let productID = makeProductID()
        
        expect(
            .templates,
            toNotifyWith: [.select(.outside(.productProfile(productID)))]
        ) {
            $0.templates?.event(.select(.productID(productID)))
        }
    }
    
    // MARK: - userAccount
    
    func test_userAccount_shouldDeliverFailureOnMissingClientInfo() {
        
        let model: Model = .mockWithEmptyExcept()
        model.clientInfo.value = nil
        let sut = makeSUT(model: model).sut
        
        expect(sut: sut, .userAccount, toDeliver: .failure(.makeUserAccountFailure))
    }
    
    func test_userAccount_shouldDeliverUserAccountOnExistingClientInfo() {
        
        let model: Model = .mockWithEmptyExcept()
        model.clientInfo.value = makeClientInfoData()
        let sut = makeSUT(model: model).sut
        
        expect(sut: sut, .userAccount, toDeliver: .userAccount)
    }
    
    func test_userAccount_shouldNotifyWithDismissOnClose() {
        
        let model: Model = .mockWithEmptyExcept()
        model.clientInfo.value = makeClientInfoData()
        let sut = makeSUT(model: model).sut
        
        expect(sut: sut, .userAccount, toNotifyWith: [.dismiss]) {
            
            $0.userAccount?.close()
        }
    }
    
    // MARK: - standardPayment
    
    func test_utilityPayment_shouldDeliverFailureOnMissingCategory() {
        
        expect(.standardPayment(.charity), toDeliver: .failure(.missingCategoryOfType(.housingAndCommunalService)))
    }
    
    func test_utilityPayment_shouldDeliverFailureOnFailure() throws {
        
        let (sut, httpClient, _) = try makeSUT(
            model: .withServiceCategoryAndOperator(ofType: .charity)
        )
        
        expect(sut: sut, .standardPayment(.charity), toDeliver: .standardPayment) {
            
            completeGetAllLatestPayments(httpClient)
        }
    }
    
    // MARK: - Helpers
    
    private typealias NotifyEvent = RootViewDomain.FlowDomain.NotifyEvent
    private typealias NotifySpy = CallSpy<NotifyEvent, Void>
    
    private func makeProductID() -> ProductData.ID {
        
        return .random(in: 0..<Int.max)
    }
    
    private func completeGetAllLatestPayments(
        _ httpClient: HTTPClientSpy,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(httpClient.requests.map(\.url?.lastPathComponent), [
            "getAllLatestPayments"
        ], file: file, line: line)
        httpClient.complete(with: anyError(), at: 0)
    }
    
    private func equatable(
        _ navigation: RootViewNavigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .failure(failure):
            return .failure(failure)
            
        case let .outside(outside):
            return .outside(outside)
            
        case .scanQR:
            return .scanQR
            
        case .standardPayment:
            return .standardPayment
            
        case .templates:
            return .templates
            
        case .userAccount:
            return .userAccount
        }
    }
    
    private enum EquatableNavigation: Equatable {
        
        case failure(RootViewNavigation.Failure)
        case outside(RootViewOutside)
        case scanQR
        case standardPayment
        case templates
        case userAccount
    }
    
    private func expect(
        sut: SUT? = nil,
        _ select: RootViewSelect,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let exp = expectation(description: "wait for completion")
        
        sut.getRootNavigation(
            select: select,
            notify: { _ in }
        ) {
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        sut: SUT? = nil,
        _ select: RootViewSelect,
        toNotifyWith expectedNotifyEvents: [NotifyEvent],
        on assert: @escaping (RootViewNavigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let notifySpy = NotifySpy(stubs: [()])
        let exp = expectation(description: "wait for completion")
        
        sut.getRootNavigation(
            select: select,
            notify: notifySpy.call
        ) {
            assert($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, expectedNotifyEvents, "Expected \(expectedNotifyEvents), but got \(notifySpy.payloads) instead.", file: file, line: line)
    }
}

// MARK: - Helpers

extension XCTestCase {
    
    func makeClientInfoData(
        id: Int = .random(in: 1...1_000),
        lastName: String = anyMessage(),
        firstName: String = anyMessage(),
        patronymic: String? = nil,
        birthDay: String? = nil,
        regSeries: String? = nil,
        regNumber: String = anyMessage(),
        birthPlace: String? = nil,
        dateOfIssue: String? = nil,
        codeDepartment: String? = nil,
        regDepartment: String? = nil,
        address: String = anyMessage(),
        addressInfo: ClientInfoData.AddressInfo? = nil,
        addressResidential: String? = nil,
        addressResidentialInfo: ClientInfoData.AddressInfo? = nil,
        phone: String = anyMessage(),
        phoneSMS: String? = nil,
        email: String? = nil,
        inn: String? = nil,
        customName: String? = nil
    ) -> ClientInfoData {
        
        
        return .init(
            id: id,
            lastName: lastName,
            firstName: firstName,
            patronymic: patronymic,
            birthDay: birthDay,
            regSeries: regSeries,
            regNumber: regNumber,
            birthPlace: birthPlace,
            dateOfIssue: dateOfIssue,
            codeDepartment: codeDepartment,
            regDepartment: regDepartment,
            address: address,
            addressInfo: addressInfo,
            addressResidential: addressResidential,
            addressResidentialInfo: addressResidentialInfo,
            phone: phone,
            phoneSMS: phoneSMS,
            email: email,
            inn: inn,
            customName: customName
        )
    }
}

// MARK: - DSL

extension RootViewNavigation {
    
    var scanQR: QRScannerModel? {
        
        guard case let .scanQR(node) = self else { return nil }
        return node.model.content
    }
    
    var templates: TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>? {
        
        guard case let .templates(node) = self else { return nil }
        return node.model
    }
    
    var userAccount: UserAccountViewModel? {
        
        guard case let .userAccount(userAccount) = self else { return nil }
        return userAccount
    }
}

extension Model {
    
    static func withServiceCategoryAndOperator(
        ofType categoryType: CodableServiceCategory.CategoryType = .housingAndCommunalService,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let categories = [makeCodableServiceCategory(type: categoryType)]
        let operators = [makeCodableServicePaymentOperator(type: categoryType)]
        
        let encoder = JSONEncoder()
        
        let categoriesData = try encoder.encode(categories)
        let operatorsData = try encoder.encode(operators)
        
        let localAgent = LocalAgentStub(stub: [
            "\(type(of: categories).self)" : categoriesData,
            "\(type(of: operators).self)" : operatorsData
        ])
        
        XCTAssertNotNil(localAgent.load(type: [CodableServiceCategory].self)?.first(where: { $0.type == categoryType }), file: file, line: line)
        XCTAssertNotNil(localAgent.load(type: [CodableServicePaymentOperator].self)?.first(where: { $0.type == categoryTypeName(of: categoryType) }), file: file, line: line)
        
        return .mockWithEmptyExcept(localAgent: localAgent)
    }
    
    private static func makeCodableServicePaymentOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = nil,
        name: String = anyMessage(),
        type: CodableServiceCategory.CategoryType = .housingAndCommunalService,
        sortedOrder: Int = .random(in: 0..<1_000)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: categoryTypeName(of: type), sortedOrder: sortedOrder)
    }
    
    private static func categoryTypeName(
        of type: CodableServiceCategory.CategoryType
    ) -> String {
        
        switch type {
        case .housingAndCommunalService:
            return "housingAndCommunalService"
            
        default:
            return unimplemented()
        }
    }
    
    private static func makeCodableServiceCategory(
        latestPaymentsCategory: CodableServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 0..<1_000),
        paymentFlow: CodableServiceCategory.PaymentFlow = .standard,
        hasSearch: Bool = false,
        type: CodableServiceCategory.CategoryType = .housingAndCommunalService
    ) -> CodableServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}

extension UserAccountViewModel {
    
    func close() {
        
        navigationBar.backButton?.action()
    }
}

extension NavigationBarView.ViewModel {
    
    var backButton: NavigationBarView.ViewModel.BackButtonItemViewModel? {
        
        leftItems
            .compactMap(\.asBackButton)
            .first
    }
}

private extension NavigationBarView.ViewModel.ItemViewModel {
    
    var asBackButton: NavigationBarView.ViewModel.BackButtonItemViewModel? {
        
        self as? NavigationBarView.ViewModel.BackButtonItemViewModel
    }
}

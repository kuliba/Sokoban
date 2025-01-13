//
//  RootViewModelFactory+getRootNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 26.11.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getRootNavigationTests: RootViewModelFactoryTests {
          
    // MARK: - outside
    
    func test_outside_productProfile_shouldDeliverOutsideProductProfile() {
        
        let product = anyProduct(id: .random(in: 1...9), productType: .card)
        
        expect(.outside(.productProfile(product.id)), product, toDeliver: .outside(.productProfile(product.id)))
    }
    
    func test_outside_productProfile_shouldDeliverFailureOnMissingProduct() {
         
        let product = anyProduct(id: .random(in: 1...9), productType: .card)

        expect(.outside(.productProfile(product.id)), toDeliver: .failure(.makeProductProfileFailure(product.id)))
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
    
    func test_standardPayment_shouldDeliverFailureOnMissingCategory() {
        
        for type in categoryTypes {
            
            expect(.standardPayment(type), toDeliver: .failure(.missingCategoryOfType(type)))
        }
    }
    
    func test_standardPayment_shouldDeliverStandardPayment() throws {
        
        for type in categoryTypes {
            
            let (sut, httpClient, _) = try makeSUT(
                model: .withServiceCategoryAndOperator(ofType: type)
            )
            
            expect(sut: sut, .standardPayment(type), toDeliver: .standardPayment) {
                
                completeGetAllLatestPayments(httpClient)
            }
        }
    }
    
    // TODO: - fix delay await
//    func test_standardPayment_shouldNotifyWithScanQROnQR() throws {
//        
//        let (sut, httpClient, _) = try makeSUT(
//            model: .withServiceCategoryAndOperator(ofType: .internet)
//        )
//        
//        expect(
//            sut: sut,
//            .standardPayment(.internet),
//            toNotifyWith: [.select(.scanQR)],
//            on: { $0.standardPaymentFlow?.event(.select(.outside(.qr))) }
//        ) {
//            httpClient.complete(with: anyError())
//        }
//    }
    
    // MARK: - Helpers
    
    private typealias NotifyEvent = RootViewDomain.FlowDomain.NotifyEvent
    private typealias NotifySpy = CallSpy<NotifyEvent, Void>
    
    private func makeProductID() -> ProductData.ID {
        
        return .random(in: 0..<Int.max)
    }
    
    private let categoryTypes = ["charity", "digitalWallets", "education", "housingAndCommunalService", "internet", "mobile", "networkMarketing", "qr", "repaymentLoansAndAccounts", "security", "socialAndGames", "taxAndStateService", "transport"]
    
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
            switch failure {
            case let .makeStandardPaymentFailure(binder):
                return .failure(.makeStandardPaymentFailure(.init(binder)))
                
            case .makeUserAccountFailure:
                return .failure(.makeUserAccountFailure)
                
            case let .missingCategoryOfType(type):
                return .failure(.missingCategoryOfType(type))
                
            case let .makeProductProfileFailure(productID):
                return .failure(.makeProductProfileFailure(productID))
            }
            
        case let .outside(outside):
            switch outside {
            case let .productProfile(profile):
                return .outside(.productProfile(profile.product.activeProductId))
                
            case let .tab(tab):
                return .outside(.tab(tab))
            }
            
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
        
        case failure(Failure)
        case outside(EquatableRootViewOutside)
        case scanQR
        case standardPayment
        case templates
        case userAccount
        
        enum Failure: Equatable {
            
            case makeProductProfileFailure(ProductData.ID)
            case makeStandardPaymentFailure(ObjectIdentifier)
            case makeUserAccountFailure
            case missingCategoryOfType(ServiceCategory.CategoryType)
        }
        
        enum EquatableRootViewOutside: Equatable {
            
            case productProfile(ProductData.ID)
            case tab(RootViewTab)
        }
    }
    
    private func expect(
        sut: SUT? = nil,
        _ select: RootViewSelect,
        _ product: ProductData? = nil,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let model: Model = {
            let model = Model.mockWithEmptyExcept()
            
            guard let product else { return model }
            
            model.products.value[.card] = [product]
            
            return model
        }()
        
        let sut = sut ?? makeSUT(model: model, file: file, line: line).sut
        let exp = expectation(description: "wait for completion")
        
        sut.getRootNavigation(
            makeProductProfileByID: { productID,_  in
                return makeProductProfileViewModel(productID, model)
            },
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
        action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let notifySpy = NotifySpy(stubs: [()])
        let exp = expectation(description: "wait for completion")
        
        sut.getRootNavigation(
            makeProductProfileByID: {_,_  in nil },
            select: select,
            notify: notifySpy.call
        ) {
            assert($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, expectedNotifyEvents, "Expected \(expectedNotifyEvents), but got \(notifySpy.payloads) instead.", file: file, line: line)
    }
    
    private func makeProductProfileViewModel(
        _ productID: ProductData.ID,
        _ model: Model
    ) -> ProductProfileViewModel? {
           
        guard let product: ProductProfileCardView.ViewModel = .init(model, productData: .stub(productId: productID)) else { return nil }
        
        return ProductProfileViewModel(
            navigationBar: NavigationBarView.ViewModel.sampleNoActionButton,
            product: product,
            buttons: .sample,
            detail: .sample,
            history: nil,
            fastPaymentsFactory: .legacy,
            makePaymentsTransfersFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            productProfileServices: .preview,
            qrViewModelFactory: .preview(),
            paymentsTransfersFactory: .preview,
            operationDetailFactory: .preview,
            productNavigationStateManager: .preview,
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            filterHistoryRequest: { _,_,_,_ in },
            makeOpenNewProductButtons: { _ in [] },
            productProfileViewModelFactory: .preview,
            filterState: .preview,
            rootView: ""
        )
    }
}

// MARK: - DSL

extension RootViewNavigation {
    
    var scanQR: QRScannerModel? {
        
        guard case let .scanQR(node) = self else { return nil }
        return node.model.content
    }
    
    var standardPaymentFlow: PaymentProviderPickerDomain.Flow? {
        
        guard case let .standardPayment(node) = self else { return nil }
        return node.model.flow
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

extension Model {
    
    static func withServiceCategoryAndOperator(
        ofType categoryType: CodableServiceCategory.CategoryType = "housingAndCommunalService",
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
        XCTAssertNotNil(localAgent.load(type: [CodableServicePaymentOperator].self)?.first(where: { $0.type == categoryType }), file: file, line: line)
        
        return .mockWithEmptyExcept(localAgent: localAgent)
    }
    
    private static func makeCodableServicePaymentOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = nil,
        name: String = anyMessage(),
        type: CodableServiceCategory.CategoryType = "housingAndCommunalService",
        sortedOrder: Int = .random(in: 0..<1_000)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type, sortedOrder: sortedOrder)
    }
        
    private static func makeCodableServiceCategory(
        latestPaymentsCategory: CodableServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 0..<1_000),
        paymentFlow: CodableServiceCategory.PaymentFlow = .standard,
        hasSearch: Bool = false,
        type: CodableServiceCategory.CategoryType = "housingAndCommunalService"
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

extension String {
    
    static let charity                    = "charity"
    static let digitalWallets             = "digitalWallets"
    static let education                  = "education"
    static let networkMarketing           = "networkMarketing"
    static let qr                         = "qr"
    static let repaymentLoansAndAccounts  = "repaymentLoansAndAccounts"
    static let security                   = "security"
    static let socialAndGames             = "socialAndGames"
    static let taxAndStateService         = "taxAndStateService"
}

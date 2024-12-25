//
//  RootViewModelFactory+getPaymentsNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService
@testable import Vortex
import XCTest

final class RootViewModelFactory_getPaymentsNavigationTests: GetInfoRepeatPaymentTests {
    
    // MARK: - meToMe
    
    func test_shouldDeliverNilOnNilAmount() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(
            amount: nil,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: nil)
    }
    
    func test_shouldDeliverNilOnEmptyParameterList() throws {
        
        let productID = makeProductID()
        let info = makeBetweenTheir(parameterList: [])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: nil)
    }
    
    func test_shouldDeliverNilOnExternalPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payeeExternal: makeExternalPayer())
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: nil)
    }
    
    func test_shouldDeliverMeToMeOnPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID, productType: .card, currency: "RUB")
        let transfer = makeTransfer(payer: makePayer(cardId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(product: product)
        
        assert(model: model, product: product, with: info, delivers: .meToMe)
    }
    
    func test_shouldDeliverMeToMeOnInternalPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID, productType: .account, currency: "RUB")
        let transfer = makeTransfer(payeeInternal: makeInternalPayer(accountId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(product: product)
        
        assert(model: model, product: product, with: info, delivers: .meToMe)
    }
    
    // MARK: - direct, contactAddressless
    
    func test_shouldCallMakePaymentsWithDirectSourceOnDirect() throws {
        
        let (phone, country) = (makePhone(), makeCountryID())
        let transfer = makeTransfer(additional: [phone, country])
        let info = makeDirect(parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try assertDirect(
            source,
            phone: phone.fieldvalue,
            country: country.fieldvalue,
            additional: [
                .init(fieldTitle: phone.fieldname, fieldName: phone.fieldname, fieldValue: phone.fieldvalue, svgImage: ""),
                .init(fieldTitle: country.fieldname, fieldName: country.fieldname, fieldValue: country.fieldvalue, svgImage: ""),
            ],
            amount: XCTUnwrap(transfer.amount),
            puref: ""
        )
    }
    
    func test_shouldCallMakePaymentsWithDirectSourceOnContactAddressless() throws {
        
        let (phone, country) = (makePhone(), makeCountryID())
        let transfer = makeTransfer(additional: [phone, country])
        let info = makeAddressless(parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try assertDirect(
            source,
            phone: phone.fieldvalue,
            country: country.fieldvalue,
            additional: [
                .init(fieldTitle: phone.fieldname, fieldName: phone.fieldname, fieldValue: phone.fieldvalue, svgImage: ""),
                .init(fieldTitle: country.fieldname, fieldName: country.fieldname, fieldValue: country.fieldvalue, svgImage: ""),
            ],
            amount: XCTUnwrap(transfer.amount),
            puref: ""
        )
    }
    
    func test_shouldDeliverPaymentsOnDirect() {
        
        let transfer = makeTransfer(additional: [makePhone(), makeCountryID()])
        let info = makeDirect(parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverDirectOnContactAddressless(){
        
        let transfer = makeTransfer(additional: [makePhone(), makeCountryID()])
        let info = makeAddressless(parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - externalEntity, externalIndivudual
    
    func test_shouldCallMakePaymentsWithRepeatPaymentRequisitesSourceOnExternalEntity() throws {
        
        let transfer = makeTransfer(
            payeeExternal: makeExternalPayer(
                inn: anyMessage(),
                bankBIC: anyMessage()
            )
        )
        let info = makeRepeat(type: .externalEntity, parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try XCTAssertNoDiff(source, .repeatPaymentRequisites(
            accountNumber: XCTUnwrap(transfer.payeeExternal?.accountNumber),
            bankId: XCTUnwrap(transfer.payeeExternal?.bankBIC),
            inn: XCTUnwrap(transfer.payeeExternal?.inn),
            kpp: transfer.payeeExternal?.kpp,
            amount: XCTUnwrap(transfer.amount?.description),
            productId: nil,
            comment: transfer.comment
        ))
    }
    
    func test_shouldCallMakePaymentsWithRepeatPaymentRequisitesSourceOnExternalIndivudual() throws {
        
        let transfer = makeTransfer(
            payeeExternal: makeExternalPayer(
                inn: anyMessage(),
                bankBIC: anyMessage()
            )
        )
        let info = makeRepeat(type: .externalIndividual, parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try XCTAssertNoDiff(source, .repeatPaymentRequisites(
            accountNumber: XCTUnwrap(transfer.payeeExternal?.accountNumber),
            bankId: XCTUnwrap(transfer.payeeExternal?.bankBIC),
            inn: XCTUnwrap(transfer.payeeExternal?.inn),
            kpp: transfer.payeeExternal?.kpp,
            amount: XCTUnwrap(transfer.amount?.description),
            productId: nil,
            comment: transfer.comment
        ))
    }
    
    func test_shouldDeliverPaymentsOnExternalEntity() throws {
        
        let transfer = makeTransfer(
            payeeExternal: makeExternalPayer(
                inn: anyMessage(),
                bankBIC: anyMessage()
            )
        )
        let info = makeRepeat(type: .externalEntity, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverPaymentsOnExternalIndivudual() throws {
        
        let transfer = makeTransfer(
            payeeExternal: makeExternalPayer(
                inn: anyMessage(),
                bankBIC: anyMessage()
            )
        )
        let info = makeRepeat(type: .externalIndividual, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - insideBank
    
    func test_shouldCallMakePaymentsWithToAnotherCardSourceOnInsideBank() throws {
        
        let transfer = makeTransfer(payer: makePayer())
        let productTemplate = makeProductTemplate()
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: productTemplate
        )
        
        let source = makePaymentsSource(info)
        
        try XCTAssertNoDiff(
            source,
            .toAnotherCard(
                from: XCTUnwrap(transfer.payer?.cardId),
                to: XCTUnwrap(productTemplate.id),
                amount: transfer.amount?.description
            )
        )
    }
    
    func test_shouldDeliverPaymentsOnInsideBank() throws {
        
        let transfer = makeTransfer(payer: makePayer())
        let productTemplate = makeProductTemplate()
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: productTemplate
        )
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - internet, transport, housingAndCommunalService
    
    func test_shouldCallMakePaymentsWithServicePaymentSourceOnInternet() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .internet, parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try XCTAssertNoDiff(
            source,
            .servicePayment(
                puref: XCTUnwrap(transfer.puref),
                additionalList: [
                    .init(fieldTitle: additional.fieldname, fieldName: additional.fieldname, fieldValue: additional.fieldvalue, svgImage: nil)
                ],
                amount: XCTUnwrap(transfer.amount),
                productId: transfer.payer?.cardId
            )
        )
    }
    
    func test_shouldCallMakePaymentsWithServicePaymentSourceOnTransport() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .transport, parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try XCTAssertNoDiff(
            source,
            .servicePayment(
                puref: XCTUnwrap(transfer.puref),
                additionalList: [
                    .init(fieldTitle: additional.fieldname, fieldName: additional.fieldname, fieldValue: additional.fieldvalue, svgImage: nil)
                ],
                amount: XCTUnwrap(transfer.amount),
                productId: transfer.payer?.cardId
            )
        )
    }
    
    func test_shouldCallMakePaymentsWithServicePaymentSourceOnHousingAndCommunalService() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .housingAndCommunalService, parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        try XCTAssertNoDiff(
            source,
            .servicePayment(
                puref: XCTUnwrap(transfer.puref),
                additionalList: [
                    .init(fieldTitle: additional.fieldname, fieldName: additional.fieldname, fieldValue: additional.fieldvalue, svgImage: nil)
                ],
                amount: XCTUnwrap(transfer.amount),
                productId: transfer.payer?.cardId
            )
        )
    }
    
    func test_shouldDeliverPaymentsOnInternet() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .internet, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverPaymentsOnTransport() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .transport, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverPaymentsOnHousingAndCommunalService() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .housingAndCommunalService, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - byPhone
    
    func test_shouldCallMakePaymentsWithSFPSourceOnByPhone() throws {
        
        let activeProductID = makeProductID()
        let transfer = makeTransfer(
            payeeInternal: makeInternalPayer(phoneNumber: anyMessage())
        )
        let info = makeRepeat(type: .byPhone, parameterList: [transfer])
        
        let source = makePaymentsSource(info, activeProductID: activeProductID)
        
        try XCTAssertNoDiff(source, .sfp(
            phone: XCTUnwrap(transfer.payeeInternal?.phoneNumber),
            bankId: Vortex.BankID.vortexID.digits,
            amount: XCTUnwrap(transfer.amount?.description),
            productId: activeProductID
        ))
    }
    
    func test_shouldDeliverPaymentsOnByPhone() {
        
        let transfer = makeTransfer(
            payeeInternal: makeInternalPayer(phoneNumber: anyMessage())
        )
        let info = makeRepeat(type: .byPhone, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - sfp
    
    func test_shouldCallMakePaymentsWithSFPSourceOnSFP() throws {
        
        let activeProductID = makeProductID()
        let (phone, bankID) = (anyMessage(), anyMessage())
        let transfer = makeTransfer(
            additional: [
                makeAdditional(fieldname: "RecipientID", fieldvalue: phone),
                makeAdditional(fieldname: "BankRecipientID", fieldvalue: bankID)
            ]
        )
        let info = makeRepeat(type: .sfp, parameterList: [transfer])
        
        let source = makePaymentsSource(info, activeProductID: activeProductID)
        
        try XCTAssertNoDiff(source, .sfp(
            phone: phone,
            bankId: bankID,
            amount: XCTUnwrap(transfer.amount?.description),
            productId: activeProductID
        ))
    }
    
    func test_shouldDeliverPaymentsOnSFP() {
        
        let (phone, bankID) = (anyMessage(), anyMessage())
        let transfer = makeTransfer(
            additional: [
                makeAdditional(fieldname: "RecipientID", fieldvalue: phone),
                makeAdditional(fieldname: "BankRecipientID", fieldvalue: bankID)
            ]
        )
        let info = makeRepeat(type: .sfp, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - mobile
    
    func test_shouldCallMakePaymentsWithMobileSourceOnMobile() {
        
        let phone = anyMessage()
        let transfer = makeTransfer(
            additional: [makeAdditional(fieldname: "a3_NUMBER_1_2", fieldvalue: phone)]
        )
        let info = makeRepeat(type: .mobile, parameterList: [transfer])
        
        let source = makePaymentsSource(info)
        
        XCTAssertNoDiff(source, .mobile(
            phone: "7\(phone)",
            amount: transfer.amount?.description,
            productId: nil
        ))
    }
    
    func test_shouldDeliverPaymentsOnMobile() {
        
        let phone = anyMessage()
        let transfer = makeTransfer(
            additional: [makeAdditional(fieldname: "a3_NUMBER_1_2", fieldvalue: phone)]
        )
        let info = makeRepeat(type: .mobile, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - taxes
    
    func test_shouldCallMakePaymentsWithTaxesSourceOnTaxes() {
        
        let info = makeRepeat(type: .taxes)
        
        let source = makePaymentsSource(info)
        
        XCTAssertNoDiff(source, .taxes(parameterData: nil))
    }
    
    func test_shouldDeliverPaymentsOnTaxes() {
        
        let info = makeRepeat(type: .taxes)
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - otherBank
    
    func test_shouldCallMakePaymentsWitServiceOnOtherBank() {
        
        let info = makeRepeat(type: .otherBank)
        
        let service = makePaymentsService(info)
        
        XCTAssertNoDiff(service, .toAnotherCard)
    }
    
    func test_shouldDeliverPaymentsOnOtherBank() {
        
        let info = makeRepeat(type: .otherBank)
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - Helpers
    
    private typealias Payload = PaymentsDomain.PaymentsPayload
    
    private func makeDirect(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: ._direct, parameterList: parameterList)
    }
    
    private func makeAddressless(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .contactAddressless, parameterList: parameterList)
    }
    
    private enum EquatableNavigation: Equatable {
        
        case anywayPayment
        case meToMe
        case payments
    }
    
    private func equatable(
        _ navigation: PaymentsDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .anywayPayment: return .anywayPayment
        case .meToMe:        return .meToMe
        case .payments:      return .payments
        }
    }
    
    private func makeModelWithMeToMeProduct(
        product: ProductData? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        try model.addMeToMeProduct(product: product, file: file, line: line)
        
        return model
    }
    
    private func assert(
        model: Model = .mockWithEmptyExcept(),
        closeAction: @escaping () -> Void = {},
        product: ProductData? = nil,
        with info: Repeat,
        delivers expectedNavigation: EquatableNavigation?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT(model: model, file: file, line: line).sut
        
        let navigation = sut.getInfoRepeatPaymentNavigation(
            from: info,
            activeProductID: makeProductID(),
            getProduct: { _ in product },
            closeAction: closeAction
        )
        
        XCTAssertNoDiff(navigation.map(equatable), expectedNavigation, "Expected \(String(describing: expectedNavigation)), but got \(String(describing: navigation)) instead.", file: file, line: line)
    }
    
    private func assertDirect(
        _ source: Payments.Operation.Source?,
        phone expectedPhone: String,
        country expectedCountry: String,
        additional: [PaymentServiceData.AdditionalListData],
        amount: Double,
        puref: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch source {
        case let .direct(phone: phone, countryId: country, serviceData: serviceData):
            XCTAssertNoDiff(phone, expectedPhone, "Expected \(expectedPhone), but got \(String(describing: phone)) instead.", file: file, line: line)
            XCTAssertNoDiff(country, expectedCountry, "Expected \(expectedCountry), but got \(String(describing: country)) instead.", file: file, line: line)
            XCTAssertNoDiff(serviceData?.additionalList, additional, file: file, line: line)
            XCTAssertNoDiff(serviceData?.amount, amount, file: file, line: line)
            XCTAssertNoDiff(serviceData?.puref, puref, file: file, line: line)
            
        default:
            XCTFail("Expected `direct` source, but got \(String(describing: source)) instead.", file: file, line: line)
        }
    }
    
    private func makePaymentsSource(
        _ info: Repeat,
        activeProductID: ProductData.ID? = nil,
        product: ProductData? = nil
    ) -> Payments.Operation.Source? {
        
        guard case let .source(source) = makePaymentsPayload(info: info, activeProductID: activeProductID, product: product)
        else { return nil }
        
        return source
    }
    
    private func makePaymentsService(
        _ info: Repeat,
        activeProductID: ProductData.ID? = nil,
        product: ProductData? = nil
    ) -> Payments.Service? {
        
        guard case let .service(service) = makePaymentsPayload(info: info, activeProductID: activeProductID, product: product)
        else { return nil }
        
        return service
    }
    
    private func makePaymentsPayload(
        info: Repeat,
        activeProductID: ProductData.ID? = nil,
        product: ProductData? = nil
    ) -> PaymentsDomain.PaymentsPayload? {
        
        return info.paymentsPayload(
            activeProductID: activeProductID ?? makeProductID(),
            getProduct: { _ in product }
        )
    }
}

extension XCTestCase {
    
    func makeProduct(
        id: Int = .random(in: 1...100),
        productType: ProductType = .account,
        number: String? = nil,
        numberMasked: String? = nil,
        accountNumber: String? = nil,
        balance: Double? = nil,
        balanceRub: Double? = nil,
        currency: String = anyMessage(),
        mainField: String = anyMessage(),
        additionalField: String? = nil,
        customName: String? = nil,
        productName: String = anyMessage(),
        openDate: Date? = nil,
        ownerId: Int = .random(in: 1...100),
        branchId: Int? = nil,
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        extraLargeDesign: SVGImageData = .test,
        largeDesign: SVGImageData = .test,
        mediumDesign: SVGImageData = .test,
        smallDesign: SVGImageData = .test,
        fontDesignColor: ColorData = .init(description: anyMessage()),
        background: [ColorData] = [],
        order: Int = .random(in: 1...100),
        isVisible: Bool = true,
        smallDesignMd5hash: String = anyMessage(),
        smallBackgroundDesignHash: String = anyMessage()
    ) -> ProductData {
        
        return .init(
            id: id,
            productType: productType,
            number: number,
            numberMasked: numberMasked,
            accountNumber: accountNumber,
            balance: balance,
            balanceRub: balanceRub,
            currency: currency,
            mainField: mainField,
            additionalField: additionalField,
            customName: customName,
            productName: productName,
            openDate: openDate,
            ownerId: ownerId,
            branchId: branchId,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: extraLargeDesign,
            largeDesign: largeDesign,
            mediumDesign: mediumDesign,
            smallDesign: smallDesign,
            fontDesignColor: fontDesignColor,
            background: background,
            order: order,
            isVisible: isVisible,
            smallDesignMd5hash: smallDesignMd5hash,
            smallBackgroundDesignHash: smallBackgroundDesignHash
        )
    }
}

extension String {
    
    static let addressingCash: Self = "ADDRESSING_CASH"
    static let addressless: Self = "ADDRESSLESS"
    static let betweenTheir: Self = "BETWEEN_THEIR"
    static let byPhone: Self = "BY_PHONE"
    static let charityService: Self = "CHARITY_SERVICE"
    static let contactAddressless: Self = "CONTACT_ADDRESSLESS"
    static let digitalWalletsService: Self = "DIGITAL_WALLETS_SERVICE"
    static let _direct: Self = "DIRECT"
    static let educationService: Self = "EDUCATION_SERVICE"
    static let externalEntity: Self = "EXTERNAL_ENTITY"
    static let externalIndividual: Self = "EXTERNAL_INDIVIDUAL"
    static let foreignCard: Self = "FOREIGN_CARD"
    static let housingAndCommunalService: Self = "HOUSING_AND_COMMUNAL_SERVICE"
    static let insideBank: Self = "INSIDE_BANK"
    static let internet: Self = "INTERNET"
    static let mobile: Self = "MOBILE"
    static let networkMarketingService: Self = "NETWORK_MARKETING_SERVICE"
    static let newDirect: Self = "NEW_DIRECT"
    static let newDirectAccount: Self = "NEW_DIRECT_ACCOUNT"
    static let newDirectCard: Self = "NEW_DIRECT_CARD"
    static let otherBank: Self = "OTHER_BANK"
    static let repaymentLoansAndAccountsService: Self = "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE"
    static let securityService: Self = "SECURITY_SERVICE"
    static let sfp: Self = "SFP"
    static let socialAndGamesService: Self = "SOCIAL_AND_GAMES_SERVICE"
    static let taxes: Self = "TAX_AND_STATE_SERVICE"
    static let transport: Self = "TRANSPORT"
}

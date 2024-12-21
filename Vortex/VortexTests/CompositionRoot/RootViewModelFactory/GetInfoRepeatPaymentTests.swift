//
//  GetInfoRepeatPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    func betweenTheirMode(
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsMeToMeViewModel.Mode? {
        
        guard type == .betweenTheir else { return nil }
        
        return parameterList.compactMap {
            
            guard let amount = $0.amount,
                  let productID = $0.payerOrInternalPayerProductID,
                  let product = getProduct(productID)
            else { return nil }
            
            return .makePaymentTo(product, amount)
        }
        .first
    }
    
    func directSource(
        date: Date = .init()
    ) -> Payments.Operation.Source? {
        
        guard type == .direct || type == .contactAddressless,
              let transfer = parameterList.last,
              let additional = transfer.additional,
              let phone = transfer.directPhone,
              let countryId = transfer.countryID
        else { return nil }
        
        return .direct(
            phone: phone,
            countryId: countryId,
            serviceData: .init(
                additionalList: additional.map {
                    
                    return .init(
                        fieldTitle: $0.fieldname,
                        fieldName: $0.fieldname,
                        fieldValue: $0.fieldvalue,
                        svgImage: ""
                    )
                },
                amount: transfer.amount ?? 0,
                date: date, // ???
                paymentDate: "", // ???
                puref: transfer.puref ?? "", // ???
                type: .internet, // ???
                lastPaymentName: nil
            )
        )
    }
    
    func repeatPaymentRequisitesSource(
    ) -> Payments.Operation.Source? {
        
        guard type == .externalEntity || type == .externalIndivudual,
              let transfer = parameterList.last,
              let amount = transfer.amount?.description,
              let accountNumber = transfer.payeeExternal?.accountNumber,
              let bankBIC = transfer.payeeExternal?.bankBIC
        else { return nil }
        
        return .repeatPaymentRequisites(
            accountNumber: accountNumber,
            bankId: bankBIC,
            inn: transfer.payeeExternal?.inn ?? "",
            kpp: transfer.payeeExternal?.kpp,
            amount: amount,
            productId: transfer.payerProductID,
            comment: transfer.comment
        )
    }
    
    func toAnotherCardSource(
    ) -> Payments.Operation.Source? {
        
        guard type == .insideBank,
              let transfer = parameterList.last,
              let from = transfer.payer?.cardId,
              let amount = transfer.amount,
              let to = productTemplate?.id
        else { return nil }
        
        return .toAnotherCard(from: from, to: to, amount: amount.description)
    }
    
    func servicePaymentSource() -> Payments.Operation.Source? {
        
        guard type == .internet || type == .transport || type == .housingAndCommunalService,
              let transfer = parameterList.first,
              let puref = transfer.puref,
              let amount = transfer.amount ?? parameterList.last?.amount
        else { return nil }
        
        return .servicePayment(
            puref: puref,
            additionalList: transfer.additional?.map {
                
                return .init(fieldTitle: $0.fieldname, fieldName: $0.fieldname, fieldValue: $0.fieldvalue, svgImage: nil)
            },
            amount: amount,
            productId: transfer.payer?.cardId
        )
    }
    
    func otherBankService() -> Payments.Service? {
        
        type == .otherBank ? .toAnotherCard : nil
    }
    
    func byPhoneSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == .byPhone,
              let transfer = parameterList.last,
              let phone = transfer.payeeInternal?.phoneNumber,
              let amount = transfer.amount
        else { return nil }
        
        return .sfp(
            phone: phone,
            bankId: Vortex.BankID.vortexID.digits,
            amount: amount.description,
            productId: activeProductID
        )
    }
    
    func sfpSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == .sfp,
              let transfer = parameterList.last,
              let phone = transfer.sfpPhone,
              let bankID = transfer.sfpBankID,
              let amount = transfer.amount
        else { return nil }
        
        return .sfp(
            phone: phone,
            bankId: bankID,
            amount: amount.description,
            productId: activeProductID
        )
    }
    
    func mobileSource(
    ) -> Payments.Operation.Source? {
        
        guard type == .mobile,
              let transfer = parameterList.last,
              let phone = transfer.mobilePhone,
              let amount = transfer.amount
        else { return nil }
        
        return .mobile(
            phone: phone,
            amount: amount.description,
            productId: transfer.payerProductID
        )
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer {
    
    var countryID: String? {
        
        additional?.first(where: { $0.fieldname == "trnPickupPoint"})?.fieldvalue
    }
    
    var directPhone: String? {
        
        additional?.first(where: { $0.fieldname == "RECP"})?.fieldvalue
    }
    
    var mobilePhone: String? {
        
        additional?.first(where: { $0.fieldname == "a3_NUMBER_1_2"})?.fieldvalue
    }
    
    var sfpBankID: String? {
        
        additional?.first(where: { $0.fieldname == "BankRecipientID"})?.fieldvalue
    }
    
    var sfpPhone: String? {
        
        additional?.first(where: { $0.fieldname == "RecipientID"})?.fieldvalue
    }
    
    var payerOrInternalPayerProductID: Int? {
        
        payerProductID ?? internalPayeeProductID
    }
    
    var payerProductID: Int? {
        
        payer?.cardId ?? payer?.accountId
    }
    
    private var externalPayeeProductID: Int? {
        
        payeeExternal?.cardId ?? payeeExternal?.accountId
    }
    
    private var internalPayeeProductID: Int? {
        
        payeeInternal?.cardId ?? payeeInternal?.accountId
    }
}

@testable import Vortex
import XCTest

class GetInfoRepeatPaymentTests: RootViewModelFactoryTests {
    
    // MARK: - betweenTheirMode
    
    func test_betweenTheirMode_shouldDeliverNilOnNonBetweenTheirType() {
        
        for type in allTransferTypes(except: .betweenTheir) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
        }
    }
    
    func test_betweenTheirMode_shouldDeliverNilOnNilAmount() {
        
        let productID = makeProductID()
        let transfer = makeTransfer(
            amount: nil,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_betweenTheirMode_shouldDeliverNilOnEmptyParameterList() throws {
        
        let info = makeBetweenTheir(parameterList: [])
        
        XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_betweenTheirMode_shouldDeliverNilOnExternalPayerProduct() throws {
        
        let transfer = makeTransfer(payeeExternal: makeExternalPayer())
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_betweenTheirMode_shouldDeliverModeOnPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID)
        let amount = Double.random(in: 1...100)
        let transfer = makeTransfer(
            amount: amount,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNoDiff(
            info.betweenTheirMode(getProduct: { _ in product }),
            .makePaymentTo(product, amount)
        )
    }
    
    func test_betweenTheirMode_shouldDeliverModeOnInternalPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID)
        let amount = Double.random(in: 1...100)
        let transfer = makeTransfer(
            amount: amount,
            payeeInternal: makeInternalPayer(accountId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNoDiff(
            info.betweenTheirMode(getProduct: { _ in product }),
            .makePaymentTo(product, amount)
        )
    }
    
    // MARK: - directSource
    
    func test_directSource_shouldDeliverNilForNonDirectNonContactAddressless() {
        
        for type in allTransferTypes(except: .direct, .contactAddressless) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.directSource())
        }
    }
    
    func test_directSource_shouldDeliverNilOnEmptyParameterList() {
        
        for type in [TransferType.direct, .contactAddressless] {
            
            let info = makeRepeat(type: type, parameterList: [])
            
            XCTAssertNil(info.directSource())
        }
    }
    
    func test_directSource_shouldDeliverNilOnNilAdditional() {
        
        for type in [TransferType.direct, .contactAddressless] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(additional: nil)
            ])
            
            XCTAssertNil(info.directSource())
        }
    }
    
    func test_directSource_shouldDeliverNilOnMissingCountryIDField() {
        
        for type in [TransferType.direct, .contactAddressless] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(additional: [makePhone()])
            ])
            
            XCTAssertNil(info.directSource())
        }
    }
    
    func test_directSource_shouldDeliverNilOnMissingPhoneField() {
        
        for type in [TransferType.direct, .contactAddressless] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(additional: [makeCountryID()])
            ])
            
            XCTAssertNil(info.directSource())
        }
    }
    
    func test_directSource_shouldDeliverSourceOnDirect() {
        
        let amount = Double.random(in: 1...1_000)
        let date = Date()
        let (phone, countryID) = (makePhone(), makeCountryID())
        let info = makeRepeat(type: .direct, parameterList: [
            makeTransfer(amount: amount, additional: [phone, countryID])
        ])
        
        XCTAssertNoDiff(info.directSource(date: date), .direct(
            phone: phone.fieldvalue,
            countryId: countryID.fieldvalue,
            serviceData: .init(
                additionalList: [
                    .init(fieldTitle: phone.fieldname, fieldName: phone.fieldname, fieldValue: phone.fieldvalue, svgImage: ""),
                    .init(fieldTitle: countryID.fieldname, fieldName: countryID.fieldname, fieldValue: countryID.fieldvalue, svgImage: ""),
                ],
                amount: amount,
                date: date,
                paymentDate: "",
                puref: "",
                type: .internet,
                lastPaymentName: nil
            )
        ))
    }
    
    func test_directSource_shouldDeliverSourceOnContactAddressless() {
        
        let amount = Double.random(in: 1...1_000)
        let date = Date()
        let (phone, countryID) = (makePhone(), makeCountryID())
        let info = makeRepeat(type: .contactAddressless, parameterList: [
            makeTransfer(amount: amount, additional: [phone, countryID])
        ])
        
        XCTAssertNoDiff(info.directSource(date: date), .direct(
            phone: phone.fieldvalue,
            countryId: countryID.fieldvalue,
            serviceData: .init(
                additionalList: [
                    .init(fieldTitle: phone.fieldname, fieldName: phone.fieldname, fieldValue: phone.fieldvalue, svgImage: ""),
                    .init(fieldTitle: countryID.fieldname, fieldName: countryID.fieldname, fieldValue: countryID.fieldvalue, svgImage: ""),
                ],
                amount: amount,
                date: date,
                paymentDate: "",
                puref: "",
                type: .internet,
                lastPaymentName: nil
            )
        ))
    }
    
    // MARK: - repeatPaymentRequisitesSource
    
    func test_repeatPaymentRequisitesSource_shouldDeliverNilForNonExternalEntityNonExternalIndivudual() {
        
        for type in allTransferTypes(except: .externalEntity, .externalIndivudual) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.repeatPaymentRequisitesSource())
        }
    }
    
    func test_repeatPaymentRequisitesSource_shouldDeliverNilOnEmptyParameterList() {
        
        for type in [TransferType.externalEntity, .externalIndivudual] {
            
            let info = makeRepeat(type: type, parameterList: [])
            
            XCTAssertNil(info.repeatPaymentRequisitesSource())
        }
    }
    
    func test_repeatPaymentRequisitesSource_shouldDeliverNilOnNilAmount() {
        
        for type in [TransferType.externalEntity, .externalIndivudual] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(
                    amount: nil,
                    payeeExternal: makeExternalPayer(bankBIC: anyMessage())
                )
            ])
            
            XCTAssertNil(info.repeatPaymentRequisitesSource())
        }
    }
    
    func test_repeatPaymentRequisitesSource_shouldDeliverNilOnNilBICPayeeExternal() {
        
        for type in [TransferType.externalEntity, .externalIndivudual] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(
                    payeeExternal: makeExternalPayer(bankBIC: nil)
                )
            ])
            
            XCTAssertNil(info.repeatPaymentRequisitesSource())
        }
    }
    
    func test_repeatPaymentRequisitesSource_shouldDeliverSourceOnExternalEntity() throws {
        
        let transfer = makeTransfer(payeeExternal: makeExternalPayer(
            inn: anyMessage(),
            bankBIC: anyMessage())
        )
        let info = makeRepeat(type: .externalEntity, parameterList: [transfer])
        
        try XCTAssertNoDiff(
            info.repeatPaymentRequisitesSource(),
            .repeatPaymentRequisites(
                accountNumber: XCTUnwrap(transfer.payeeExternal?.accountNumber),
                bankId: XCTUnwrap(transfer.payeeExternal?.bankBIC),
                inn: XCTUnwrap(transfer.payeeExternal?.inn),
                kpp: transfer.payeeExternal?.kpp,
                amount: XCTUnwrap(transfer.amount?.description),
                productId: transfer.payerProductID,
                comment: transfer.comment
            )
        )
    }
    
    func test_repeatPaymentRequisitesSource_shouldDeliverSourceOnExternalIndivudual() throws {
        
        let transfer = makeTransfer(payeeExternal: makeExternalPayer(
            inn: anyMessage(),
            bankBIC: anyMessage())
        )
        let info = makeRepeat(type: .externalIndivudual, parameterList: [transfer])
        
        try XCTAssertNoDiff(
            info.repeatPaymentRequisitesSource(),
            .repeatPaymentRequisites(
                accountNumber: XCTUnwrap(transfer.payeeExternal?.accountNumber),
                bankId: XCTUnwrap(transfer.payeeExternal?.bankBIC),
                inn: XCTUnwrap(transfer.payeeExternal?.inn),
                kpp: transfer.payeeExternal?.kpp,
                amount: XCTUnwrap(transfer.amount?.description),
                productId: transfer.payerProductID,
                comment: transfer.comment
            )
        )
    }
    
    // MARK: - toAnotherCardSource
    
    func test_toAnotherCardSource_shouldDeliverNilForNonInsideBank() {
        
        for type in allTransferTypes(except: .insideBank) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.toAnotherCardSource())
        }
    }
    
    func test_toAnotherCardSource_shouldDeliverNilOnEmptyParameterList() {
        
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [],
            productTemplate: makeProductTemplate()
        )
        
        XCTAssertNil(info.toAnotherCardSource())
    }
    
    func test_toAnotherCardSource_shouldDeliverNilOnNilAmount() {
        
        let transfer = makeTransfer(amount: nil, payer: makePayer())
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: makeProductTemplate()
        )
        
        XCTAssertNil(info.toAnotherCardSource())
    }
    
    func test_toAnotherCardSource_shouldDeliverNilOnNilPayerCardID() {
        
        let transfer = makeTransfer(payer: nil)
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: makeProductTemplate()
        )
        
        XCTAssertNil(info.toAnotherCardSource())
    }
    
    func test_toAnotherCardSource_shouldDeliverNilOnNilProductTemplateID() {
        
        let transfer = makeTransfer(payer: makePayer())
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: makeProductTemplate(id: nil)
        )
        
        XCTAssertNil(info.toAnotherCardSource())
    }
    
    func test_toAnotherCardSource_shouldDeliverSourceOnInsideBank() throws {
        
        let transfer = makeTransfer(payer: makePayer())
        let productTemplate = makeProductTemplate()
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: productTemplate
        )
        
        try XCTAssertNoDiff(
            info.toAnotherCardSource(),
            .toAnotherCard(
                from: XCTUnwrap(transfer.payer?.cardId),
                to: XCTUnwrap(productTemplate.id),
                amount: transfer.amount?.description
            )
        )
    }
    
    // MARK: - servicePaymentSource
    
    func test_servicePaymentSource_shouldDeliverNilForNonInternetNonTransportNonHousingAndCommunalService() {
        
        for type in allTransferTypes(except: .internet, .transport, .housingAndCommunalService) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.servicePaymentSource())
        }
    }
    
    func test_servicePaymentSource_shouldDeliverNilOnEmptyParameterList() {
        
        for type in [TransferType.internet, .transport, .housingAndCommunalService] {
            
            let info = makeRepeat(type: type, parameterList: [])
            
            XCTAssertNil(info.servicePaymentSource())
        }
    }
    
    func test_servicePaymentSource_shouldDeliverNilOnMissingPuref() {
        
        for type in [TransferType.internet, .transport, .housingAndCommunalService] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(puref: nil)
            ])
            
            XCTAssertNil(info.servicePaymentSource())
        }
    }
    
    func test_servicePaymentSource_shouldDeliverNilOnMissingAmount() {
        
        for type in [TransferType.internet, .transport, .housingAndCommunalService] {
            
            let info = makeRepeat(type: type, parameterList: [
                makeTransfer(amount: nil)
            ])
            
            XCTAssertNil(info.servicePaymentSource())
        }
    }
    
    func test_servicePaymentSource_shouldDeliverSourceOnInternet() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .internet, parameterList: [transfer])
        
        try XCTAssertNoDiff(info.servicePaymentSource(), .servicePayment(
            puref: XCTUnwrap(transfer.puref),
            additionalList: [
                .init(fieldTitle: additional.fieldname, fieldName: additional.fieldname, fieldValue: additional.fieldvalue, svgImage: nil)
            ],
            amount: XCTUnwrap(transfer.amount),
            productId: transfer.payer?.cardId
        ))
    }
    
    func test_servicePaymentSource_shouldDeliverSourceOnTransport() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .transport, parameterList: [transfer])
        
        try XCTAssertNoDiff(info.servicePaymentSource(), .servicePayment(
            puref: XCTUnwrap(transfer.puref),
            additionalList: [
                .init(fieldTitle: additional.fieldname, fieldName: additional.fieldname, fieldValue: additional.fieldvalue, svgImage: nil)
            ],
            amount: XCTUnwrap(transfer.amount),
            productId: transfer.payer?.cardId
        ))
    }
    
    func test_servicePaymentSource_shouldDeliverSourceOnHousingAndCommunalService() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .housingAndCommunalService, parameterList: [transfer])
        
        try XCTAssertNoDiff(info.servicePaymentSource(), .servicePayment(
            puref: XCTUnwrap(transfer.puref),
            additionalList: [
                .init(fieldTitle: additional.fieldname, fieldName: additional.fieldname, fieldValue: additional.fieldvalue, svgImage: nil)
            ],
            amount: XCTUnwrap(transfer.amount),
            productId: transfer.payer?.cardId
        ))
    }
    
    // MARK: - otherBankService
    
    func test_otherBankService_shouldDeliverNilForNonOtherBank() {
        
        for type in allTransferTypes(except: .otherBank) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.otherBankService())
        }
    }

    func test_otherBankService_shouldDeliverToAnotherCard() {
        
        XCTAssertNoDiff(makeRepeat(type: .otherBank).otherBankService(), .toAnotherCard)
    }

    // MARK: - byPhoneSource
    
    func test_byPhoneSource_shouldDeliverNilForNonByPhone() {
        
        for type in allTransferTypes(except: .byPhone) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.byPhoneSource(activeProductID: makeProductID()))
        }
    }
    
    func test_byPhoneSource_shouldDeliverNilOnEmptyParameterList() {
        
        let info = makeRepeat(type: .byPhone, parameterList: [])
        
        XCTAssertNil(info.byPhoneSource(activeProductID: makeProductID()))
    }
    
    func test_byPhoneSource_shouldDeliverNilOnMissingInternalPayeePhoneNumber() {
        
        let transfer = makeTransfer(
            payeeInternal: makeInternalPayer(phoneNumber: nil)
        )
        let info = makeRepeat(type: .byPhone, parameterList: [transfer])
        
        XCTAssertNil(info.byPhoneSource(activeProductID: makeProductID()))
    }
    
    func test_byPhoneSource_shouldDeliverNilOnMissingAmount() {
        
        let transfer = makeTransfer(
            amount: nil,
            payeeInternal: makeInternalPayer(phoneNumber: anyMessage())
        )
        let info = makeRepeat(type: .byPhone, parameterList: [transfer])
        
        XCTAssertNil(info.byPhoneSource(activeProductID: makeProductID()))
    }
    
    func test_byPhoneSource_shouldDeliverSource() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(
            payeeInternal: makeInternalPayer(phoneNumber: anyMessage())
        )
        let info = makeRepeat(type: .byPhone, parameterList: [transfer])
        
        try XCTAssertNoDiff(info.byPhoneSource(activeProductID: productID), .sfp(
            phone: XCTUnwrap(transfer.payeeInternal?.phoneNumber),
            bankId: Vortex.BankID.vortexID.digits,
            amount: XCTUnwrap(transfer.amount?.description),
            productId: productID
        ))
    }
    
    // MARK: - sfp
    
    func test_sfp_shouldDeliverNilForNonSFP() {
        
        for type in allTransferTypes(except: .sfp) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.sfpSource(activeProductID: makeProductID()))
        }
    }
    
    func test_sfpSource_shouldDeliverNilOnEmptyParameterList() {
        
        let info = makeRepeat(type: .sfp, parameterList: [])
        
        XCTAssertNil(info.sfpSource(activeProductID: makeProductID()))
    }

    func test_sfpSource_shouldDeliverNilOnMissingPhone() {
        
        let info = makeRepeat(type: .sfp, parameterList: [makeTransfer()])

        XCTAssertNil(info.sfpSource(activeProductID: makeProductID()))
    }

    func test_sfpSource_shouldDeliverNilOnMissingBankID() {
        
        let transfer = makeTransfer(
            additional: [makeAdditional(fieldname: "RecipientID")]
        )
        let info = makeRepeat(type: .sfp, parameterList: [transfer])

        XCTAssertNil(info.sfpSource(activeProductID: makeProductID()))
    }

    func test_sfpSource_shouldDeliverNilOnMissingAmount() {
        
        let transfer = makeTransfer(
            amount: nil,
            additional: [
                makeAdditional(fieldname: "RecipientID"),
                makeAdditional(fieldname: "BankRecipientID")
            ]
        )
        let info = makeRepeat(type: .sfp, parameterList: [transfer])

        XCTAssertNil(info.sfpSource(activeProductID: makeProductID()))
    }

    func test_sfpSource_shouldDeliverSource() throws {
        
        let productID = makeProductID()
        let (phone, bankID) = (anyMessage(), anyMessage())
        let transfer = makeTransfer(
            additional: [
                makeAdditional(fieldname: "RecipientID", fieldvalue: phone),
                makeAdditional(fieldname: "BankRecipientID", fieldvalue: bankID)
            ]
        )
        let info = makeRepeat(type: .sfp, parameterList: [transfer])

        try XCTAssertNoDiff(info.sfpSource(activeProductID: productID), .sfp(
            phone: phone,
            bankId: bankID,
            amount: XCTUnwrap(transfer.amount?.description),
            productId: productID
        ))
    }

    // MARK: - mobileSource
    
    func test_mobileSource_shouldDeliverNilForNonMobile() {
        
        for type in allTransferTypes(except: .mobile) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.mobileSource())
        }
    }
    
    func test_mobileSource_shouldDeliverNilOnEmptyParameterList() {
        
        let info = makeRepeat(type: .mobile, parameterList: [])
        
        XCTAssertNil(info.mobileSource())
    }
    
    func test_mobileSource_shouldDeliverNilOnMissingMobilePhone() {
        
        let info = makeRepeat(type: .mobile, parameterList: [makeTransfer()])
        
        XCTAssertNil(info.mobileSource())
    }
    
    func test_mobileSource_shouldDeliverNilOnMissingAmount() {
        
        let transfer = makeTransfer(
            amount: nil,
            additional: [makeAdditional(fieldname: "a3_NUMBER_1_2")]
        )
        let info = makeRepeat(type: .mobile, parameterList: [transfer])
        
        XCTAssertNil(info.mobileSource())
    }
    
    func test_mobileSource_shouldDeliverSource() {
        
        let transfer = makeTransfer(
            additional: [makeAdditional(fieldname: "a3_NUMBER_1_2")]
        )
        let info = makeRepeat(type: .mobile, parameterList: [transfer])
        
        XCTAssertNoDiff(info.mobileSource(), .mobile(
            phone: transfer.mobilePhone, amount: transfer.amount?.description, productId: transfer.payerProductID
        ))
    }
    
    // MARK: - Helpers
    
    typealias Repeat = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    typealias Transfer = Repeat.Transfer
    typealias TransferType = Repeat.TransferType
    
    func allTransferTypes(
        except excludingTypes: TransferType...
    ) -> [TransferType] {
        
        return TransferType.allCases.filter { !excludingTypes.contains($0) }
    }
    
    func makeBetweenTheir(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .betweenTheir, parameterList: parameterList)
    }
    
    func makeRepeat(
        type: TransferType,
        parameterList: [Repeat.Transfer] = [],
        productTemplate: Repeat.ProductTemplate? = nil
    ) -> Repeat {
        
        return .init(type: type, parameterList: parameterList, productTemplate: productTemplate)
    }
    
    func makeProductTemplate(
        id: Int? = .random(in: 1...100),
        numberMask: String? = nil,
        customName: String? = nil,
        currency: String? = nil,
        type: Repeat.ProductTemplate.ProductType? = nil,
        smallDesign: String? = nil,
        paymentSystemImage: String? = nil
    ) -> Repeat.ProductTemplate {
        
        return .init(
            id: id,
            numberMask: numberMask,
            customName: customName,
            currency: currency,
            type: type,
            smallDesign: smallDesign,
            paymentSystemImage: paymentSystemImage
        )
    }
    
    func makeProductID() -> ProductData.ID {
        
        return .random(in: 1...1_000)
    }
    
    func makeTransfer(
        check: Bool = false,
        amount: Double? = .random(in: 1...100),
        currencyAmount: String? = nil,
        payer: Transfer.Payer? = nil,
        comment: String? = nil,
        puref: String? = nil,
        payeeInternal: Transfer.PayeeInternal? = nil,
        payeeExternal: Transfer.PayeeExternal? = nil,
        additional: [Transfer.Additional]? = nil,
        mcc: String? = nil
    ) -> Repeat.Transfer {
        
        return .init(
            check: check,
            amount: amount,
            currencyAmount: currencyAmount,
            payer: payer,
            comment: comment,
            puref: puref,
            payeeInternal: payeeInternal,
            payeeExternal: payeeExternal,
            additional: additional,
            mcc: mcc
        )
    }
    
    func makePayer(
        cardId: Int = .random(in: 1...100),
        cardNumber: String? = nil,
        accountId: Int? = nil,
        accountNumber: String? = nil,
        phoneNumber: String? = nil,
        inn: String? = nil
    ) -> Repeat.Transfer.Payer {
        
        return .init(
            cardId: cardId,
            cardNumber: cardNumber,
            accountId: accountId,
            accountNumber: accountNumber,
            phoneNumber: phoneNumber,
            inn: inn
        )
    }
    
    func makeExternalPayer(
        inn: String? = nil,
        kpp: String? = nil,
        accountId: Int? = nil,
        accountNumber: String = anyMessage(),
        bankBIC: String? = nil,
        cardId: Int? = nil,
        cardNumber: String? = nil,
        compilerStatus: String? = nil,
        date: String? = nil,
        name: String = anyMessage()
    ) -> Repeat.Transfer.PayeeExternal {
        
        return .init(
            inn: inn,
            kpp: kpp,
            accountId: accountId,
            accountNumber: accountNumber,
            bankBIC: bankBIC,
            cardId: cardId,
            cardNumber: cardNumber,
            compilerStatus: compilerStatus,
            date: date,
            name: name
        )
    }
    
    func makeInternalPayer(
        accountId: Int? = nil,
        accountNumber: String? = nil,
        cardId: Int? = nil,
        cardNumber: String? = nil,
        phoneNumber: String? = nil,
        productCustomName: String? = nil
    ) -> Repeat.Transfer.PayeeInternal {
        
        return .init(
            accountId: accountId,
            accountNumber: accountNumber,
            cardId: cardId,
            cardNumber: cardNumber,
            phoneNumber: phoneNumber,
            productCustomName: productCustomName
        )
    }
    
    func makePhone(
        fieldid: Int = .random(in: 1...100),
        fieldvalue: String = anyMessage()
    ) -> Transfer.Additional {
        
        return makeAdditional(fieldname: "RECP", fieldid: fieldid, fieldvalue: fieldvalue)
    }
    
    func makeCountryID(
        fieldid: Int = .random(in: 1...100),
        fieldvalue: String = anyMessage()
    ) -> Transfer.Additional {
        
        return makeAdditional(fieldname: "trnPickupPoint", fieldid: fieldid, fieldvalue: fieldvalue)
    }
    
    func makeAdditional(
        fieldname: String = anyMessage(),
        fieldid: Int = .random(in: 1...100),
        fieldvalue: String = anyMessage()
    ) -> Transfer.Additional {
        
        return .init(fieldname: fieldname, fieldid: fieldid, fieldvalue: fieldvalue)
    }
}

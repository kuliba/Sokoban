//
//  Templates+Helpers.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.11.2023.
//

@testable import ForaBank

extension PaymentTemplateData {
    
    static let mobileWithOutPhone: Self = templateStub(
        type: .mobile,
        parameterList: .mobileWithOutPhone)

    static let mobile10Digits: Self = templateStub(
        type: .mobile,
        parameterList: .mobile10Digits)
    
    static let mobileLess10Digits: Self = templateStub(
        type: .mobile,
        parameterList: .mobileLess10Digits)
    
    static let mobileMore10Digits: Self = templateStub(
        type: .mobile,
        parameterList: .mobileMore10Digits)
    
    static let sfpWithOutPhone: Self = templateStub(
        type: .sfp,
        parameterList: .sfpWithOutPhone)

    static let sfpPhone10Digits: Self = templateStub(
        type: .sfp,
        parameterList: .sfpPhone10Digits)
    
    static let sfpPhoneLess10Digits: Self = templateStub(
        type: .sfp,
        parameterList: .sfpPhoneLess10Digits)
    
    static let sfpPhoneMore10Digits: Self = templateStub(
        type: .sfp,
        parameterList: .sfpPhoneMore10Digits)
}

extension Array where Element == TransferAnywayData {
    
    static let mobileWithOutPhone: Self = [
        .transferAnywayDataStub(additional: [.mobileWithOutPhone])
    ]
    
    static let mobile10Digits: Self = [
        .transferAnywayDataStub(additional: [.mobile10Digits])
    ]
    
    static let mobileLess10Digits: Self = [
        .transferAnywayDataStub(additional: [.mobileLess10Digits])
    ]
    
    static let mobileMore10Digits: Self = [
        .transferAnywayDataStub(additional: [.mobileMore10Digits])
    ]
    
    static let sfpWithOutPhone: Self = [
        .transferAnywayDataStub(additional: [.sfpWithOutPhone])
    ]
    
    static let sfpPhone10Digits: Self = [
        .transferAnywayDataStub(additional: [.sfpPhone10Digits])
    ]
    
    static let sfpPhoneLess10Digits: Self = [
        .transferAnywayDataStub(additional: [.sfpPhoneLess10Digits])
    ]
    
    static let sfpPhoneMore10Digits: Self = [
        .transferAnywayDataStub(additional: [.sfpPhoneMore10Digits])
    ]
}

extension TransferAnywayData.Additional {
    
    static let mobileWithOutPhone: Self = .init(
        fieldid: 1,
        fieldname: "a3",
        fieldvalue: "test")
    
    static let mobile10Digits: Self = .init(
        fieldid: 1,
        fieldname: "a3_NUMBER_1_2",
        fieldvalue: "9630000000")
    
    static let mobileLess10Digits: Self = .init(
        fieldid: 1,
        fieldname: "a3_NUMBER_1_2",
        fieldvalue: "963000000")
    
    static let mobileMore10Digits: Self = .init(
        fieldid: 1,
        fieldname: "a3_NUMBER_1_2",
        fieldvalue: "96300000000")
    
    static let sfpWithOutPhone: Self = .init(
        fieldid: 1,
        fieldname: "test",
        fieldvalue: "test")
    
    static let sfpPhone10Digits: Self = .init(
        fieldid: 1,
        fieldname: "RecipientID",
        fieldvalue: "9630000000")
    
    static let sfpPhoneLess10Digits: Self = .init(
        fieldid: 1,
        fieldname: "RecipientID",
        fieldvalue: "963000000")
    
    static let sfpPhoneMore10Digits: Self = .init(
        fieldid: 1,
        fieldname: "RecipientID",
        fieldvalue: "96300000000")
}

extension TransferAnywayData {
    
    static func transferAnywayDataStub(
        additional: [Additional]
    ) -> TransferAnywayData {
        .init(amount: 10.0, check: true, comment: nil, currencyAmount: "", payer: .test(), additional: additional, puref: nil)
    }
}

//
//  Payments+ParameterTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 03.06.2024.
//

@testable import ForaBank
import XCTest

final class Payments_ParameterTests: XCTestCase {

    func test_systemIdentifiersForPayments() throws {

        let systemIdentifiers = Payments.Parameter.systemIdentifiers.map({ $0.rawValue })
        XCTAssertEqual(systemIdentifiers, [
            "ru.forabank.sense.category",
            "ru.forabank.sense.service",
            "ru.forabank.sense.operator",
            "ru.forabank.sense.header",
            "ru.forabank.sense.product",
            "ru.forabank.sense.amount",
            "ru.forabank.sense.code",
            "ru.forabank.sense.fee",
            "ru.forabank.sense.continue",
            "ru.forabank.sense.mock",
            "ru.forabank.sense.subscribe",
            "ru.forabank.sense.productTemplate",
            "ru.forabank.sense.productTemplateName"
        ])
    }
}

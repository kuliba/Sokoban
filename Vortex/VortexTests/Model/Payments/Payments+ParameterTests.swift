//
//  Payments+ParameterTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 03.06.2024.
//

@testable import Vortex
import XCTest

final class Payments_ParameterTests: XCTestCase {

    func test_systemIdentifiersForPayments() throws {

        let systemIdentifiers = Payments.Parameter.systemIdentifiers.map({ $0.rawValue })
        XCTAssertEqual(systemIdentifiers, [
            "ru.vortex.sense.category",
            "ru.vortex.sense.service",
            "ru.vortex.sense.operator",
            "ru.vortex.sense.header",
            "ru.vortex.sense.product",
            "ru.vortex.sense.amount",
            "ru.vortex.sense.code",
            "ru.vortex.sense.fee",
            "ru.vortex.sense.continue",
            "ru.vortex.sense.mock",
            "ru.vortex.sense.subscribe",
            "ru.vortex.sense.productTemplate",
            "ru.vortex.sense.productTemplateName"
        ])
    }
}

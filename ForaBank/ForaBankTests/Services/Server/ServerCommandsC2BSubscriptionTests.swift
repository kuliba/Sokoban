//
//  ServerCommandsC2BSubscriptionTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 30.01.2023.
//

import XCTest
@testable import ForaBank

class ServerCommandsC2BSubscriptionTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsSPBTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    
    //MARK: - ConfirmC2BSubscription

    //FIXME: - Update test
    /*
    func testConfirmC2BSubscription_Response_Decoding() throws {
       
        // given
        guard let url = bundle.url(forResource: "ConfirmC2BSubscriptionGeneric", withExtension: "json") else {
            XCTFail("testConfirmC2BSubscription_Response_Decoding : Missing file: ConfirmC2BSubscription.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SubscriptionController.ConfirmC2BSubscription.Response(statusCode: .ok, errorMessage: nil, data: .init(operationStatus: .complete, title: "Привязка счета оформлена", brandIcon: "c896aba73a67de2bfc69de70209eb3f3", brandName: "Тестовый ТСП ТИВ", redirectUrl: .init(string: "https://sbp.nspk.ru/test_link_tiv.html")!))
        
        // when
        let result = try decoder.decode(ServerCommands.SubscriptionController.ConfirmC2BSubscription.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    */
    
    //MARK: - DeniedC2BSubscription

    func testDeniedC2BSubscription_Response_Decoding() throws {
       
        // given
        guard let url = bundle.url(forResource: "DeniedC2BSubscriptionGeneric", withExtension: "json") else {
            XCTFail("testDeniedC2BSubscription_Response_Decoding : Missing file: DeniedC2BSubscriptionGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SubscriptionController.DeniedC2BSubscription.Response(statusCode: .ok, errorMessage: nil, data: .init(operationStatus: .rejected, title: "Счет не привязан", brandIcon: "c896aba73a67de2bfc69de70209eb3f3", brandName: "Тестовый ТСП ТИВ", legalName: nil, redirectUrl: .init(string: "https://sbp.nspk.ru/test_link_tiv.html")!))
        
        // when
        let result = try decoder.decode(ServerCommands.SubscriptionController.DeniedC2BSubscription.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetC2BSubscription_Response_Decoding() throws {
       
        // given
        guard let url = bundle.url(forResource: "GetC2BSubscriptionGeneric", withExtension: "json") else {
            XCTFail("testGetC2BSubscription_Response_Decoding : Missing file: GetC2BSubscriptionGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SubscriptionController.GetC2bSubscriptions.Response(
            statusCode: .ok,
            errorMessage: "string",
            data: .init(
                title: "Управление подписками",
                subscriptionType: .empty,
                emptySearch: "Нет совпадений",
                emptyList: ["У Вас нет активных подписок."],
                list: [.init(
                    productId: "10000128973",
                    productType: .account,
                    productTitle: "Счет списания",
                    subscriptions: [.init(
                        subscriptionToken: "999c04f9e51b4911abdd9a32961c763d",
                        brandIcon: "12123344",
                        brandName: "Тестовый ТСП ТИВ",
                        subscriptionPurpose: "Подписка на получение QR для теста 560",
                        cancelAlert: "Вы действительно хотите отключить подписку <brandName>?"
                    )]
                )]
            )
        )
        
        // when
        let result = try decoder.decode(ServerCommands.SubscriptionController.GetC2bSubscriptions.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    func testUpdateC2BSubscription_Response_Decoding() throws {
       
        // given
        let url = try XCTUnwrap(bundle.url(
            forResource: "UpdateC2BSubscriptionGeneric",
            withExtension: "json"
        ))
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SubscriptionController.UpdateC2bSubscriptionCard.Response(
            statusCode: .ok,
            errorMessage: "string",
            data: .init(
                operationStatus: .complete,
                title: "Привязка счета оформлена",
                brandIcon: "12123344",
                brandName: "Тестовый ТСП ТИВ",
                legalName: nil,
                redirectUrl: nil
            )
        )
        
        // when
        let result = try decoder.decode(ServerCommands.SubscriptionController.UpdateC2bSubscriptionCard.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
}

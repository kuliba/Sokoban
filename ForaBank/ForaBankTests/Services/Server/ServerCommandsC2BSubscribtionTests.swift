//
//  ServerCommandsC2BSubscribtionTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 30.01.2023.
//

import XCTest
@testable import ForaBank

class ServerCommandsC2BSubscribtionTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsSPBTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    
    //MARK: - ConfirmC2BSubscription

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
    
    //MARK: - DeniedC2BSubscription

    func testDeniedC2BSubscription_Response_Decoding() throws {
       
        // given
        guard let url = bundle.url(forResource: "DeniedC2BSubscriptionGeneric", withExtension: "json") else {
            XCTFail("testDeniedC2BSubscription_Response_Decoding : Missing file: DeniedC2BSubscriptionGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SubscriptionController.DeniedC2BSubscription.Response(statusCode: .ok, errorMessage: nil, data: .init(operationStatus: .rejected, title: "Счет не привязан", brandIcon: "c896aba73a67de2bfc69de70209eb3f3", brandName: "Тестовый ТСП ТИВ", redirectUrl: .init(string: "https://sbp.nspk.ru/test_link_tiv.html")!))
        
        // when
        let result = try decoder.decode(ServerCommands.SubscriptionController.DeniedC2BSubscription.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}

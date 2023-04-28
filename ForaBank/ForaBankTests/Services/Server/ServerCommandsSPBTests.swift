//
//  ServerCommandsSPBTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 30.01.2023.
//

import XCTest
@testable import ForaBank

class ServerCommandsSPBTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsSPBTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetScenarioQRData

    func testGetScenarioQRData_Response_Decoding() throws {
       
        // given
        guard let url = bundle.url(forResource: "GetScenarioQRDataGeneric", withExtension: "json") else {
            XCTFail("testGetScenarioQRData_Response_Decoding : Missing file: GetScenarioQRDataGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SBPController.GetScenarioQRData.Response(statusCode: .ok, errorMessage: nil, data: .init(scenario: .subscription, qrcId: "AS10006QJQ2789N79JVP19G0KEK4LSGU", parameters: [.init(QRScenarioParameterSubscriber(type: .subscriber, id: "brandName", value: "Кофейня у Артема", icon: "12123344", subscriptionPurpose: "Привязка счета для платежей в пользу АО \"Кофеек\", регулярность раз в месяц, сумма 100 рублей")), .init(QRScenarioParameterProductSelect(type: .productSelect, id: "debit_account", value: nil, title: "Счет списания", filter: .init(productTypes: [.card, .account], currencies: [.rub], additional: false))), .init(QRScenarioParameterCheck(type: .check, id: "terms_check", value: true, link: .init(title: "Включить переводы через СБП,", subtitle: "принять условия обслуживания", url: .init(string: "https://www.forabank.ru/dkbo/dkbo.pdf")!)))], required: ["debit_account"]))
        
        // when
        let result = try decoder.decode(ServerCommands.SBPController.GetScenarioQRData.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}

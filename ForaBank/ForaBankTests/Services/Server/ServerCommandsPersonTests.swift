//
//  ServerCommandsPersonTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 02.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsPersontTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsPersontTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetClientInfo
    
    func testGetClientInfo_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetClientInfoGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PersonController.GetClientInfo.Response(
            statusCode: .ok,
            errorMessage: "string",
            data: .init(
                id: 10002053887,
                lastName: "Иванов",
                firstName: "Иван",
                patronymic: "Иванович",
                birthDay: "1992-04-19",
                regSeries: "1234",
                regNumber: "123456",
                birthPlace: "Г. САМАРА",
                dateOfIssue: "2021-07-19",
                codeDepartment: "630-006",
                regDepartment: "ГУ МВД РОССИИ ПО САМАРСКОЙ ОБЛАСТИ",
                address: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 123456, Московская обл, Мытищи г, Олимпийский пр-кт ,  д. 99,  корп. 1,  кв. 18",
                addressInfo: .init(postIndex: "150522",
                                   country: "РОССИЯ",
                                   area: "Ярославский",
                                   region: "Ярославская",
                                   street: "Ленина",
                                   house: "3", frame: "1", flat: "31"),
                addressResidential: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 123456, Московская обл, Мытищи г, Олимпийский пр-кт ,  д. 99,  корп. 1,  кв. 18",
                addressResidentialInfo: .init(postIndex: "150522",
                                              country: "РОССИЯ",
                                              area: "Ярославский",
                                              region: "Ярославская",
                                              street: "Ленина",
                                              house: "3", frame: "1", flat: "31"),
                phone: "79998887766",
                phoneSMS: "79998887766",
                email: "test@test.com",
                inn: "7723384619",
                customName: nil)
        )
        
        // when
        let result = try decoder.decode(ServerCommands.PersonController.GetClientInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}

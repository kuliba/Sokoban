//
//  QRCodeTests.swift
//  ForaBankTests
//
//  Created by Константин Савялов on 19.10.2022.
//

import XCTest
@testable import ForaBank

class QRCodeTests: XCTestCase {
    
    let bundle = Bundle(for: QRCodeTests.self)
    let decoder = JSONDecoder.serverDate
    let string = """
                 ST00012|Name=ПАО "Калужская сбытовая компания"|PersonalAcc=40702810600180000156|BankName=Тульский филиал АБ "РОССИЯ"|BIC=047003764|CorrespAcc=30101810600000000764|PersAcc=110110581|Sum=66671|Purpose= лс 110110581 ЭЭ|PayeeINN=4029030252|KPP=402801001|TechCode=02|Category=1|KSK_PeriodPok=202208|KSK_Type=1|Amount=6835|Any=123
                 """

    
    func testSeparatorStringCount() throws {
        
        // given
        let expectedCount = 17
        
        // when
        let result = QRCode.separatedString(string: string)
        
        // then
        XCTAssertEqual(result.count, expectedCount)
    }
    
    func testRawDataMapping() throws {
        
        // given
        let separatedString = ["PersonalAcc=40702810600180000156", "BIC=047003764", "CorrespAcc=30101810600000000764", "PersAcc=110110581"]
        
        // when
        let result = QRCode.rawDataMapping(qrStringData: separatedString)
        
        // then
        XCTAssertEqual(result.count, 4)
        XCTAssert(result.keys.contains("personalacc"))
        XCTAssert(result.keys.contains("bic"))
        XCTAssert(result.keys.contains("correspacc"))
        XCTAssert(result.keys.contains("persacc"))
        XCTAssertEqual(result["personalacc"], "40702810600180000156")
        //TODO: other values
    }
    
    func testInit_Correct() {
        
        // when
        let result = QRCode(string: string)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.rawData.keys.count, 16)
        XCTAssertEqual(result?.rawData["name"], "ПАО \"Калужская сбытовая компания\"")
        XCTAssertEqual(result?.rawData["personalacc"], "40702810600180000156")
        XCTAssertEqual(result?.rawData["purpose"], " лс 110110581 ЭЭ")
        //TODO: other values
    }
    
    func testInit_Incorrect() {
        
        // given
        let string = "http://google.com"
        
        // when
        let result = QRCode(string: string)
        
        // then
        XCTAssertNil(result)
    }
    
    func testValue_String() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.inn), keys: ["payeeinn"], type: .string)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["payeeinn": "4029030252"])
        
        // when
        let result: String? = try qrCode.value(type: .general(.inn), mapping: qrMapping)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, "4029030252")
    }
    
    func testValue_Int() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.techcode), keys: ["techcode"], type: .integer)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["techcode": "02"])
        
        // when
        let result: Int? = try qrCode.value(type: .general(.techcode), mapping: qrMapping)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 2)
    }

    //FIXME: double convertion do not work
    /*
    func testResultDoubleValue() throws {
        
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.amount), keys: ["amount", "summ"], type: .double)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["amount": "6835"])
        
        // when
        let result: Double? = try qrCode.value(type: .general(.amount), mapping: qrMapping)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 68.35, accuracy: .ulpOfOne)
    }
     */
    
    func testResultErrorValue() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.techcode), keys: ["techcode"], type: .integer)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["techcode": "02"])
        
        // when
        do {
            let _: Double? = try qrCode.value(type: .general(.techcode), mapping: qrMapping)
            XCTFail()
            
        } catch {
            
            XCTAssert(true)
        }
    }
    
    //FIXME: like testValue_String
    func testStringValue() throws {
        
        guard let url = bundle.url(forResource: "QRMappingJSON", withExtension: "json") else {
            XCTFail()
            return
        }
        let json = try Data(contentsOf: url)
        let qrMapping = try decoder.decode(QRMapping.self, from: json)
        
        // given
        guard let qrCode = QRCode.init(string: string) else {
            XCTFail()
            return
        }
        
        let value = qrCode.stringValue(type: .general(.amount), mapping: qrMapping)
        
        // when
        // 6835
        XCTAssertTrue(value == "6835")
    }
}

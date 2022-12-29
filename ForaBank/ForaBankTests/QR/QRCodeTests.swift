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
}

//MARK: - Init with String

extension QRCodeTests {
    
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
}

//MARK: - String Value

extension QRCodeTests {

    func testStringValue() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.inn), keys: ["payeeinn"], type: .string)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["payeeinn": "4029030252"])
        
        // when
        let result = qrCode.stringValue(type: .general(.inn), mapping: qrMapping)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "4029030252")
    }
}

//MARK: - Value String

extension QRCodeTests {
    
    func testValue_String() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.inn), keys: ["payeeinn"], type: .string)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["payeeinn": "4029030252"])
        
        // when
        let result: String = try qrCode.value(type: .general(.inn), mapping: qrMapping)
        
        // then
        XCTAssertEqual(result, "4029030252")
    }
}

//MARK: - Value Int

extension QRCodeTests {
    
    func test_Value_Int_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.techcode), keys: ["techcode"], type: .integer)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["techcode": "2"])
        
        // when
        let result: Int = try qrCode.value(type: .general(.techcode), mapping: qrMapping)
        
        // then
        XCTAssertEqual(result, 2)
    }
    
    func test_Value_Int_Incorrect() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.techcode), keys: ["techcode"], type: .integer)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["techcode": "200 руб."])
        
        // when
        do {
            
            let _: Int = try qrCode.value(type: .general(.techcode), mapping: qrMapping)
            XCTFail()
            
        } catch {
            
            XCTAssert(true)
        }
    }
}

//MARK: - Value Double

extension QRCodeTests {
    
    func testValue_Double_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.amount), keys: ["amount", "summ"], type: .double)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["amount": "6835"])
        
        // when
        let result: Double = try qrCode.value(type: .general(.amount), mapping: qrMapping)
        
        // then
        XCTAssertEqual(result, 68.35, accuracy: .ulpOfOne)
    }
    
    func testValue_Double_Zero_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.amount), keys: ["amount", "summ"], type: .double)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["amount": "35"])
        
        // when
        let result: Double = try qrCode.value(type: .general(.amount), mapping: qrMapping)
        
        // then
        XCTAssertEqual(result, 0.35, accuracy: .ulpOfOne)
    }
    
    func testValue_Double_Incorrect() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.amount), keys: ["amount", "summ"], type: .double)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["amount": "5"])
        
        // when
        do {
            
            let _: Double = try qrCode.value(type: .general(.amount), mapping: qrMapping)
            XCTFail()
            
        } catch {
            
            XCTAssert(true)
        }
    }
}

//MARK: - Value Date

extension QRCodeTests {
    
    func testValue_Date_Dots_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .value("paymentdate"), keys: ["date"], type: .date)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["date": "01.12.2021"])
        
        // when
        let result: Date = try qrCode.value(type: .value("paymentdate"), mapping: qrMapping)
        
        // then
        let components = Calendar.current.dateComponents([.day, .month, .year], from: result)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.year, 2021)
    }
    
    func testValue_Date_No_Space_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .value("paymentdate"), keys: ["date"], type: .date)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["date": "12072021"])
        
        // when
        let result: Date = try qrCode.value(type: .value("paymentdate"), mapping: qrMapping)
        
        // then
        let components = Calendar.current.dateComponents([.day, .month, .year], from: result)
        XCTAssertEqual(components.day, 12)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.year, 2021)
    }
    
    func testValue_Date_No_Space_Month_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .value("paymentdate"), keys: ["date"], type: .date)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["date": "072021"])
        
        // when
        let result: Date = try qrCode.value(type: .value("paymentdate"), mapping: qrMapping)
        
        // then
        let components = Calendar.current.dateComponents([.day, .month, .year], from: result)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.year, 2021)
    }
    
    func testValue_Date_Slashes_Correct() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .value("paymentdate"), keys: ["date"], type: .date)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["date": "01/12/2021"])
        
        // when
        let result: Date = try qrCode.value(type: .value("paymentdate"), mapping: qrMapping)
        
        // then
        let components = Calendar.current.dateComponents([.day, .month, .year], from: result)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.year, 2021)
    }
    
    func testValue_Date_Incorrect() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .value("paymentdate"), keys: ["date"], type: .date)], operators: [])
        let qrCode = QRCode(original: "", rawData: ["date": "01 декабря 2021"])
        
        // when
        do {
            
            let _: Date = try qrCode.value(type: .value("paymentdate"), mapping: qrMapping)
            
        } catch {
            
            XCTAssert(true)
        }
    }
}

//MARK: - Fail Data

extension QRCodeTests {
    
    func testCheck_FailData() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.inn), keys: ["inn"], type: .string),
                                               .init(parameter: .general(.amount), keys: ["amount"], type: .double)],
                                  operators: [.init(operator: "123", parameters: [.init(parameter: .value("category"), keys: ["v3_category"], type: .string)])])
        let qrCode = QRCode(original: "ST00012|Inn=123456|Amount=2235|V3_Category=Налоги|BIC=987654",
                            rawData: ["inn": "123456", "amount": "2235", "v3_category": "Налоги", "bic": "987654"])
        
        // when
        let result = qrCode.check(mapping: qrMapping)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.unknownKeys, ["bic"])
        XCTAssertEqual(result?.rawData, qrCode.original)
        XCTAssertEqual(result?.parsed.count, 3)
    }
    
    func testCheck_No_FailData() throws {
        
        // given
        let qrMapping = QRMapping(parameters: [.init(parameter: .general(.inn), keys: ["inn"], type: .string),
                                               .init(parameter: .general(.amount), keys: ["amount"], type: .double)],
                                  operators: [.init(operator: "123", parameters: [.init(parameter: .value("category"), keys: ["v3_category"], type: .string)])])
        let qrCode = QRCode(original: "ST00012|Inn=123456|Amount=2235|V3_Category=Налоги",
                            rawData: ["inn": "123456", "amount": "2235", "v3_category": "Налоги"])
        
        // when
        let result = qrCode.check(mapping: qrMapping)
        
        // then
        XCTAssertNil(result)
    }
}


//MARK: - Helpers

extension QRCodeTests {
    
    func testSeparatedString() throws {
        
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
}

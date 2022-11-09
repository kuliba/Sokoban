//
//  QRMappingTests.swift
//  ForaBankTests
//
//  Created by Константин Савялов on 19.10.2022.
//

import XCTest
@testable import ForaBank

class QRMappingTests: XCTestCase {
    
    let bundle = Bundle(for: QRMappingTests.self)
    let decoder = JSONDecoder.serverDate
    
    let string = """
                 ST00012|Name=ПАО "Калужская сбытовая компания"|PersonalAcc=40702810600180000156|BankName=Тульский филиал АБ "РОССИЯ"|BIC=047003764|CorrespAcc=30101810600000000764|PersAcc=110110581|Sum=66671|Purpose= лс 110110581 ЭЭ|PayeeINN=4029030252|KPP=402801001|TechCode=02|Category=1|KSK_PeriodPok=202208|KSK_Type=1|Amount=6835|Any=123
                 """
    
    func testSeparatorStringCount() throws {
        
        // given
        let separatorCount = 16
        
        // when
        let dataArray = QRCode.separatedString(string: string)
        
        // then
        XCTAssertEqual(separatorCount, dataArray.count - 1)
    }
    
    func testRawDataMapping() throws {
        
        // given
        let separatorCount = 16
        let dataArray = QRCode.separatedString(string: string)
        
        // when
        let qrCodeType = QRCode.rawDataMapping(qrStringData: dataArray)
        
        // then
        XCTAssertEqual(separatorCount, qrCodeType.count)
    }
    
    func testResultStringValue() throws {
        
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
        
        // when
        guard let stringValue: String = try qrCode.value(type: .general(.inn), mapping: qrMapping) else {
            
            XCTFail()
            return
        }
        
        // then
        let stringResult  = type(of: stringValue)
        
        XCTAssertTrue(stringResult == String.self)
    }
    
    func testResultIntegerValue() throws {
        
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
        
        // when
        guard let integerValue: Int = try qrCode.value(type: .general(.techcode), mapping: qrMapping) else {
            
            XCTFail()
            return
        }
        
        // then
        let integerResult = type(of: integerValue)
        
        XCTAssertTrue(integerResult == Int.self)
    }
    
    func testResultDoubleValue() throws {
        
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
        
        // when
        guard let doubleValue: Double = try qrCode.value(type: .general(.amount), mapping: qrMapping) else {
            
            XCTFail()
            return
        }
        
        // then
        let doubleResult  = type(of: doubleValue)
        
        XCTAssertTrue(doubleResult == Double.self)
    }
    
    func testResultErrorValue() throws {
        
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
        
        // when
        do {
            guard let _: Double = try qrCode.value(type: .general(.techcode), mapping: qrMapping) else {
                XCTFail()
                return
            }
            
        } catch QRCodeError.typeMissmatch {
            print("QRMappingError")
            return
        }
    }
    
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
    
    func testCheck() throws {
        
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
        
        let value = qrCode.check(mapping: qrMapping)
        
        // when
        // Any=123
        
        XCTAssertNotNil(value)
        
    }
}

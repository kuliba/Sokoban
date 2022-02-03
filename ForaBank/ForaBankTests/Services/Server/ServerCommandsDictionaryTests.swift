//
//  ServerCommandsDictionaryTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 01.02.2022.
//

import Foundation

import XCTest
@testable import ForaBank

class ServerCommandsDictionaryTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsDictionaryTests.self)
    let decoder = JSONDecoder.serverDate
    
    //MARK: - GetAnywayOperatorsList
    
    func testGetAnywayOperatorsList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAnywayOperatorsListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetAnywayOperatorsList_Response_Decoding : Missing file: GetAnywayOperatorsListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let anywayOperatorGroupData = ServerCommands.DictionaryController.GetAnywayOperatorsList.Response.AnywayOperatorGroupData(operatorGroupList: [.init(city: "Москва", code: "iFora||1011001", isGroup: true, logotypeList: [.init(content: "string", contentType: "string", name: "Лого Газпром.png", svgImage: SVGImageData(description: "string"))], name: "Мобильная связь", operators: [.init(city: "Москва", code: "iFora||4285", isGroup: false, logotypeList: [.init(content: "string", contentType: "string", name: "Лого Газпром.png", svgImage: SVGImageData(description: "string"))], name: "Билайн", parameterList: [.init(content: "account", dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: "+7(___)-___-__-__", maxLength: 10, minLength: 0, order: 2, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: "Пример: 9051111111", title: "Номер телефона +7", type: "Input", svgImage: SVGImageData(description: "string"), viewType: .input)], parentCode: "iFora||1011001", region: "Пермский край", synonymList: ["string"])], region: "Пермский край", synonymList: ["string"])], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetAnywayOperatorsList.Response(statusCode: .ok, errorMessage: "string", data: anywayOperatorGroupData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetAnywayOperatorsList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetAnywayOperatorsList_Response_Decoding_Min() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAnywayOperatorGroupDataGenericMin", withExtension: "json") else {
            XCTFail("testGetAnywayOperatorGroupDataGenericMin_Response_Decoding : Missing file: GetAnywayOperatorGroupDataGenericMin.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let anywayOperatorGroupData = ServerCommands.DictionaryController.GetAnywayOperatorsList.Response.AnywayOperatorGroupData(operatorGroupList: [.init(city: nil, code: "iFora||1011001", isGroup: true, logotypeList: [.init(content: "string", contentType: "string", name: "Лого Газпром.png", svgImage: SVGImageData(description: "string"))], name: "Мобильная связь", operators: [.init(city: nil,code: "iFora||4285", isGroup: false, logotypeList: [.init(content: "string", contentType: "string", name: "Лого Газпром.png", svgImage: SVGImageData(description: "string"))], name: "Билайн", parameterList: [.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: nil, isRequired: true, mask: "+7(___)-___-__-__", maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "Input", svgImage: nil, viewType: .input)], parentCode: "iFora||1011001", region: nil, synonymList: ["string"])], region: nil, synonymList: ["string"])], serial: "bea36075a58954199a6b8980549f6b69")

        let expected = ServerCommands.DictionaryController.GetAnywayOperatorsList.Response(statusCode: .ok, errorMessage: "string", data: anywayOperatorGroupData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetAnywayOperatorsList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetBanks
    
    func testGetBanks_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetBanksResponseGeneric", withExtension: "json") else {
            XCTFail("testGetBanks_Response_Decoding : Missing file: GetBanksResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let bankListData = ServerCommands.DictionaryController.GetBanks.Response.BankListData(banksList: [.init(md5hash: "257108d9f58bc12ece63986ba17428eb", memberId: "100000000001", memberName: "Gazprombank", memberNameRus: "Газпромбанк", paymentSystemCodeList: ["string"], svgImage: SVGImageData(description: "string"))], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetBanks.Response(statusCode: .ok, errorMessage: "string", data: bankListData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetBanks.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetBanks_Response_Decoding_Min() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetBanksResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetBanks_Response_Decoding_Min : Missing file: GetBanksResponseGenericMin.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let bankListData = ServerCommands.DictionaryController.GetBanks.Response.BankListData(banksList: [.init(md5hash: "257108d9f58bc12ece63986ba17428eb", memberId: nil, memberName: nil, memberNameRus: "Газпромбанк", paymentSystemCodeList: ["string"], svgImage: SVGImageData(description: "string"))], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetBanks.Response(statusCode: .ok, errorMessage: "string", data: bankListData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetBanks.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetCountries
    
    func testGetCountries_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetCountriesResponseGeneric", withExtension: "json") else {
            XCTFail("testGetCountries_Response_Decoding : Missing file: GetCountriesResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let countryData = ServerCommands.DictionaryController.GetCountries.Response.CountryData(countriesList: [.init(code: "AM", contactCode: "BTOC", md5hash: "string", name: "АРМЕНИЯ", paymentSystemIdList: ["string"], sendCurr: "EUR;USD;RUR;", svgImage: SVGImageData(description: "string"))], serial: "bea36075a58954199a6b8980549f6b69")
        
        
        let expected = ServerCommands.DictionaryController.GetCountries.Response(statusCode: .ok, errorMessage: "string", data: countryData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetCountries.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetCountries_Response_Decoding_Min() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetCountriesResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetCountries_Response_Decoding_Min : Missing file: GetCountriesResponseGenericMin.json")
            return
        }
        let json = try Data(contentsOf: url)
        let countryData = ServerCommands.DictionaryController.GetCountries.Response.CountryData(countriesList: [.init(code: "AM", contactCode: nil, md5hash: nil, name: "АРМЕНИЯ", paymentSystemIdList: ["string"], sendCurr: "EUR;USD;RUR;", svgImage: nil)], serial: "bea36075a58954199a6b8980549f6b69")
        
        
        let expected = ServerCommands.DictionaryController.GetCountries.Response(statusCode: .ok, errorMessage: "string", data: countryData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetCountries.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetCurrencyList
    
    func testGetCurrencyList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetCurrencyListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetCurrencyList_Response_Decoding : Missing file: GetCurrencyListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let currencyData = ServerCommands.DictionaryController.GetCurrencyList.Response.CurrencyListData(currencyList: [.init(code: "USD", codeISO: 840, codeNumeric: 840, cssCode: "\\062F\\002E\\0625", htmlCode: "&#1583;.&#1573;", id: "1", name: "Доллар США", unicode: "U+062F\\U+002E\\U+0625")], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetCurrencyList.Response(statusCode: .ok, errorMessage: "string", data: currencyData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetCurrencyList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetCurrencyList_Response_Decoding_Min() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetCurrencyListResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetCurrencyList_Response_Decoding_Min : Missing file: GetCurrencyListResponseGenericMin.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let currencyData = ServerCommands.DictionaryController.GetCurrencyList.Response.CurrencyListData(currencyList: [.init(code: "USD", codeISO: 840, codeNumeric: 840, cssCode: nil, htmlCode: nil, id: "1", name: "Доллар США", unicode: nil)], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetCurrencyList.Response(statusCode: .ok, errorMessage: "string", data: currencyData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetCurrencyList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetFMSList
    
    func testGetFMSList_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetFMSListResponseGeneric", withExtension: "json")!
        
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.DictionaryController.GetFMSList.Response(statusCode: .ok, errorMessage: "string", data: .init(fmsList: [.init(md5hash: "366e1c4043eb433b82a6ab4988e80862", svgImage: .init(description: "string"), text: "Российский паспорт", value: "1")], serial: "bea36075a58954199a6b8980549f6b69"))
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetFMSList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetFSSPList
    
    func testGetFSSPList_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetFSSPListResponseGeneric", withExtension: "json")!
        
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.DictionaryController.GetFSSPList.Response(statusCode: .ok, errorMessage: "string", data: .init(fsspList: [.init(md5hash: "366e1c4043eb433b82a6ab4988e80862", svgImage: .init(description: "string"), text: "Паспорт РФ", value: "20")], serial: "bea36075a58954199a6b8980549f6b69"))
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetFSSPList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetFTSList
    
    func testGetFTSList_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetFTSListResponseGeneric", withExtension: "json")!
        
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.DictionaryController.GetFTSList.Response(statusCode: .ok, errorMessage: "string", data: .init(ftsList: [.init(md5hash: "366e1c4043eb433b82a6ab4988e80862", svgImage: .init(description: "string"), text: "Имущественный налог", value: "1")], serial: "bea36075a58954199a6b8980549f6b69"))
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetFTSList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetFullBankInfoList
    
    func testGetFullBankInfoList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetFullBankInfoListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetFullBankInfoList_Response_Decoding : Missing file: GetFullBankInfoListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let bankFullInfoData = ServerCommands.DictionaryController.GetFullBankInfoList.Response.BankFullInfoData(bankFullInfoList: [.init(accountList: [.init(cbrbic: "044525000", account: "30101810145250000974", ck: "37", dateIn: "16.06.2016 00:00:00", dateOut: "16.06.2016 00:00:00", regulationAccountType: "CRSA", status: "ACAC")], address: "127287, г Москва, Ул. 2-я Хуторская, д.38А, стр.26", bankServiceType: "Сервис срочного перевода и сервис быстрых платежей", bankServiceTypeCode: "5", bankType: "20", bankTypeCode: "Кредитная организация", bic: "044525974", engName: "TINKOFF BANK", fiasId: "string", fullName: "АО \"ТИНЬКОФФ БАНК\"", inn: "string", kpp: "string", latitude: 0, longitude: 0, md5hash: "a97d3153c1172f0c5333c9eadb5696f3", memberId: "100000000004", name: "Tinkoff Bank", receiverList: ["string"], registrationDate: "16.06.2016 00:00:00", registrationNumber: "2673", rusName: "Тинькофф Банк", senderList: ["string"], svgImage: SVGImageData(description: "string"), swiftList: [.init(default: true, swift: "TICSRUMMXXX")])], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetFullBankInfoList.Response(statusCode: .ok, errorMessage: "string", data: bankFullInfoData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetFullBankInfoList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetFullBankInfoList_Response_Decoding_Min() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetFullBankInfoListResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetFullBankInfoList_Response_Decoding_Min : Missing file: GetFullBankInfoListResponseGenericMin.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let bankFullInfoData = ServerCommands.DictionaryController.GetFullBankInfoList.Response.BankFullInfoData(bankFullInfoList: [.init(accountList: [.init(cbrbic: "044525000", account: "30101810145250000974", ck: "37", dateIn: "16.06.2016 00:00:00", dateOut: nil, regulationAccountType: "CRSA", status: "ACAC")], address: "127287, г Москва, Ул. 2-я Хуторская, д.38А, стр.26", bankServiceType: "Сервис срочного перевода и сервис быстрых платежей", bankServiceTypeCode: "5", bankType: "20", bankTypeCode: "Кредитная организация", bic: "044525974", engName: "TINKOFF BANK", fiasId: nil, fullName: "АО \"ТИНЬКОФФ БАНК\"", inn: nil, kpp: nil, latitude: nil, longitude: nil, md5hash: "a97d3153c1172f0c5333c9eadb5696f3", memberId: nil, name: nil, receiverList: ["string"], registrationDate: "16.06.2016 00:00:00", registrationNumber: nil, rusName: "Тинькофф Банк", senderList: ["string"], svgImage: SVGImageData(description: "string"), swiftList: [.init(default: nil, swift: "TICSRUMMXXX")])], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetFullBankInfoList.Response(statusCode: .ok, errorMessage: "string", data: bankFullInfoData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetFullBankInfoList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetMobileData
    
    func testGetMobileData_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetMobileDataResponseGeneric", withExtension: "json") else {
            XCTFail("testGetMobileData_Response_Decoding : Missing file: GetMobileDataResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let mobileData = ServerCommands.DictionaryController.GetMobileList.Response.MobileData(mobileList: [.init(code: "BEELINE", md5hash: "2a025e81e19ddc447cc93d27ad75ff84", providerName: "ПАО \"Вымпел-Коммуникации\"", puref: "iFora||4285", shortName: "Билайн", svgImage: SVGImageData(description: "string"))], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetMobileList.Response(statusCode: .ok, errorMessage: "string", data: mobileData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetMobileList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetMosParkingList
    
    func testGetMosParkingList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetMosParkingListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetMosParkingList_Response_Decoding : Missing file: GetMosParkingListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let mosParkingData = ServerCommands.DictionaryController.GetMosParkingList.Response.MosParkingData(mosParkingList: [.init(default: true, groupName: "Годовая", md5hash: "366e1c4043eb433b82a6ab4988e80862", svgImage: SVGImageData(description: "string"), text: "От внешней стороны Садового кольца до границ г. Москвы", value: "23")], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetMosParkingList.Response(statusCode: .ok, errorMessage: "string", data: mosParkingData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetMosParkingList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetMosParkingList_Response_Decoding_Min() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetMosParkingListResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetMosParkingList_Response_Decoding_Min : Missing file: GetMosParkingListResponseGenericMin.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let mosParkingData = ServerCommands.DictionaryController.GetMosParkingList.Response.MosParkingData(mosParkingList: [.init(default: nil, groupName: "Годовая", md5hash: nil, svgImage: nil, text: nil, value: "23")], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetMosParkingList.Response(statusCode: .ok, errorMessage: "string", data: mosParkingData)
        
        // when
        let result = try decoder.decode(ServerCommands.DictionaryController.GetMosParkingList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetPaymentSystemList
    
    func testGetPaymentSystemList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetPaymentSystemListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetPaymentSystemList_Response_Decoding : Missing file: GetPaymentSystemListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        var purefData = [["additionalProp1": [PaymentSystemDataItem.PurefData(puref: "iFora||Addressless", type: "addressless")],"additionalProp2": [PaymentSystemDataItem.PurefData(puref: "iFora||Addressless", type: "addressless")],"additionalProp3": [PaymentSystemDataItem.PurefData(puref: "iFora||Addressless", type: "addressless")]]]
        purefData.sort(by: {$0.first?.key ?? "" < $1.first?.key ?? ""})
        
        let paymentSystemData = ServerCommands.DictionaryController.GetPaymentSystemList.Response.PaymentSystemData(paymentSystemList: [.init(code: "CONTACT", md5hash: "178a385607bc45fc30bd66573d4d2c67", name: "Contact", purefList: purefData, svgImage: .init(description: "string"))], serial: "bea36075a58954199a6b8980549f6b69")
        
        let expected = ServerCommands.DictionaryController.GetPaymentSystemList.Response(statusCode: .ok, errorMessage: "string", data: paymentSystemData)
        
        // when
        var result = try decoder.decode(ServerCommands.DictionaryController.GetPaymentSystemList.Response.self, from: json)
        result.data?.paymentSystemList[0].purefList?.sort(by: {$0.first?.key ?? "" > $1.first?.key ?? ""})
        
        // then
        XCTAssertEqual(result, expected)
    }
}

//
//  ServerCommandsSuggestTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

import XCTest
@testable import ForaBank

class ServerCommandsSuggestTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsSuggestTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - SuggestBank
    
    func testSuggestBank_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "SuggestBankGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.SuggestController.SuggestBank.Response(statusCode: .ok, errorMessage: "string", data: [.init(data: .init(address: .init(data: .init(area: "string", areaFiasId: "string", areaKladrId: "string", areaType: "string", areaTypeFull: "string", areaWithType: "string", beltwayDistance: "string", beltwayHit: "string", block: "string", blockType: "string", blockTypeFull: "string", capitalMarker: "string", city: "string", cityArea: "string", cityDistrict: "string", cityDistrictFiasId: "string", cityDistrictKladrId: "string", cityDistrictType: "string", cityDistrictTypeFull: "string", cityDistrictWithType: "string", cityFiasId: "string", cityKladrId: "string", cityType: "string", cityTypeFull: "string", cityWithType: "string", country: "string", countryIsoCode: "string", federalDistrict: "string", fiasActualityState: "string", fiasCode: "string", fiasId: "string", fiasLevel: "string", flat: "string", flatArea: "string", flatPrice: "string", flatType: "string", flatTypeFull: "string", geoLat: "string", geoLon: "string", geonameId: "string", historyValues: "string", house: "string", houseFiasId: "string", houseKladrId: "string", houseType: "string", houseTypeFull: "string", kladrId: "string", metro: [.init(distance: "string", line: "string", name: "string")], okato: "string", oktmo: "string", postalBox: "string", postalCode: "string", qc: "string", qcComplete: "string", qcGeo: "string", qcHouse: "string", region: "string", regionFiasId: "string", regionIsoCode: "string", regionKladrId: "string", regionType: "string", regionTypeFull: "string", regionWithType: "string", settlement: "string", settlementFiasId: "string", settlementKladrId: "string", settlementType: "string", settlementTypeFull: "string", settlementWithType: "string", source: "string", squareMeterPrice: "string", street: "string", streetFiasId: "string", streetKladrId: "string", streetType: "string", streetTypeFull: "string", streetWithType: "string", taxOffice: "string", taxOfficeLegal: "string", timezone: "string", unparsedParts: "string"), unrestrictedValue: "string", value: "string"), bic: "string", correspondentAccount: "string", name: .init(full: "string", payment: "string", short: "string"), okpo: "string", opf: .init(full: "string", short: "string", type: "string"), paymentCity: "string", phones: "string", registrationNumber: "string", state: .init(actualityDate: "string", liquidationDate: "string", registrationDate: "string", status: "string"), swift: "string"), unrestrictedValue: "string", value: "string")])
        
        // when
        let result = try decoder.decode(ServerCommands.SuggestController.SuggestBank.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testSuggestBank_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "SuggestBankGenericMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.SuggestController.SuggestBank.Response(statusCode: .ok, errorMessage: "string", data: [.init(data: .init(address: nil, bic: nil, correspondentAccount: nil, name: nil, okpo: nil, opf: nil, paymentCity: nil, phones: nil, registrationNumber: nil, state: nil, swift: nil), unrestrictedValue: nil, value: nil)])
        
        // when
        let result = try decoder.decode(ServerCommands.SuggestController.SuggestBank.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - SuggestCompany
    
    func testSuggestCompany_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "SuggestCompanyGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.SuggestController.SuggestCompany.Response(statusCode: .ok, errorMessage: "string", data: [.init(data: .init(address: .init(data: .init(area: "string", areaFiasId: "string", areaKladrId: "string", areaType: "string", areaTypeFull: "string", areaWithType: "string", beltwayDistance: "string", beltwayHit: "string", block: "string", blockType: "string", blockTypeFull: "string", capitalMarker: "string", city: "string", cityArea: "string", cityDistrict: "string", cityDistrictFiasId: "string", cityDistrictKladrId: "string", cityDistrictType: "string", cityDistrictTypeFull: "string", cityDistrictWithType: "string", cityFiasId: "string", cityKladrId: "string", cityType: "string", cityTypeFull: "string", cityWithType: "string", country: "string", countryIsoCode: "string", federalDistrict: "string", fiasActualityState: "string", fiasCode: "string", fiasId: "string", fiasLevel: "string", flat: "string", flatArea: "string", flatPrice: "string", flatType: "string", flatTypeFull: "string", geoLat: "string", geoLon: "string", geonameId: "string", historyValues: "string", house: "string", houseFiasId: "string", houseKladrId: "string", houseType: "string", houseTypeFull: "string", kladrId: "string", metro: [.init(distance: "string", line: "string", name: "string")], okato: "string", oktmo: "string", postalBox: "string", postalCode: "string", qc: "string", qcComplete: "string", qcGeo: "string", qcHouse: "string", region: "string", regionFiasId: "string", regionIsoCode: "string", regionKladrId: "string", regionType: "string", regionTypeFull: "string", regionWithType: "string", settlement: "string", settlementFiasId: "string", settlementKladrId: "string", settlementType: "string", settlementTypeFull: "string", settlementWithType: "string", source: "string", squareMeterPrice: "string", street: "string", streetFiasId: "string", streetKladrId: "string", streetType: "string", streetTypeFull: "string", streetWithType: "string", taxOffice: "string", taxOfficeLegal: "string", timezone: "string", unparsedParts: "string"), unrestrictedValue: "string", value: "string"), authorities: "string", branchCount: "string", branchType: "string", capital: "string", documents: "string", emails: "string", employeeCount: "string", finance: .init(debt: "string", expense: "string", income: "string", penalty: "string", taxSystem: "string"), founders: "string", hid: "string", inn: "string", kpp: "string", licenses: "string", management: .init(disqualified: "string", name: "string", post: "string"), managers: "string", name: .init(full: "string", fullWithOpf: "string", latin: "string", short: "string", shortWithOpf: "string"), ogrn: "string", ogrnDate: "string", okpo: "string", okved: "string", okvedType: "string", okveds: "string", opf: .init(code: "string", full: "string", short: "string", type: "string"), phones: "string", qc: "string", source: "string", state: .init(actualityDate: "string", liquidationDate: "string", registrationDate: "string", status: "string"), type: "string"), unrestrictedValue: "string", value: "string")])
        
        // when
        let result = try decoder.decode(ServerCommands.SuggestController.SuggestCompany.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testSuggestCompany_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "SuggestCompanyGenericMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.SuggestController.SuggestCompany.Response(statusCode: .ok, errorMessage: "string", data: [.init(data: .init(address: nil, authorities: nil, branchCount: nil, branchType: nil, capital: nil, documents: nil, emails: nil, employeeCount: nil, finance: nil, founders: nil, hid: nil, inn: nil, kpp: nil, licenses: nil, management: nil, managers: nil, name: nil, ogrn: nil, ogrnDate: nil, okpo: nil, okved: nil, okvedType: nil, okveds: nil, opf: nil, phones: nil, qc: nil, source: nil, state: nil, type: nil), unrestrictedValue: nil, value: nil)])
        
        // when
        let result = try decoder.decode(ServerCommands.SuggestController.SuggestCompany.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}

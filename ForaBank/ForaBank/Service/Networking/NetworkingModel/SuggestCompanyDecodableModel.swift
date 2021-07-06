//
//  SuggestCompanyDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.07.2021.
//

import Foundation

// MARK: - SuggestCompanyDecodableModel
struct SuggestCompanyDecodableModel: Codable, NetworkModelProtocol {
    let data: [SuggestCompanyDatum]?
    let errorMessage: String?
    let statusCode: Int?
}

// MARK: SuggestCompanyDecodableModel convenience initializers and mutators

extension SuggestCompanyDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyDecodableModel.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        data: [SuggestCompanyDatum]?? = nil,
        errorMessage: String?? = nil,
        statusCode: Int?? = nil
    ) -> SuggestCompanyDecodableModel {
        return SuggestCompanyDecodableModel(
            data: data ?? self.data,
            errorMessage: errorMessage ?? self.errorMessage,
            statusCode: statusCode ?? self.statusCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SuggestCompanyDatum
struct SuggestCompanyDatum: Codable {
    let data: SuggestCompanyDatumData?
    let unrestrictedValue, value: String?
}

// MARK: Datum convenience initializers and mutators

extension SuggestCompanyDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyDatum.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        data: SuggestCompanyDatumData?? = nil,
        unrestrictedValue: String?? = nil,
        value: String?? = nil
    ) -> SuggestCompanyDatum {
        return SuggestCompanyDatum(
            data: data ?? self.data,
            unrestrictedValue: unrestrictedValue ?? self.unrestrictedValue,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


// MARK: - SuggestCompanyDatumData
struct SuggestCompanyDatumData: Codable {
    let address: SuggestCompanyAddress?
    let authorities, branchCount, branchType, capital: String?
    let documents, emails, employeeCount: String?
    let finance: SuggestCompanyFinance?
    let founders, hid, inn, kpp: String?
    let licenses: String?
    let management: SuggestCompanyManagement?
    let managers: String?
    let name: SuggestCompanyName?
    let ogrn, ogrnDate, okpo, okved: String?
    let okvedType, okveds: String?
    let opf: SuggestCompanyOpf?
    let phones, qc, source: String?
    let state: SuggestCompanyState?
    let type: String?
}

// MARK: DatumData convenience initializers and mutators

extension SuggestCompanyDatumData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyDatumData.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        address: SuggestCompanyAddress?? = nil,
        authorities: String?? = nil,
        branchCount: String?? = nil,
        branchType: String?? = nil,
        capital: String?? = nil,
        documents: String?? = nil,
        emails: String?? = nil,
        employeeCount: String?? = nil,
        finance: SuggestCompanyFinance?? = nil,
        founders: String?? = nil,
        hid: String?? = nil,
        inn: String?? = nil,
        kpp: String?? = nil,
        licenses: String?? = nil,
        management: SuggestCompanyManagement?? = nil,
        managers: String?? = nil,
        name: SuggestCompanyName?? = nil,
        ogrn: String?? = nil,
        ogrnDate: String?? = nil,
        okpo: String?? = nil,
        okved: String?? = nil,
        okvedType: String?? = nil,
        okveds: String?? = nil,
        opf: SuggestCompanyOpf?? = nil,
        phones: String?? = nil,
        qc: String?? = nil,
        source: String?? = nil,
        state: SuggestCompanyState?? = nil,
        type: String?? = nil
    ) -> SuggestCompanyDatumData {
        return SuggestCompanyDatumData(
            address: address ?? self.address,
            authorities: authorities ?? self.authorities,
            branchCount: branchCount ?? self.branchCount,
            branchType: branchType ?? self.branchType,
            capital: capital ?? self.capital,
            documents: documents ?? self.documents,
            emails: emails ?? self.emails,
            employeeCount: employeeCount ?? self.employeeCount,
            finance: finance ?? self.finance,
            founders: founders ?? self.founders,
            hid: hid ?? self.hid,
            inn: inn ?? self.inn,
            kpp: kpp ?? self.kpp,
            licenses: licenses ?? self.licenses,
            management: management ?? self.management,
            managers: managers ?? self.managers,
            name: name ?? self.name,
            ogrn: ogrn ?? self.ogrn,
            ogrnDate: ogrnDate ?? self.ogrnDate,
            okpo: okpo ?? self.okpo,
            okved: okved ?? self.okved,
            okvedType: okvedType ?? self.okvedType,
            okveds: okveds ?? self.okveds,
            opf: opf ?? self.opf,
            phones: phones ?? self.phones,
            qc: qc ?? self.qc,
            source: source ?? self.source,
            state: state ?? self.state,
            type: type ?? self.type
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


// MARK: - SuggestCompany
struct SuggestCompanyAddress: Codable {
    let data: AddressData?
    let unrestrictedValue, value: String?
}

// MARK: Address convenience initializers and mutators

extension SuggestCompanyAddress {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyAddress.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        data: AddressData?? = nil,
        unrestrictedValue: String?? = nil,
        value: String?? = nil
    ) -> SuggestCompanyAddress {
        return SuggestCompanyAddress(
            data: data ?? self.data,
            unrestrictedValue: unrestrictedValue ?? self.unrestrictedValue,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

import Foundation

// MARK: - AddressData
struct SuggestCompanyAddressData: Codable {
    let area, areaFiasID, areaKladrID, areaType: String?
    let areaTypeFull, areaWithType, beltwayDistance, beltwayHit: String?
    let block, blockType, blockTypeFull, capitalMarker: String?
    let city, cityArea, cityDistrict, cityDistrictFiasID: String?
    let cityDistrictKladrID, cityDistrictType, cityDistrictTypeFull, cityDistrictWithType: String?
    let cityFiasID, cityKladrID, cityType, cityTypeFull: String?
    let cityWithType, country, countryISOCode, federalDistrict: String?
    let fiasActualityState, fiasCode, fiasID, fiasLevel: String?
    let flat, flatArea, flatPrice, flatType: String?
    let flatTypeFull, geoLat, geoLon, geonameID: String?
    let historyValues, house, houseFiasID, houseKladrID: String?
    let houseType, houseTypeFull, kladrID: String?
    let metro: [Metro]?
    let okato, oktmo, postalBox, postalCode: String?
    let qc, qcComplete, qcGeo, qcHouse: String?
    let region, regionFiasID, regionISOCode, regionKladrID: String?
    let regionType, regionTypeFull, regionWithType, settlement: String?
    let settlementFiasID, settlementKladrID, settlementType, settlementTypeFull: String?
    let settlementWithType, source, squareMeterPrice, street: String?
    let streetFiasID, streetKladrID, streetType, streetTypeFull: String?
    let streetWithType, taxOffice, taxOfficeLegal, timezone: String?
    let unparsedParts: String?

    enum CodingKeys: String, CodingKey {
        case area
        case areaFiasID = "areaFiasId"
        case areaKladrID = "areaKladrId"
        case areaType, areaTypeFull, areaWithType, beltwayDistance, beltwayHit, block, blockType, blockTypeFull, capitalMarker, city, cityArea, cityDistrict
        case cityDistrictFiasID = "cityDistrictFiasId"
        case cityDistrictKladrID = "cityDistrictKladrId"
        case cityDistrictType, cityDistrictTypeFull, cityDistrictWithType
        case cityFiasID = "cityFiasId"
        case cityKladrID = "cityKladrId"
        case cityType, cityTypeFull, cityWithType, country
        case countryISOCode = "countryIsoCode"
        case federalDistrict, fiasActualityState, fiasCode
        case fiasID = "fiasId"
        case fiasLevel, flat, flatArea, flatPrice, flatType, flatTypeFull, geoLat, geoLon
        case geonameID = "geonameId"
        case historyValues, house
        case houseFiasID = "houseFiasId"
        case houseKladrID = "houseKladrId"
        case houseType, houseTypeFull
        case kladrID = "kladrId"
        case metro, okato, oktmo, postalBox, postalCode, qc, qcComplete, qcGeo, qcHouse, region
        case regionFiasID = "regionFiasId"
        case regionISOCode = "regionIsoCode"
        case regionKladrID = "regionKladrId"
        case regionType, regionTypeFull, regionWithType, settlement
        case settlementFiasID = "settlementFiasId"
        case settlementKladrID = "settlementKladrId"
        case settlementType, settlementTypeFull, settlementWithType, source, squareMeterPrice, street
        case streetFiasID = "streetFiasId"
        case streetKladrID = "streetKladrId"
        case streetType, streetTypeFull, streetWithType, taxOffice, taxOfficeLegal, timezone, unparsedParts
    }
}

// MARK: AddressData convenience initializers and mutators

extension SuggestCompanyAddressData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyAddressData.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        area: String?? = nil,
        areaFiasID: String?? = nil,
        areaKladrID: String?? = nil,
        areaType: String?? = nil,
        areaTypeFull: String?? = nil,
        areaWithType: String?? = nil,
        beltwayDistance: String?? = nil,
        beltwayHit: String?? = nil,
        block: String?? = nil,
        blockType: String?? = nil,
        blockTypeFull: String?? = nil,
        capitalMarker: String?? = nil,
        city: String?? = nil,
        cityArea: String?? = nil,
        cityDistrict: String?? = nil,
        cityDistrictFiasID: String?? = nil,
        cityDistrictKladrID: String?? = nil,
        cityDistrictType: String?? = nil,
        cityDistrictTypeFull: String?? = nil,
        cityDistrictWithType: String?? = nil,
        cityFiasID: String?? = nil,
        cityKladrID: String?? = nil,
        cityType: String?? = nil,
        cityTypeFull: String?? = nil,
        cityWithType: String?? = nil,
        country: String?? = nil,
        countryISOCode: String?? = nil,
        federalDistrict: String?? = nil,
        fiasActualityState: String?? = nil,
        fiasCode: String?? = nil,
        fiasID: String?? = nil,
        fiasLevel: String?? = nil,
        flat: String?? = nil,
        flatArea: String?? = nil,
        flatPrice: String?? = nil,
        flatType: String?? = nil,
        flatTypeFull: String?? = nil,
        geoLat: String?? = nil,
        geoLon: String?? = nil,
        geonameID: String?? = nil,
        historyValues: String?? = nil,
        house: String?? = nil,
        houseFiasID: String?? = nil,
        houseKladrID: String?? = nil,
        houseType: String?? = nil,
        houseTypeFull: String?? = nil,
        kladrID: String?? = nil,
        metro: [Metro]?? = nil,
        okato: String?? = nil,
        oktmo: String?? = nil,
        postalBox: String?? = nil,
        postalCode: String?? = nil,
        qc: String?? = nil,
        qcComplete: String?? = nil,
        qcGeo: String?? = nil,
        qcHouse: String?? = nil,
        region: String?? = nil,
        regionFiasID: String?? = nil,
        regionISOCode: String?? = nil,
        regionKladrID: String?? = nil,
        regionType: String?? = nil,
        regionTypeFull: String?? = nil,
        regionWithType: String?? = nil,
        settlement: String?? = nil,
        settlementFiasID: String?? = nil,
        settlementKladrID: String?? = nil,
        settlementType: String?? = nil,
        settlementTypeFull: String?? = nil,
        settlementWithType: String?? = nil,
        source: String?? = nil,
        squareMeterPrice: String?? = nil,
        street: String?? = nil,
        streetFiasID: String?? = nil,
        streetKladrID: String?? = nil,
        streetType: String?? = nil,
        streetTypeFull: String?? = nil,
        streetWithType: String?? = nil,
        taxOffice: String?? = nil,
        taxOfficeLegal: String?? = nil,
        timezone: String?? = nil,
        unparsedParts: String?? = nil
    ) -> SuggestCompanyAddressData {
        return SuggestCompanyAddressData(
            area: area ?? self.area,
            areaFiasID: areaFiasID ?? self.areaFiasID,
            areaKladrID: areaKladrID ?? self.areaKladrID,
            areaType: areaType ?? self.areaType,
            areaTypeFull: areaTypeFull ?? self.areaTypeFull,
            areaWithType: areaWithType ?? self.areaWithType,
            beltwayDistance: beltwayDistance ?? self.beltwayDistance,
            beltwayHit: beltwayHit ?? self.beltwayHit,
            block: block ?? self.block,
            blockType: blockType ?? self.blockType,
            blockTypeFull: blockTypeFull ?? self.blockTypeFull,
            capitalMarker: capitalMarker ?? self.capitalMarker,
            city: city ?? self.city,
            cityArea: cityArea ?? self.cityArea,
            cityDistrict: cityDistrict ?? self.cityDistrict,
            cityDistrictFiasID: cityDistrictFiasID ?? self.cityDistrictFiasID,
            cityDistrictKladrID: cityDistrictKladrID ?? self.cityDistrictKladrID,
            cityDistrictType: cityDistrictType ?? self.cityDistrictType,
            cityDistrictTypeFull: cityDistrictTypeFull ?? self.cityDistrictTypeFull,
            cityDistrictWithType: cityDistrictWithType ?? self.cityDistrictWithType,
            cityFiasID: cityFiasID ?? self.cityFiasID,
            cityKladrID: cityKladrID ?? self.cityKladrID,
            cityType: cityType ?? self.cityType,
            cityTypeFull: cityTypeFull ?? self.cityTypeFull,
            cityWithType: cityWithType ?? self.cityWithType,
            country: country ?? self.country,
            countryISOCode: countryISOCode ?? self.countryISOCode,
            federalDistrict: federalDistrict ?? self.federalDistrict,
            fiasActualityState: fiasActualityState ?? self.fiasActualityState,
            fiasCode: fiasCode ?? self.fiasCode,
            fiasID: fiasID ?? self.fiasID,
            fiasLevel: fiasLevel ?? self.fiasLevel,
            flat: flat ?? self.flat,
            flatArea: flatArea ?? self.flatArea,
            flatPrice: flatPrice ?? self.flatPrice,
            flatType: flatType ?? self.flatType,
            flatTypeFull: flatTypeFull ?? self.flatTypeFull,
            geoLat: geoLat ?? self.geoLat,
            geoLon: geoLon ?? self.geoLon,
            geonameID: geonameID ?? self.geonameID,
            historyValues: historyValues ?? self.historyValues,
            house: house ?? self.house,
            houseFiasID: houseFiasID ?? self.houseFiasID,
            houseKladrID: houseKladrID ?? self.houseKladrID,
            houseType: houseType ?? self.houseType,
            houseTypeFull: houseTypeFull ?? self.houseTypeFull,
            kladrID: kladrID ?? self.kladrID,
            metro: metro ?? self.metro,
            okato: okato ?? self.okato,
            oktmo: oktmo ?? self.oktmo,
            postalBox: postalBox ?? self.postalBox,
            postalCode: postalCode ?? self.postalCode,
            qc: qc ?? self.qc,
            qcComplete: qcComplete ?? self.qcComplete,
            qcGeo: qcGeo ?? self.qcGeo,
            qcHouse: qcHouse ?? self.qcHouse,
            region: region ?? self.region,
            regionFiasID: regionFiasID ?? self.regionFiasID,
            regionISOCode: regionISOCode ?? self.regionISOCode,
            regionKladrID: regionKladrID ?? self.regionKladrID,
            regionType: regionType ?? self.regionType,
            regionTypeFull: regionTypeFull ?? self.regionTypeFull,
            regionWithType: regionWithType ?? self.regionWithType,
            settlement: settlement ?? self.settlement,
            settlementFiasID: settlementFiasID ?? self.settlementFiasID,
            settlementKladrID: settlementKladrID ?? self.settlementKladrID,
            settlementType: settlementType ?? self.settlementType,
            settlementTypeFull: settlementTypeFull ?? self.settlementTypeFull,
            settlementWithType: settlementWithType ?? self.settlementWithType,
            source: source ?? self.source,
            squareMeterPrice: squareMeterPrice ?? self.squareMeterPrice,
            street: street ?? self.street,
            streetFiasID: streetFiasID ?? self.streetFiasID,
            streetKladrID: streetKladrID ?? self.streetKladrID,
            streetType: streetType ?? self.streetType,
            streetTypeFull: streetTypeFull ?? self.streetTypeFull,
            streetWithType: streetWithType ?? self.streetWithType,
            taxOffice: taxOffice ?? self.taxOffice,
            taxOfficeLegal: taxOfficeLegal ?? self.taxOfficeLegal,
            timezone: timezone ?? self.timezone,
            unparsedParts: unparsedParts ?? self.unparsedParts
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Metro
struct SuggestCompanyMetro: Codable {
    let distance, line, name: String?
}

// MARK: Metro convenience initializers and mutators

extension SuggestCompanyMetro {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyMetro.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        distance: String?? = nil,
        line: String?? = nil,
        name: String?? = nil
    ) -> SuggestCompanyMetro {
        return SuggestCompanyMetro(
            distance: distance ?? self.distance,
            line: line ?? self.line,
            name: name ?? self.name
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

import Foundation

// MARK: - SuggestCompanyFinance
struct SuggestCompanyFinance: Codable {
    let debt, expense, income, penalty: String?
    let taxSystem: String?
}

// MARK: Finance convenience initializers and mutators

extension SuggestCompanyFinance {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyFinance.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        debt: String?? = nil,
        expense: String?? = nil,
        income: String?? = nil,
        penalty: String?? = nil,
        taxSystem: String?? = nil
    ) -> SuggestCompanyFinance {
        return SuggestCompanyFinance(
            debt: debt ?? self.debt,
            expense: expense ?? self.expense,
            income: income ?? self.income,
            penalty: penalty ?? self.penalty,
            taxSystem: taxSystem ?? self.taxSystem
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SuggestCompanyManagement
struct SuggestCompanyManagement: Codable {
    let disqualified, name, post: String?
}

// MARK: Management convenience initializers and mutators

extension SuggestCompanyManagement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyManagement.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        disqualified: String?? = nil,
        name: String?? = nil,
        post: String?? = nil
    ) -> SuggestCompanyManagement {
        return SuggestCompanyManagement(
            disqualified: disqualified ?? self.disqualified,
            name: name ?? self.name,
            post: post ?? self.post
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SuggestCompanyName
struct SuggestCompanyName: Codable {
    let full, fullWithOpf, latin, short: String?
    let shortWithOpf: String?
}

// MARK: Name convenience initializers and mutators

extension SuggestCompanyName {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyName.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        full: String?? = nil,
        fullWithOpf: String?? = nil,
        latin: String?? = nil,
        short: String?? = nil,
        shortWithOpf: String?? = nil
    ) -> SuggestCompanyName {
        return SuggestCompanyName(
            full: full ?? self.full,
            fullWithOpf: fullWithOpf ?? self.fullWithOpf,
            latin: latin ?? self.latin,
            short: short ?? self.short,
            shortWithOpf: shortWithOpf ?? self.shortWithOpf
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SuggestCompanyOpf
struct SuggestCompanyOpf: Codable {
    let code, full, short, type: String?
}

// MARK: Opf convenience initializers and mutators

extension SuggestCompanyOpf {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyOpf.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        code: String?? = nil,
        full: String?? = nil,
        short: String?? = nil,
        type: String?? = nil
    ) -> SuggestCompanyOpf {
        return SuggestCompanyOpf(
            code: code ?? self.code,
            full: full ?? self.full,
            short: short ?? self.short,
            type: type ?? self.type
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SuggestCompanyState
struct SuggestCompanyState: Codable {
    let actualityDate, liquidationDate, registrationDate, status: String?
}

// MARK: State convenience initializers and mutators

extension SuggestCompanyState {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestCompanyState.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        actualityDate: String?? = nil,
        liquidationDate: String?? = nil,
        registrationDate: String?? = nil,
        status: String?? = nil
    ) -> SuggestCompanyState {
        return SuggestCompanyState(
            actualityDate: actualityDate ?? self.actualityDate,
            liquidationDate: liquidationDate ?? self.liquidationDate,
            registrationDate: registrationDate ?? self.registrationDate,
            status: status ?? self.status
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

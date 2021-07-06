//
//  SuggestBankDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.07.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let suggestBankDecodableModel = try SuggestBankDecodableModel(json)

import Foundation

// MARK: - SuggestBankDecodableModel
struct SuggestBankDecodableModel: Codable, NetworkModelProtocol {
    let data: [Datum]?
    let errorMessage: String?
    let statusCode: Int?
}

// MARK: SuggestBankDecodableModel convenience initializers and mutators

extension SuggestBankDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SuggestBankDecodableModel.self, from: data)
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
        data: [Datum]?? = nil,
        errorMessage: String?? = nil,
        statusCode: Int?? = nil
    ) -> SuggestBankDecodableModel {
        return SuggestBankDecodableModel(
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

// Datum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datum = try Datum(json)

// MARK: - Datum
struct Datum: Codable {
    let data: DatumData?
    let unrestrictedValue, value: String?
}

// MARK: Datum convenience initializers and mutators

extension Datum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Datum.self, from: data)
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
        data: DatumData?? = nil,
        unrestrictedValue: String?? = nil,
        value: String?? = nil
    ) -> Datum {
        return Datum(
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

// DatumData.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datumData = try DatumData(json)

// MARK: - DatumData
struct DatumData: Codable {
    let address: Address?
    let bic, correspondentAccount: String?
    let name: Name?
    let okpo: String?
    let opf: Opf?
    let paymentCity, phones, registrationNumber, rkc: String?
    let state: State?
    let swift: String?
}

// MARK: DatumData convenience initializers and mutators

extension DatumData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DatumData.self, from: data)
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
        address: Address?? = nil,
        bic: String?? = nil,
        correspondentAccount: String?? = nil,
        name: Name?? = nil,
        okpo: String?? = nil,
        opf: Opf?? = nil,
        paymentCity: String?? = nil,
        phones: String?? = nil,
        registrationNumber: String?? = nil,
        rkc: String?? = nil,
        state: State?? = nil,
        swift: String?? = nil
    ) -> DatumData {
        return DatumData(
            address: address ?? self.address,
            bic: bic ?? self.bic,
            correspondentAccount: correspondentAccount ?? self.correspondentAccount,
            name: name ?? self.name,
            okpo: okpo ?? self.okpo,
            opf: opf ?? self.opf,
            paymentCity: paymentCity ?? self.paymentCity,
            phones: phones ?? self.phones,
            registrationNumber: registrationNumber ?? self.registrationNumber,
            rkc: rkc ?? self.rkc,
            state: state ?? self.state,
            swift: swift ?? self.swift
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Address.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let address = try Address(json)

// MARK: - Address
struct Address: Codable {
    let data: AddressData?
    let unrestrictedValue, value: String?
}

// MARK: Address convenience initializers and mutators

extension Address {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Address.self, from: data)
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
    ) -> Address {
        return Address(
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

// AddressData.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let addressData = try AddressData(json)

// MARK: - AddressData
struct AddressData: Codable {
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

extension AddressData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AddressData.self, from: data)
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
    ) -> AddressData {
        return AddressData(
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

// Metro.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let metro = try Metro(json)

// MARK: - Metro
struct Metro: Codable {
    let distance, line, name: String?
}

// MARK: Metro convenience initializers and mutators

extension Metro {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Metro.self, from: data)
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
    ) -> Metro {
        return Metro(
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

// Name.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let name = try Name(json)

// MARK: - Name
struct Name: Codable {
    let full, payment, short: String?
}

// MARK: Name convenience initializers and mutators

extension Name {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Name.self, from: data)
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
        payment: String?? = nil,
        short: String?? = nil
    ) -> Name {
        return Name(
            full: full ?? self.full,
            payment: payment ?? self.payment,
            short: short ?? self.short
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Opf.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let opf = try Opf(json)

// MARK: - Opf
struct Opf: Codable {
    let full, short, type: String?
}

// MARK: Opf convenience initializers and mutators

extension Opf {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Opf.self, from: data)
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
        short: String?? = nil,
        type: String?? = nil
    ) -> Opf {
        return Opf(
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

// State.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let state = try State(json)

// MARK: - State
struct State: Codable {
    let actualityDate, liquidationDate, registrationDate, status: String?
}

// MARK: State convenience initializers and mutators

extension State {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(State.self, from: data)
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
    ) -> State {
        return State(
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


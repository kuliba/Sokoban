//
//  SuggestAddressData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct SuggestAddressData: Codable, Equatable {

    let data: AddressItem?
    let unrestrictedValue: String?
    let value: String?
}

extension SuggestAddressData {
    
    struct AddressItem: Codable, Equatable {
        
        let area: String?
        let areaFiasId: String?
        let areaKladrId: String?
        let areaType: String?
        let areaTypeFull: String?
        let areaWithType: String?
        let beltwayDistance: String?
        let beltwayHit: String?
        let block: String?
        let blockType: String?
        let blockTypeFull: String?
        let capitalMarker: String?
        let city: String?
        let cityArea: String?
        let cityDistrict: String?
        let cityDistrictFiasId: String
        let cityDistrictKladrId: String
        let cityDistrictType: String
        let cityDistrictTypeFull: String?
        let cityDistrictWithType: String?
        let cityFiasId: String?
        let cityKladrId: String?
        let cityType: String?
        let cityTypeFull: String?
        let cityWithType: String?
        let country: String?
        let countryIsoCode: String?
        let federalDistrict: String?
        let fiasActualityState: String?
        let fiasCode: String?
        let fiasId: String?
        let fiasLevel: String?
        let flat: String?
        let flatArea: String?
        let flatPrice: String?
        let flatType: String?
        let flatTypeFull: String?
        let geoLat: String?
        let geoLon: String?
        let geonameId: String?
        let historyValues: String?
        let house: String?
        let houseFiasId: String?
        let houseKladrId: String?
        let houseType: String?
        let houseTypeFull: String?
        let kladrId: String?
        let metro: [Metro]?
        let okato: String?
        let oktmo: String?
        let postalBox: String?
        let postalCode: String?
        let qc: String?
        let qcComplete: String?
        let qcGeo: String?
        let qcHouse: String?
        let region: String?
        let regionFiasId: String?
        let regionIsoCode: String?
        let regionKladrId: String?
        let regionType: String?
        let regionTypeFull: String?
        let regionWithType: String?
        let settlement: String?
        let settlementFiasId: String?
        let settlementKladrId: String?
        let settlementType: String?
        let settlementTypeFull: String?
        let settlementWithType: String?
        let source: String?
        let squareMeterPrice: String?
        let street: String?
        let streetFiasId: String?
        let streetKladrId: String?
        let streetType: String?
        let streetTypeFull: String?
        let streetWithType: String?
        let taxOffice: String?
        let taxOfficeLegal: String?
        let timezone: String?
        let unparsedParts: String?
        
        struct Metro: Codable, Equatable {
            
            let distance: String?
            let line: String?
            let name: String?
        }
    }
}


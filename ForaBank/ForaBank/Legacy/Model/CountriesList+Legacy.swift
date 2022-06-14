//
//  CountriesList+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 14.06.2022.
//

import Foundation

extension CountryData {
    
    func getCountriesList() -> CountriesList {
        
        CountriesList(code: code, contactCode: contactCode, name: name, sendCurr: sendCurr, md5Hash: md5hash, svgImage: svgImage?.description, paymentSystemCodeList: paymentSystemIdList)
    }
    
}

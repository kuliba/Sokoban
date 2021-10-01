//
//  GKHDataSorted.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import Foundation

struct GKHDataSorted {
    static func a(_ dataType: String) -> (String, String) {
        var dataCase = ("", "")
        for i in GKHDataCase.allCases {
            let key = i.returnDataCase().first?.key ?? ""
            let value = i.returnDataCase().first?.value ?? []
            
            for i in value {
                if i == dataType {
                    
                    let v = GKHDataCaseImage.allCases.filter {$0.rawValue == key}.first
                    
                    dataCase.1 = v?.returnStringImage() ?? ""
                    dataCase.0 = v?.rawValue ?? ""

                }
            }
        }
        return dataCase
    }
    
    
}

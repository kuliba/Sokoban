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
            i.returnDataCase().values.forEach { value in
                if value.contains(dataType) {
                dataCase.0 = i.returnDataCase().keys.first! as String
                }
                GKHDataCaseImage.allCases.forEach { im in
                    let a = i.returnDataCase().keys.first! as String
                    let b = im.rawValue
                    if b == a {
                        dataCase.1 = im.returnImage()
                    }
                }
            }
        }
        return dataCase
    }
}

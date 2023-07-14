//
//  Array+OptionWithMapImage.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import Foundation

extension Array where Element == OptionWithMapImage {
    
    static let monthlyOptions: Self = [
        .oneWithHtml,
        .twoWithHtml
    ]
    
    static let yearlyOptions: Self = [
        .oneWithHtml,
        .twoWithHtml,
        .threeWithHtml
    ]
    
    static let allWithHtml: Self = [
        .oneWithHtml,
        .twoWithHtml,
        .threeWithHtml
    ]
}

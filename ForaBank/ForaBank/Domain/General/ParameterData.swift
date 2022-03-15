//
//  ParameterData.swift
//  ForaBank
//
//  Created by Дмитрий on 03.02.2022.
//

import Foundation

struct ParameterData: Codable, Equatable {
    
    let content: String?
    let dataType: String?
    let id: String
    let isPrint: Bool?
    let isRequired: Bool?
    let mask: String?
    let maxLength: Int?
    let minLength: Int?
    let order: Int?
    let rawLength: Int
    let readOnly: Bool?
    let regExp: String?
    let subTitle: String?
    let title: String
    let type: String
    let svgImage: SVGImageData?
    let viewType: ViewType
    
    enum ViewType: String, Codable, Equatable{
        
        case constant = "CONSTANT"
        case input = "INPUT"
        case output = "OUTPUT"
    }
}

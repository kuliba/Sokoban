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
    
    enum ViewType: String, Codable, Equatable, Unknownable {
        
        case constant = "CONSTANT"
        case input = "INPUT"
        case output = "OUTPUT"
        case unknown
    }
}

extension ParameterData {
    
    var value: String? { content }
    
    //"=,inn_oktmo=ИНН и ОКТМО подразделения,number=Номер подразделения"
    var options: [Option]? {
        
        guard let data = dataType else {
            return nil
        }
        
        var options = [Option]()
        let dataSplitted = data.split(separator: ",")
        
        for chunk in dataSplitted {
            
            let chunkSplitted = chunk.split(separator: "=")
            
            guard chunkSplitted.count == 2, chunkSplitted[0] != "", chunkSplitted[1] != "" else {
                continue
            }
            
            let id = String(chunkSplitted[0])
            let name = String(chunkSplitted[1])
            let option = Option(id: id, name: name)
            
            options.append(option)
        }
        
        guard options.isEmpty == false else {
            return nil
        }
        
        return options
    }
    
    var iconData: ImageData? {
        
        guard let svgImage = svgImage else {
            return nil
        }
        
        return ImageData(with: svgImage)
    }
}

extension ParameterData: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        "id: \(id) value: \(value ?? "empty") title: \(title) data: \(dataType ?? "empty") type: \(type)"
    }
}

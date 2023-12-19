//
//  ImageData.swift
//  
//
//  Created by Дмитрий Савушкин on 17.11.2023.
//

import Foundation

public enum ImageData: Hashable {
    
    case data(Data?)
    case named(String)
    case systemName(String)
}

extension ImageData {
    
    var data: Data? {
    
        guard case let .data(data) = self
        else { return nil }
        
        return data
    }
    
    var name: String? {
    
        guard case let .named(name) = self
        else { return nil }
        
        return name
    }
    
    static let empty: Self = .data(.empty)
}

extension Data {
    
    static let empty: Data = .init()
}

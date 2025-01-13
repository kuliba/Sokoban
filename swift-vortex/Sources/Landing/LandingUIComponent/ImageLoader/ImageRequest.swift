//
//  ImageRequest.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Foundation

public enum ImageRequest: Hashable {
    
    case md5Hash(String)
    case url(String)
    
    public var value: String {
        switch self {
        case let .md5Hash(id), let .url(id):
            return id
        }
    }
}

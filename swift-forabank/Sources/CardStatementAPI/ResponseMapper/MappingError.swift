//
//  MappingError.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

public enum MappingError: Error, Equatable {
    
    case mappingFailure(String)
    case not200Status(String)
}

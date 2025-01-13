//
//  AnywayElement.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import Foundation

public enum AnywayElement: Equatable {
    
    case field(Field)
    case parameter(Parameter)
    case widget(Widget)
}

extension AnywayElement {
    
    public enum Icon: Equatable {
        
        case md5Hash(String)
        case svg(String)
        case withFallback(md5Hash: String, svg: String)
    }
}

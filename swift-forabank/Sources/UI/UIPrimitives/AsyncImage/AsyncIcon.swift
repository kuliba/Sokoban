//
//  AsyncIcon.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import SwiftUI

public enum AsyncIcon: Equatable {
    
    case image(Image)
    case md5Hash(String)
    case named(String)
    case svg(String)
}

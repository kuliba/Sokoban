//
//  anyURL.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

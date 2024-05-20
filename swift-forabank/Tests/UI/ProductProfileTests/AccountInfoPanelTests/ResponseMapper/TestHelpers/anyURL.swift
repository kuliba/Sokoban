//
//  anyURL.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

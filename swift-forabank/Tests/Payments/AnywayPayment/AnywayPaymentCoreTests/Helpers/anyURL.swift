//
//  anyURL.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

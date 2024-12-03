//
//  anyURL.swift
//  
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

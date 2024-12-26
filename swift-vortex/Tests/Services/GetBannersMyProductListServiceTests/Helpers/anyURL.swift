//
//  anyURL.swift
//  
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

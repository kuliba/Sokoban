//
//  anyURL.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

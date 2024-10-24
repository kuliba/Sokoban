//
//  anyURL.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 30.09.2024.
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

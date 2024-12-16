//
//  anyURL.swift
//

import Foundation

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

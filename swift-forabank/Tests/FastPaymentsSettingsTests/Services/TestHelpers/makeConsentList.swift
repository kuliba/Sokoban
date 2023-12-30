//
//  makeConsentList.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Foundation

func makeConsentList(
    count: Int
) -> [BankID] {
    
    (0..<count).map { _ in .init(UUID().uuidString) }
}

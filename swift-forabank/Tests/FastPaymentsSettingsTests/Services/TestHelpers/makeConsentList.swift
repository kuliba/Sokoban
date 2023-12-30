//
//  makeConsentList.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Foundation

func makeConsentList(
    count: Int,
    file: StaticString = #file,
    line: UInt = #line
) -> ConsentList {
    
    let list = (0..<count).map { _ in BankID(UUID().uuidString) }
    XCTAssertNoDiff(list.count, count, file: file, line: line)
    
    return list
}

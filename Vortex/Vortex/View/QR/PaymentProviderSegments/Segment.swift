//
//  Segment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

struct Segment<Item> {
    
    let title: String
    let content: [Item]
}

extension Segment: Identifiable {
    
    var id: String { title }
}

extension Segment: Equatable where Item: Equatable {}

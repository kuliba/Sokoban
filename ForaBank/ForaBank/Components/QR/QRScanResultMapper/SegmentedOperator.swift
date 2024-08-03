//
//  SegmentedOperator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct SegmentedOperator<Origin, Segment> {
    
    let origin: Origin
    let segment: Segment
}

extension SegmentedOperator: Equatable where Origin: Equatable, Segment: Equatable {}

//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 27.02.2025.
//

import Foundation

public final class OffsetReducer {
    
    let refreshRange: Range<CGFloat>
    let showTitleRange: PartialRangeFrom<CGFloat>
    
    public init(
        refreshRange: Range<CGFloat>,
        showTitleRange: PartialRangeFrom<CGFloat>
    ) {
        self.refreshRange = refreshRange
        self.showTitleRange = showTitleRange
    }
}

//
//  ReactiveRefreshScrollView.swift
//  
//
//  Created by Igor Malyarov on 02.03.2025.
//

import SwiftUI

/// A reusable view that composes the offset-reporting scroll view with a refresh pipeline.
/// Consumers supply a content closure and a refresh closure. Internally, the view reports offsets
/// and feeds them into a Combine pipeline that triggers refresh when the offset meets the criteria.
public struct ReactiveRefreshScrollView<Content: View>: View {
    
    @StateObject private var model: ReactiveRefreshScrollViewModel
    
    private let content: (CGFloat) -> Content
    
    public init(
        model: ReactiveRefreshScrollViewModel,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self._model = .init(wrappedValue: model)
        self.content = content
    }
    
    public var body: some View {
        
        OffsetReportingScrollView { offset in
            
            content(offset)
                .onChange(of: offset, perform: model.offset)
        }
    }
}

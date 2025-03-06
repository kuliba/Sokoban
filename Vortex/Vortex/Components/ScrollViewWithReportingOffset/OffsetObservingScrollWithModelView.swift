//
//  OffsetObservingScrollWithModelView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import Combine
import CombineSchedulers
import SwiftUI

final class OffsetObservingScrollModel: ObservableObject {
    @Published var offset: CGPoint = .zero
    private var cancellable: AnyCancellable?
    
    init(
        delay: DispatchQueue.SchedulerTimeType.Stride = .seconds(2),
        threshold: CGFloat = -100,
        onChange: @escaping () -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let config = SwipeToRefreshConfig(
            threshold: threshold,
            debounceInterval: delay
        )
        
        self.cancellable = $offset.swipeToRefresh(
            config: config,
            scheduler: scheduler,
            onChange: onChange
        )
    }
}

struct OffsetThreshold {
    
    let title: CGFloat
    let refresh: CGFloat
}

//TODO: change name or add scrollView
struct OffsetObservingScrollWithModelView<Content: View>: View {
    
    @StateObject var model: OffsetObservingScrollModel
    
    private let content: (Binding<CGPoint>) -> Content
    
    init(
        delay: Delay = .seconds(2),
        threshold: CGFloat = -100,
        refresh: @escaping () -> Void,
        @ViewBuilder content: @escaping (Binding<CGPoint>) -> Content
    ) {
        self._model = .init(
            wrappedValue: .init(
                delay: delay,
                threshold: threshold,
                onChange: refresh,
                scheduler: .main
            )
        )
        self.content = content
    }
    
    var body: some View {
        
        content($model.offset)
    }
}

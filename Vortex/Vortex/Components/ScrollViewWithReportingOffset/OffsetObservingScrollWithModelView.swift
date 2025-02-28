//
//  OffsetObservingScrollWithModelView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import Combine
import CombineSchedulers
import SwiftUI
import UIPrimitives

final class OffsetObservingScrollModel: ObservableObject {
    
    @Published var offset: CGPoint = .zero
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride

    private var cancellable: AnyCancellable?
    
    init(
        onChange: @escaping () -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        
        let shouldRefresh = $offset
            .map(\.y)
            .scan(.zero, min)
            .map { $0 < -100 }
            .removeDuplicates()
           // .handleEvents(receiveOutput: { print("shouldRefresh", $0) })
        
        let callRefresh = $offset
            .debounce(for: .seconds(2), scheduler: scheduler)
        
        self.cancellable = shouldRefresh
            .combineLatest(callRefresh)
            .compactMap { $0 ? $1 : nil }
          //  .handleEvents(receiveOutput: { print("cancellable", $0) })
            .sink { _ in onChange() }
    }
}

struct OffsetThreshold {
    
    let title: CGFloat
    let refresh: CGFloat
}

struct OffsetObservingScrollWithModelView<Content: View>: View {
    
    @StateObject var model: OffsetObservingScrollModel
    
    private let content: (Binding<CGPoint>) -> Content
    
    init(
        threshold: OffsetThreshold = .init(title: 100, refresh: -100),
        refresh: @escaping () -> Void,
        content: @escaping (Binding<CGPoint>) -> Content
    ) {
        self._model = .init(
            wrappedValue: .init(
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

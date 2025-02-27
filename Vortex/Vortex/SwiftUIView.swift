//
//  SwiftUIView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import Combine
import CombineSchedulers
import SwiftUI
import UIPrimitives

final class _Model: ObservableObject {
    
    @Published var offset: CGPoint = .zero
    
    private var cancellable: AnyCancellable?
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride

    init(
        interval: Delay,
        refresh: @escaping (CGPoint) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.cancellable = $offset
            .debounce(for: interval, scheduler: scheduler)
            .filter { $0.y < -100 } // TODO: inject -100
            .sink(receiveValue: refresh)
    }
}

struct SwiftUIView: View {
    
    @StateObject var model: _Model
    
    init(refresh: @escaping () -> Void) {
        
        self._model = .init(
            wrappedValue: .init(
                interval: .seconds(2),
                refresh: { if $0.y < -100 { refresh() }},
                scheduler: .main
            )
        )
    }
    
    var body: some View {
        
        OffsetObservingScrollView(
            axes: .vertical,
            showsIndicators: false,
            offset: $model.offset,
            coordinateSpaceName: "coordinateSpaceName"
        ) {
            EmptyView()
        }
        .navigationTitle(model.hasTitle ? "title" : "")
    }
}
extension _Model {
    
    var hasTitle: Bool { offset.y >= 100 }
}

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

final class OffsetObservingScrollModel: ObservableObject {
    
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

struct OffsetObservingScrollWithModelView: View {
    
    @StateObject var model: OffsetObservingScrollModel
    
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
extension OffsetObservingScrollModel {
    
    var hasTitle: Bool { offset.y >= 100 }
}
/*
 import Foundation
 import CombineSchedulers
 import Combine

 final class Model: ObservableObject {
     
     @Published var offset: CGPoint
     //var hasTitle: Bool { offset.y >= 100 } // TODO: inject 100
     private let cancellable: AnyCancellable
     
     init(
         offset: CGPoint = .zero,
         interval: Delay,
         scheduler: AnySchedulerOf<DispatchQueue>
     ) {
         self.offset = offset
         self.cancellable = $offset
             .debounce(for: interval, scheduler: scheduler)
             .filter { $0.y < -100 } // TODO: inject -100
             .sink(receiveValue: <#T##((Published<CGPoint>.Publisher.Output) -> Void)##((Published<CGPoint>.Publisher.Output) -> Void)##(Published<CGPoint>.Publisher.Output) -> Void#>)
         
     }
 }

 extension Model {
     
     typealias Delay = DispatchQueue.SchedulerTimeType.Stride
 }

 */

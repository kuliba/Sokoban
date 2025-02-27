//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 27.02.2025.
//

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

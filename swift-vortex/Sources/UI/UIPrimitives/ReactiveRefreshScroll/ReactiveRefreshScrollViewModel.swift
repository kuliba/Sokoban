//
//  ReactiveRefreshScrollViewModel.swift
//
//
//  Created by Igor Malyarov on 02.03.2025.
//

import Combine
import CombineSchedulers
import Foundation
import VortexTools

/// A view model that listens for vertical offset updates and triggers a refresh action
/// when the offset meets the configured threshold using a Combine pipeline.
public final class ReactiveRefreshScrollViewModel: ObservableObject {
    
    private let offsetSubject = PassthroughSubject<CGFloat, Never>()
    private let refreshCancellable: AnyCancellable
    
    /// Initializes the view model with a refresh configuration, scheduler, and refresh action.
    ///
    /// - Parameters:
    ///   - config: The configuration specifying the threshold and debounce interval.
    ///   - scheduler: The scheduler controlling the debounce timing.
    ///   - refresh: The action to perform when a valid pull-to-refresh gesture is detected.
    public init(
        config: SwipeToRefreshConfig,
        scheduler: AnySchedulerOf<DispatchQueue>,
        refresh: @escaping () -> Void
    ) {
        self.refreshCancellable = offsetSubject
            .swipeToRefresh(
                refresh: refresh,
                config: config,
                scheduler: scheduler
            )
        
        debugPrint("init ReactiveRefreshScrollViewModel")
    }
    
    deinit {
        
        debugPrint("deinit ReactiveRefreshScrollViewModel")
    }
    
    /// Sends an offset update to the refresh pipeline.
    ///
    /// - Parameter offset: The vertical scroll offset.
    public func offset(_ offset: CGFloat) {
        
        offsetSubject.send(offset)
    }
}

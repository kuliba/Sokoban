//
//  _QRBinderGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub

public final class _QRBinderGetNavigationComposer<QRResult, QRNavigation> {
    
    private let getOutsideNavigation: GetOutsideNavigation
    private let getQRResultNavigation: GetQRResultNavigation
    
    public init(
        getOutsideNavigation: @escaping GetOutsideNavigation,
        getQRResultNavigation: @escaping GetQRResultNavigation
    ) {
        self.getOutsideNavigation = getOutsideNavigation
        self.getQRResultNavigation = getQRResultNavigation
    }
}

public extension _QRBinderGetNavigationComposer {
    
    typealias GetOutsideNavigation = (Select.Outside, @escaping Notify, @escaping Completion) -> Void
    typealias GetQRResultNavigation = (QRResult, @escaping Notify, @escaping Completion) -> Void
    
    typealias Domain = _QRNavigationDomain<QRResult, QRNavigation>
    typealias FlowDomain = Domain.FlowDomain
    typealias Select = Domain.Select
    typealias Navigation = Domain.Navigation
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    typealias Completion = (Navigation) -> Void
}

public extension _QRBinderGetNavigationComposer {
    
    func getNavigation(
        select: Select,
        notify: @escaping Notify,
        completion: @escaping Completion
    ) {
        switch select {
        case let .outside(outside):
            getOutsideNavigation(outside, notify, completion)
            
        case let .qrResult(qrResult):
            getQRResultNavigation(qrResult, notify, completion)
        }
    }
}

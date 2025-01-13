//
//  QRBinderComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine

public struct QRBinderComposerMicroServices<Navigation, QR, QRResult> {
    
    public let bind: Bind
    public let getNavigation: GetNavigation
    public let makeQR: MakeQR
    
    public init(
        bind: @escaping Bind,
        getNavigation: @escaping GetNavigation,
        makeQR: @escaping MakeQR
    ) {
        self.bind = bind
        self.getNavigation = getNavigation
        self.makeQR = makeQR
    }
}

public extension QRBinderComposerMicroServices {
    
    typealias Bind = (Domain.Content, Domain.Flow) -> Set<AnyCancellable>
    
    typealias NavigationCompletion = (Navigation) -> Void
    typealias GetNavigation = (Domain.Select, @escaping Domain.Notify, @escaping NavigationCompletion) -> Void
    
    typealias MakeQR = () -> QR
    
    typealias Domain = QRDomain<Navigation, QR, QRResult>
}

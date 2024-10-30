//
//  QRButtonViewFactory.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

struct QRButtonViewFactory<DestinationContent, FullScreenCoverContent> {
    
    let makeDestinationContent: MakeDestinationContent
    let makeFullScreenCoverContent: MakeFullScreenCoverContent
}

extension QRButtonViewFactory {
    
    typealias Destination = QRButtonDomain.FlowDomain.State.Destination
    typealias MakeDestinationContent = (Destination) -> DestinationContent
    
    typealias FullScreen = QRButtonDomain.FlowDomain.State.FullScreen
    typealias MakeFullScreenCoverContent = (FullScreen) -> FullScreenCoverContent
}

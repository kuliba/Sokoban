//
//  QRButtonViewFactory.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

struct QRButtonViewFactory<FullScreenCoverContent> {
    
    let makeFullScreenCoverContent: MakeFullScreenCoverContent
}

extension QRButtonViewFactory {
    
    typealias FullScreen = QRButtonDomain.FlowDomain.State.FullScreen
    typealias MakeFullScreenCoverContent = (FullScreen) -> FullScreenCoverContent
}

//
//  ElementIDs.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.11.2024.
//

enum ElementIDs {
    
    case fullScreenCover(FullScreenCover)
    case mainView(MainView)
    case rootView(RootView)
    
    enum FullScreenCover: String {
        
        case closeButton
    }
    
    enum MainView: String {
        
        case fullScreenCoverAnchor
        case qrScanner
    }
    
    enum RootView: String {
        
        case qrFullScreenCover
    }
}

extension ElementIDs {
    
    var rawValue: String {
        
        switch self {
        case let .fullScreenCover(fullScreenCover):
            return fullScreenCover.rawValue
            
        case let .mainView(mainView):
            return mainView.rawValue
            
        case let .rootView(rootView):
            return rootView.rawValue
        }
    }
}

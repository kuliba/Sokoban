//
//  ElementIDs.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.11.2024.
//

enum ElementIDs {
    
    case fullScreenCover(FullScreenCover)
    case mainView(MainView)
    case operatorSearch
    case payments
    case providerPicker
    case qrFailure
    case qrScanner
    case rootView(RootView)
    
    enum FullScreenCover: String {
        
        case closeButton
    }
    
    enum MainView: String {
        
        case content
        case fullScreenCoverAnchor
        case qrScanner
        case templates
    }
    
    enum RootView {
        
        case qrFullScreenCover
        case mainView
        case destination(Destination)
        
        var rawValue: String {
            
            switch self {
            case .qrFullScreenCover:
                return "qrFullScreenCover"
                
            case .mainView:
                return "mainView"
                
            case let .destination(destination):
                return destination.rawValue
            }
        }
        
        enum Destination: String {
            
            case templates
        }
    }
}

extension ElementIDs {
    
    var rawValue: String {
        
        switch self {
        case let .fullScreenCover(fullScreenCover):
            return fullScreenCover.rawValue
            
        case let .mainView(mainView):
            return mainView.rawValue
            
        case .operatorSearch:
            return "operatorSearch"
            
        case .payments:
            return "payments"
            
        case .providerPicker:
            return "providerPicker"
            
        case .qrFailure:
            return "qrFailure"
            
        case .qrScanner:
            return "qrScanner"
            
        case let .rootView(rootView):
            return rootView.rawValue
        }
    }
}

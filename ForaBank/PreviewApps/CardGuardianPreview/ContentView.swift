//
//  ContentView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule
import ProductProfile

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            
            ProductProfileView(viewModel: .init(
                product: .cardUnblokedOnMain,
                initialState: .init(),
                navigationStateManager: .init(
                    reduce: ProductProfileReducer().reduce(_:_:),
                    makeCardGuardianViewModel: { _ in
                        
                            .init(
                                initialState: .init(buttons: .preview),
                                reduce: { state, event in
                                    
                                    var state = state
                                    
                                    switch event {
                                        
                                    case .appear:
                                        state.updateEvent(.appear)
                                        
                                    case let .buttonTapped(tap):
                                        switch tap {
                                            
                                        case .toggleLock:
                                            state.updateEvent(.buttonTapped(.toggleLock))
                                            
                                        case .changePin:
                                            state.updateEvent(.buttonTapped(.changePin))
                                            
                                        case .showOnMain:
                                            state.updateEvent(.buttonTapped(.showOnMain))
                                        }
                                    }
#warning("delete!!! only for tests")
                                    switch state.event {
                                        
                                    case .none:
                                        print("none")
                                        
                                    case let .some(event):
                                        switch event {
                                            
                                        case .appear:
                                            print("appear")
                                            
                                        case let .buttonTapped(tap):
                                            switch tap {
                                                
                                            case .toggleLock:
                                                print("toggleLock")
                                                
                                            case .changePin:
                                                print("changePin")
                                                
                                            case .showOnMain:
                                                print("showOnMain")
                                            }
                                        }
                                    }
                                    
                                    return (state, .none)
                                },
                                handleEffect: { _,_ in }
                            )
                    })))
            .tabItem {
                Label("1", systemImage: "lock.open")
            }
            
            ProductProfileView(viewModel: .init(
                product: .cardBlockedHideOnMain,
                initialState: .init(),
                navigationStateManager: .init(
                    reduce: ProductProfileReducer().reduce(_:_:),
                    makeCardGuardianViewModel: { _ in
                        
                            .init(
                                initialState: .init(buttons: .previewBlockHide),
                                reduce: { state, event in
                                    
                                    var state = state
                                    
                                    switch event {
                                        
                                    case .appear:
                                        state.updateEvent(.appear)
                                        
                                    case let .buttonTapped(tap):
                                        switch tap {
                                            
                                        case .toggleLock:
                                            state.updateEvent(.buttonTapped(.toggleLock))
                                            
                                        case .changePin:
                                            state.updateEvent(.buttonTapped(.changePin))
                                            
                                        case .showOnMain:
                                            state.updateEvent(.buttonTapped(.showOnMain))
                                        }
                                    }
#warning("delete!!! only for tests")
                                    switch state.event {
                                        
                                    case .none:
                                        print("none")
                                        
                                    case let .some(event):
                                        switch event {
                                            
                                        case .appear:
                                            print("appear")
                                            
                                        case let .buttonTapped(tap):
                                            switch tap {
                                                
                                            case .toggleLock:
                                                print("toggleLock")
                                                
                                            case .changePin:
                                                print("changePin")
                                                
                                            case .showOnMain:
                                                print("showOnMain")
                                            }
                                        }
                                    }
                                    
                                    return (state, .none)
                                },
                                handleEffect: { _,_ in }
                            )
                    })))
            .tabItem {
                Label("2", systemImage: "lock")
            }
        }
    }
}

#Preview {
    ContentView()
}

private extension ProductProfileViewModel.Product {
    
    static let cardUnblokedOnMain: Self = .init(isUnBlock: true, isShowOnMain: true)
    
    static let cardBlockedHideOnMain: Self = .init(isUnBlock: false, isShowOnMain: false)
}

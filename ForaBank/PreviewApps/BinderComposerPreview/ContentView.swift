//
//  ContentView.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import RxViewModel
import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    let binder: RootDomain.Binder
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RootFlowView(state: state, event: event) {
                
                VStack(spacing: 32) {
                    
                    Button("Destination") { event(.select(.destination)) }
                    Button("Sheet") { event(.select(.sheet)) }
                }
                .navigationDestination(
                    destination: state.navigation?.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationView
                )
                .sheet(
                    modal: state.navigation?.sheet,
                    dismiss: { event(.dismiss) },
                    content: sheetView
                )
            }
        }
    }
}

private extension ContentView {
    
    @ViewBuilder
    func destinationView(
        destination: RootDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .content(content):
            DestinationView(model: content)
        }
    }
    
    @ViewBuilder
    func sheetView(
        sheet: RootDomain.Navigation.Sheet
    ) -> some View {
        
        switch sheet {
        case let .content(content):
            DestinationView(model: content)
        }
    }
}

extension RootDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case let .destination(node):
            return .content(node.model)
            
        case .sheet:
            return nil
        }
    }
    
    enum Destination {
        
        case content(DestinationDomain.Content)
    }
    
    var sheet: Sheet? {
        
        switch self {
        case .destination:
            return nil
            
        case let .sheet(node):
            return .content(node.model)
        }
    }
    
    enum Sheet {
        
        case content(DestinationDomain.Content)
    }
}

extension RootDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .content(content):
            return .content(.init(content))
        }
    }
    
    enum ID: Hashable {
        
        case content(ObjectIdentifier)
    }
}

extension RootDomain.Navigation.Sheet: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .content(content):
            return .content(.init(content))
        }
    }
    
    enum ID: Hashable {
        
        case content(ObjectIdentifier)
    }
}

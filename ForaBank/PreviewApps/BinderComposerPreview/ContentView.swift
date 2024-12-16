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
    
    @State private var delay: Delay = .ms200
    
    private var binder: RootDomain.Binder { .default(delay: delay.value) }
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RootFlowView(state: state, event: event) {
                
                contentView(event: event)
                    .navigationDestination(
                        destination: state.navigation?.destination,
                        dismiss: { event(.dismiss) },
                        content: destinationView(destination:)
                    )
                    .sheet(
                        modal: state.navigation?.sheet,
                        dismiss: { event(.dismiss) },
                        content: sheetView
                    )
                    .onChange(of: state.navigation?.destination?.id) {
                        
                        print("destination:", $0.map { $0 } ?? "nil")
                    }
                    .onChange(of: state.navigation?.sheet?.id) {
                        
                        print("sheet:", $0.map { $0 } ?? "nil")
                    }
            }
        }
    }
}

private extension ContentView {
    
    func contentView(
        event: @escaping (RootDomain.FlowDomain.Event) -> Void
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text("Start flow with either `Destination` or `Sheet`. See how moving from Sheet to Destination on tapping `Next` briefly shows destination and dismisses it is delay is small.")
            
            HStack {
                
                button("Destination") { event(.select(.destination)) }
                button("Sheet") { event(.select(.sheet)) }
            }
            
            Divider()
            
            picker()
            note()
        }
        .padding(.horizontal)
    }
    
    private func button(
        _ title: String,
        _ action: @escaping () -> Void
    ) -> some View {
        
        Button(title, action: action)
            .frame(maxWidth: .infinity)
    }
    
    func picker() -> some View {
        
        Picker("Delay", systemImage: "clock", selection: $delay) {
            
            ForEach(Delay.allCases, id: \.self) {
                
                Text("\($0.rawValue) ms")
            }
        }
        .pickerStyle(.segmented)
    }
    
    func note() -> some View {
        
        Text("Change `delay` in `static Binder.default(delay:schedulers:)` to see correct and incorrect navigation behavior: if delay is small, SwiftUI writes `nil` destination when switching from sheet after destination is already set. Looks like 500 ms is ok.")
            .foregroundColor(.secondary)
            .font(.subheadline)
    }
    
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
    
    enum Delay: Int, CaseIterable {
        
        case ms200 = 200
        case ms500 = 500
        
        var value: RootDomain.BinderComposer.Delay { .milliseconds(rawValue) }
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

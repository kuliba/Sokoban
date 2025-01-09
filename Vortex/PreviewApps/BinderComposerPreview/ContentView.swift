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
    
    @State private var delayPair: DelayPair = .both
    @State private var mode: Mode = .both
    
    private var binder: RootDomain.Binder { .default(delayPair: delayPair) }
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            ZStack {
                
                progressView(state: state)
                    .zIndex(1.0)
                
                rootViewInNavigationView(state: state, event: event)
            }
        }
        .onChange(of: mode) { delayPair = $0.delayPair }
    }
}

private extension ContentView {
    
    func progressView(
        state: RootDomain.FlowDomain.State
    ) -> some View {
        
        ZStack {
            
            ProgressView()
                .scaleEffect(3)
                .zIndex(1.0)
            
            Color.gray.opacity(0.5)
        }
        .ignoresSafeArea()
        .opacity(state.isLoading ? 1 : 0)
        .animation(.easeInOut, value: state.isLoading)
        .onChange(of: state.isLoading) {
            
            print("isLoading: \($0)")
        }
    }
    
    func rootViewInNavigationView(
        state: RootDomain.FlowDomain.State,
        event: @escaping (RootDomain.FlowDomain.Event) -> Void
    ) -> some View {
        
        NavigationView {
            
            flowView(state: state, event: event) {
                
                contentView(event: event)
            }
            .onChange(of: state.navigation?.destination?.id) {
                
                print("destination:", $0.map { $0 } ?? "nil")
            }
            .onChange(of: state.navigation?.sheet?.id) {
                
                print("sheet:", $0.map { $0 } ?? "nil")
            }
        }
    }
    
    @ViewBuilder
    func flowView<Content: View>(
        state: RootDomain.FlowDomain.State,
        event: @escaping (RootDomain.FlowDomain.Event) -> Void,
        _ content: () -> Content
    ) -> some View {
        
        switch mode {
        case .both:
            content()
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
            
        case .destination:
            content()
                .navigationDestination(
                    destination: state.navigation,
                    dismiss: { event(.dismiss) },
                    content: destinationView(navigation:)
                )
            
        case .sheet:
            content()
                .sheet(
                    modal: state.navigation,
                    dismiss: { event(.dismiss) },
                    content: destinationView(navigation:)
                )
        }
    }
    
    func contentView(
        event: @escaping (RootDomain.FlowDomain.Event) -> Void
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text("Using Sheets only could work with no delay at all, Navigation Destination needs 500ms.")
            
            modePicker()
            
            Divider()
            
            Text("Start flow with either `Destination` or `Sheet`. See how moving from Sheet to Destination on tapping `Next` briefly shows destination and dismisses it if delay is small.")
            
            Divider()
            
            button("Destination") { event(.select(.destination)) }
            delayPicker(selection: $delayPair.destination)
            
            Divider()
            
            button("Sheet") { event(.select(.sheet)) }
            delayPicker(selection: $delayPair.sheet)
            
            note()
        }
        .padding(.horizontal)
    }
    
    func modePicker() -> some View {
        
        Picker("Model", systemImage: "star", selection: $mode) {
            
            ForEach(Mode.allCases, id: \.self) {
                
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private func button(
        _ title: String,
        _ action: @escaping () -> Void
    ) -> some View {
        
        Button(title, action: action)
            .frame(maxWidth: .infinity)
    }
    
    func delayPicker(
        selection: Binding<Delay>
    ) -> some View {
        
        Picker("Delay", systemImage: "clock", selection: selection) {
            
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
        navigation: RootDomain.Navigation
    ) -> some View {
        
        switch navigation {
        case let .destination(node):
            DestinationView(model: node.model, title: "Destination")
            
        case let .sheet(node):
            DestinationView(model: node.model, title: "Sheet")
        }
    }
    
    @ViewBuilder
    func destinationView(
        destination: RootDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .content(content):
            DestinationView(model: content, title: "Destination")
        }
    }
    
    @ViewBuilder
    func sheetView(
        sheet: RootDomain.Navigation.Sheet
    ) -> some View {
        
        switch sheet {
        case let .content(content):
            DestinationView(model: content, title: "Sheet")
        }
    }
}

extension ContentView {
    
    struct DelayPair {
        
        var destination: Delay
        var sheet: Delay
    }
    
    enum Delay: Int, CaseIterable {
        
        case ms0   = 0
        case ms100 = 100
        case ms200 = 200
        case ms300 = 300
        case ms500 = 500
        case ms600 = 600
        
        var value: RootDomain.BinderComposer.Delay { .milliseconds(rawValue) }
    }
    
    enum Mode: String, CaseIterable {
        
        case both, destination, sheet
    }
}

extension ContentView.DelayPair {
    
    static let both: Self = .init(destination: .ms500, sheet: .ms100)
    static let destination: Self = .init(destination: .ms500, sheet: .ms500)
    static let sheet: Self = .init(destination: .ms0, sheet: .ms0)
}

extension ContentView.Mode {
    
    var delayPair: ContentView.DelayPair {
        
        switch self {
        case .both:        return .both
        case .destination: return .destination
        case .sheet:       return .sheet
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

extension RootDomain.Navigation: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .destination(node):
            return .destination(.init(node.model))
            
        case let .sheet(node):
            return .sheet(.init(node.model))
        }
    }
    
    enum ID: Hashable {
        
        case destination(ObjectIdentifier)
        case sheet(ObjectIdentifier)
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

#Preview {
    
    ContentView()
}

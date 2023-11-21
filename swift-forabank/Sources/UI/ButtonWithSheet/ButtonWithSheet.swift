//
//  ButtonWithSheet.swift
//
//
//  Created by Igor Malyarov on 21.11.2023.
//

import SwiftUI

public struct ButtonWithSheet<ButtonLabel, SheetState, SheetStateView>: View
where ButtonLabel: View,
      SheetState: Identifiable & Hashable,
      SheetStateView: View {
    
    public typealias GetSheetState = (@escaping (SheetState) -> Void) -> Void
    public typealias MakeButtonLabel = () -> ButtonLabel
    public typealias Dismiss = () -> Void
    public typealias MakeSheetStateView = (SheetState, @escaping Dismiss) -> SheetStateView
    
    @State private var sheetState: SheetState?
    
    private let label: MakeButtonLabel
    private let getSheetState: GetSheetState
    private let makeSheetStateView: MakeSheetStateView
    
    public init(
        label: @escaping MakeButtonLabel,
        getSheetState: @escaping GetSheetState,
        @ViewBuilder makeSheetStateView: @escaping MakeSheetStateView
    ) {
        self.label = label
        self.getSheetState = getSheetState
        self.makeSheetStateView = makeSheetStateView
    }
    
    public var body: some View {
        
        Button(action: updateState, label: label)
            .sheet(item: $sheetState, content: sheet)
    }
    
    private func updateState() {
        
        getSheetState { self.sheetState = $0 }
    }
    
    private func sheet(sheetState: SheetState) -> some View {
        
        makeSheetStateView(sheetState) { self.sheetState = nil }
    }
}

#Preview {
    
    HStack(spacing: 32) {
        
        Group {
            
            buttonWithSheet(
                title: "sync",
                systemName: "flag.2.crossed",
                getSheetState: { completion in
                    
                    completion(Item.preview)
                }
            )
            
            buttonWithSheet(
                title: "async",
                systemName: "flag.2.crossed.circle",
                getSheetState: { completion in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        completion(Item.preview)
                    }
                }
            )
        }
        .imageScale(.large)
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}

private func buttonWithSheet(
    title: String,
    systemName: String,
    getSheetState: @escaping (@escaping (Item) -> Void) -> Void
) -> some View {
    
    ButtonWithSheet(
        label: { Label(title, systemImage: systemName) },
        getSheetState: getSheetState,
        makeSheetStateView: { item, dismiss in
            
            ZStack(alignment: .topLeading) {
                
                VStack(spacing: 48) {
                    
                    Text(item.title)
                        .font(.title.bold())
                    
                    Text(item.subtitle)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button("close", action: dismiss)
                    .padding()
            }
        }
    )
}

private struct Item: Identifiable & Hashable {
    
    let title: String
    let subtitle: String
    
    var id: String { title }
    
    static let preview: Self = .init(
        title: "Item Title",
        subtitle: "This is Item Subtitle"
    )
}

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
    public typealias MakeSheetStateView = (SheetState) -> SheetStateView
    
    @State private var sheetState: SheetState?
    
    private let label: MakeButtonLabel
    private let getSheetState: GetSheetState
    private let sheetStateView: MakeSheetStateView
    
    public init(
        label: @escaping MakeButtonLabel,
        getSheetState: @escaping GetSheetState,
        sheetStateView: @escaping MakeSheetStateView
    ) {
        self.label = label
        self.getSheetState = getSheetState
        self.sheetStateView = sheetStateView
    }
    
    public var body: some View {
        
        Button(action: updateState, label: label)
            .sheet(item: $sheetState, content: sheetStateView)
    }
    
    private func updateState() {
        
        getSheetState { sheetState = $0 }
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
        sheetStateView: { item in
            
            VStack(spacing: 48) {
                
                Text(item.title)
                    .font(.title.bold())
                
                Text(item.subtitle)
                    .foregroundColor(.secondary)
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

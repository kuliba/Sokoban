//
//  ButtonWithSheet.swift
//
//
//  Created by Igor Malyarov on 21.11.2023.
//

import SwiftUI

public struct ButtonWithSheet<ButtonLabel, Success, Failure, SheetStateView>: View
where ButtonLabel: View,
      Failure: Error,
      SheetStateView: View {
    
    public typealias GetResult = Result<Success, Failure>
    public typealias GetSheetState = (@escaping (GetResult) -> Void) -> Void
    public typealias MakeButtonLabel = () -> ButtonLabel
    public typealias Dismiss = () -> Void
    public typealias MakeSheetStateView = (GetResult, @escaping Dismiss) -> SheetStateView
    
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
}

private extension ButtonWithSheet {
    
    func updateState() {
        
        getSheetState { self.sheetState = .make($0) }
    }
    
    func sheet(sheetState: SheetState) -> some View {
        
        makeSheetStateView(sheetState.result) { self.sheetState = nil }
    }
    
    enum SheetState: Hashable & Identifiable {
        
        case failure(Failure)
        case success(Success)
        
        var id: _Case { _case }
        
        static func make(_ result: Result<Success, Failure>) -> Self {
            
            switch result {
            case let .failure(error):
                return .failure(error)
                
            case let .success(success):
                return .success(success)
            }
        }
        
        var result: Result<Success, Failure> {
            
            switch self {
            case let .failure(error):
                return .failure(error)
                
            case let .success(success):
                return .success(success)
            }
        }
        
        var _case: _Case {
            
            switch self {
            case .failure: return .failure
            case .success: return .success
            }
        }
        
        enum _Case {
            
            case failure
            case success
        }
        
        static func == (lhs: SheetState, rhs: SheetState) -> Bool {
            
            lhs._case == rhs._case
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(_case)
        }
    }
}

struct ButtonWithSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            Group {
                
                buttonWithSheet(
                    title: "sync",
                    systemName: "flag.2.crossed",
                    getSheetState: { completion in
                        
                        completion(.success(Item.preview))
                    }
                )
                
                buttonWithSheet(
                    title: "sync error",
                    systemName: "exclamationmark.triangle.fill",
                    getSheetState: { completion in
                        
                        struct SomeError: Error {}
                        completion(.failure(SomeError()))
                    }
                )
                .foregroundColor(.red)
                
                buttonWithSheet(
                    title: "async",
                    systemName: "flag.2.crossed.circle",
                    getSheetState: { completion in
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            
                            completion(.success(Item.preview))
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
}

private func buttonWithSheet(
    title: String,
    systemName: String,
    getSheetState: @escaping (@escaping (Result<Item, Error>) -> Void) -> Void
) -> some View {
    
    ButtonWithSheet(
        label: { Label(title, systemImage: systemName) },
        getSheetState: getSheetState,
        makeSheetStateView: { result, dismiss in
            
            switch result {
                
            case let .failure(error):
                Text(error.localizedDescription)
                    .padding()
                
            case let .success(item):
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

//
//  OptionalSelectorView.swift
//
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SharedConfigs
import SwiftUI

public struct OptionalSelectorView<Item, IconView, ItemLabel, SelectedItemLabel, ToggleLabel>: View
where Item: Identifiable & Equatable,
      IconView: View,
      ItemLabel: View,
      SelectedItemLabel: View,
      ToggleLabel: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let factory: Factory
    private let config: Config
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory,
        config: Config
    ) {
        self.state = state
        self.event = event
        self.factory = factory
        self.config = config
    }
    
    public var body: some View {
        
        VStack {
            
            HStack(spacing: 16) {

                factory.makeIconView()
                    .frame(width: 24, height: 24)
                
                selectedItemView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                toggleButton()
            }
            
            if state.isShowingItems {
                
                itemsView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.bouncy, value: state)
    }
}

public extension OptionalSelectorView {
    
    typealias State = OptionalSelectorState<Item>
    typealias Event = OptionalSelectorEvent<Item>
    typealias Factory = OptionalSelectorViewFactory<Item, IconView, ItemLabel, SelectedItemLabel, ToggleLabel>
    typealias Config = OptionalSelectorViewConfig
}

private extension OptionalSelectorView {
    
    func selectedItemView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            config.title.text
                .text(withConfig: config.title.config)
            
            if state.isShowingItems {
                searchView()
                    .apply(config: config.search)
            } else {
                button(event: .toggleOptions) {
                    
                    state.selected.map(factory.makeSelectedItemLabel)
                }
            }
        }
    }
    
    func toggleButton() -> some View {
        
        button(event: .toggleOptions) {
            
            factory.makeToggleLabel(state.isShowingItems)
        }
    }
    
    func searchView() -> some View {
        
        TextField(
            config.searchPlaceholder,
            text: .init(
                get: { state.searchQuery },
                set: { event(.search($0)) }
            )
        )
    }
    
    func itemsView() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                ForEach(state.filteredItems, content: itemView)
            }
        }
    }
    
    func itemView(
        item: Item
    ) -> some View {
        
        button(event: .select(item)) {
            
            factory.makeItemLabel(item)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func button(
        event: Event,
        label: @escaping () -> some View
    ) -> some View {
        
        Button {
            self.event(event)
        } label: {
            label().contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

struct OptionalSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 32) {
                
                view(.collapsed)
                view(.expanded)
                view(.searching)
            }
            .padding()
        }
    }
    
    private static func view(
        _ state: OptionalSelectorState<Item>
    ) -> some View {
        
        Wrapper(state: state)
    }
    
    private struct Wrapper: View {
        
        @State var state: OptionalSelectorState<Item>
        
        private let reducer = OptionalSelectorReducer<Item>(
            predicate: { $0.contains($1) }
        )
        
        var body: some View {
            
            OptionalSelectorView(
                state: state,
                event: { event in
                    
                    self.state = reducer.reduce(self.state, event).0
                },
                factory: .init(
                    makeIconView: {
                        Image(systemName: "airplane")
                            .foregroundColor(.green)
                    },
                    makeItemLabel: { Text($0.value) },
                    makeSelectedItemLabel: { Text($0.value).bold() },
                    makeToggleLabel: {
                        
                        Image(systemName: "chevron.up")
                            .rotationEffect(.degrees($0 ? 0 : -180))
                            .foregroundColor(.red)
                    }
                ),
                config: .preview
            )
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct Item: Equatable, Identifiable {
    
    let id: String
    let value: String
    
    static let samples: [Self] = [
        .init(id: "a", value: "A"),
        .init(id: "b", value: "B"),
        .init(id: "bb", value: "BB"),
        .init(id: "bbb", value: "BBB"),
        .init(id: "c", value: "C"),
        .init(id: "d", value: "D"),
    ]
    
    func contains(_ text: String) -> Bool {
        
        return id.localizedCaseInsensitiveContains(text) || value.localizedCaseInsensitiveContains(text)
    }
}

private extension OptionalSelectorState<Item> {
    
    static let collapsed: Self = .init(
        items: Item.samples,
        filteredItems: Item.samples
    )
    
    static let expanded: Self = .init(
        items: Item.samples,
        filteredItems: Item.samples,
        isShowingItems: true
    )
    
    static let searching: Self = .init(
        items: Item.samples,
        filteredItems: Item.samples,
        isShowingItems: true,
        searchQuery: "bb"
    )
}

private extension OptionalSelectorViewConfig {
    
    static let preview: Self = .init(
        title: .init(
            text: "Выберите вид оплаты",
            config: .init(
                textFont: .subheadline,
                textColor: .gray
            )
        ),
        search: .init(
            textFont: .body.italic(),
            textColor: .pink
        ),
        searchPlaceholder: "Search"
    )
}

//
//  SelectorView.swift
//
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SharedConfigs
import SwiftUI

public struct SelectorView<T, ID, IconView, OptionLabel, SelectedOptionLabel, ToggleLabel>: View
where ID: Hashable,
      IconView: View,
      OptionLabel: View,
      SelectedOptionLabel: View,
      ToggleLabel: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let factory: Factory
    private let idKeyPath: KeyPath<T, ID>
    private let config: Config
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory,
        idKeyPath: KeyPath<T, ID>,
        config: Config
    ) {
        self.state = state
        self.event = event
        self.factory = factory
        self.idKeyPath = idKeyPath
        self.config = config
    }
    
    public var body: some View {
        
        VStack {
            
            HStack(spacing: 16) {

                factory.makeIconView()
                    .frame(width: 24, height: 24)
                
                selectedOptionView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                toggleButton()
            }
            
            if state.isShowingOptions {
                
                optionsView()
                    .animation(.easeInOut, value: state.isShowingOptions)
            }
        }
    }
}

public extension SelectorView {
    
    typealias State = Selector<T>
    typealias Event = SelectorEvent<T>
    typealias Factory = SelectorViewFactory<T, IconView, OptionLabel, SelectedOptionLabel, ToggleLabel>
    typealias Config = SelectorViewConfig
}

private extension SelectorView {
    
    func selectedOptionView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            config.title.text
                .text(withConfig: config.title.config)
            
            if state.isShowingOptions {
                searchView()
                    .apply(config: config.search)
            } else {
                button(event: .toggleOptions) {
                    
                    factory.makeSelectedOptionLabel(state.selected)
                }
            }
        }
    }
    
    func toggleButton() -> some View {
        
        button(event: .toggleOptions) {
            
            factory.makeToggleLabel(state.isShowingOptions)
        }
    }
    
    func searchView() -> some View {
        
        TextField(
            "Search",
            text: .init(
                get: { state.searchQuery },
                set: { event(.setSearchQuery($0)) }
            )
        )
    }
    
    func optionsView() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                ForEach(state.filteredOptions, id: idKeyPath, content: optionView)
            }
        }
    }
    
    func optionView(
        option: T
    ) -> some View {
        
        button(event: .selectOption(option)) {
            
            factory.makeOptionLabel(option)
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

struct SelectorView_Previews: PreviewProvider {
    
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
        _ state: Selector<Item>
    ) -> some View {
        
        Wrapper(state: state)
    }
    
    private struct Wrapper: View {
        
        @State var state: Selector<Item>
        
        private let reducer = SelectorReducer<Item>()
        
        var body: some View {
            
            SelectorView(
                state: state,
                event: { event in
                    
                    self.state = reducer.reduce(self.state, event).0
                },
                factory: .init(
                    makeIconView: {
                        Image(systemName: "airplane")
                            .foregroundColor(.green)
                    },
                    makeOptionLabel: { Text($0.value) },
                    makeSelectedOptionLabel: { Text($0.value).bold() },
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

private extension Selector where T == Item {
    
    static let collapsed: Self = try! .init(
        options: Item.samples,
        filterPredicate: { $0.contains($1) }
    )
    
    static let expanded: Self = try! .init(
        options: Item.samples,
        isShowingOptions: true,
        filterPredicate: { $0.contains($1) }
    )
    
    static let searching: Self = try! .init(
        options: Item.samples,
        isShowingOptions: true,
        searchQuery: "bb",
        filterPredicate: { $0.contains($1) }
    )
}

private extension SelectorViewConfig {
    
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
        )
    )
}

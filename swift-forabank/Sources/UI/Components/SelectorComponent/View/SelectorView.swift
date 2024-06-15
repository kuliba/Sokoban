//
//  SelectorView.swift
//  
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SwiftUI

public struct SelectorView<T, ID, OptionView, SelectedOptionView>: View
where ID: Hashable,
      OptionView: View,
      SelectedOptionView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    let idKeyPath: KeyPath<T, ID>
    
    public init(
        state: State, 
        event: @escaping (Event) -> Void,
        factory: Factory,
        idKeyPath: KeyPath<T, ID>
    ) {
        self.state = state
        self.event = event
        self.factory = factory
        self.idKeyPath = idKeyPath
    }
    
    public var body: some View {
        
        VStack {
            
            HStack {
                
                selectedOptionView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                toggleView()
            }
            
            if state.isShowingOptions {
                
                searchView()
                optionsView()
                    .animation(.easeInOut, value: state.isShowingOptions)
            }
        }
        .padding()
    }
}

public extension SelectorView {
    
    typealias State = Selector<T>
    typealias Event = SelectorEvent<T>
    typealias Factory = SelectorViewFactory<T, OptionView, SelectedOptionView>
}

private extension SelectorView {
    
    func selectedOptionView() -> some View {
        
        factory.createSelectedOptionView(state.selected)
    }
    
    func toggleView() -> some View {
        
        Button {
            event(.toggleOptions)
        } label: {
            Text(state.isShowingOptions ? "Hide" : "Show")
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
        
        factory.createOptionView(option)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { event(.selectOption(option)) }
    }
}

//
//  SelectorView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SwiftUI

struct SelectorView<T, ID, OptionView, SelectedOptionView>: View
where ID: Hashable,
      OptionView: View,
      SelectedOptionView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    let idKeyPath: KeyPath<T, ID>
    
    var body: some View {
        
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

extension SelectorView {
    
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

extension SelectorView where T: Hashable, T == ID {
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.init(
            state: state,
            event: event,
            factory: factory,
            idKeyPath: \.self
        )
    }
}

extension SelectorView where T: Identifiable, T.ID == ID {
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.init(
            state: state,
            event: event,
            factory: factory,
            idKeyPath: \.id
        )
    }
}

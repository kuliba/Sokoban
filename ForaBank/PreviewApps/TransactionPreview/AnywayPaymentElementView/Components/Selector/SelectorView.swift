//
//  SelectorView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SwiftUI

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
            }
        }
        .padding()
    }
    
    private func selectedOptionView() -> some View {
        
        factory.createSelectedOptionView(state.selected)
    }
    
    private func toggleView() -> some View {
        
        Button {
            event(.toggleOptions)
        } label: {
            Text(state.isShowingOptions ? "Hide Options" : "Show Options")
        }
    }
    
    private func searchView() -> some View {
        
        TextField(
            "Search",
            text: .init(
                get: { state.searchQuery },
                set: { event(.setSearchQuery($0)) }
            )
        )
    }
    
    private func optionsView() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                ForEach(state.filteredOptions, id: idKeyPath, content: optionView)
            }
        }
    }
    
    private func optionView(
        option: T
    ) -> some View {
        
        factory.createOptionView(option)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { event(.selectOption(option)) }
    }
}

extension SelectorView {
    
    typealias State = Selector<T>
    typealias Event = SelectorEvent<T>
    typealias Factory = SelectorViewFactory<T, OptionView, SelectedOptionView>
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

#Preview {
    SelectorView(state: .preview, event: { print($0) }, factory: .preview)
}

#Preview {
    SelectorView(state: .previewExpanded, event: { print($0) }, factory: .preview)
}

extension Selector where T == String {
    
    static var preview: Self {
        
        return try! .init(options: ["Option A", "Option B", "Option C"])
    }
    
    static var previewExpanded: Self {
        
        return try! .init(
            options: ["Option A", "Option B", "Option C"],
            isShowingOptions: true
        )
    }
}

extension SelectorViewFactory
where T == String,
      OptionView == Text,
      SelectedOptionView == Text {
    
    static var preview: Self {
        
        return .init(
            createOptionView: Text.init,
            createSelectedOptionView: Text.init
        )
    }
}

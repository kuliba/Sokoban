//
//  CategoryPickerSectionContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import SharedConfigs
import SwiftUI
import UIPrimitives

public struct CategoryPickerSectionContentView<ItemLabel, ServiceCategory>: View
where ItemLabel: View,
      ServiceCategory: Equatable {
    
    private let state: State
    private let event: (Event) -> Void
    private let config: Config
    private let itemLabel: (State.Item) -> ItemLabel
    
    private let transition: AnyTransition = .opacity.combined(with: .scale)
    
    public init(
        state: State, 
        event: @escaping (Event) -> Void,
        config: Config,
        @ViewBuilder itemLabel: @escaping (State.Item) -> ItemLabel
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.itemLabel = itemLabel
    }
    
    public var body: some View {
        
        if state.isLoadingFailed {
            Text("Failed to load categories")
                .foregroundColor(.red)
        } else {
            VStack(spacing: config.spacing) {
                
                sectionHeader()
                    .frame(height: config.headerHeight)
                
                ScrollView(showsIndicators: false) {
                    
                    ForEach(state.suffix, content: itemView)
                        .animation(.easeInOut, value: state)
                }
                .listStyle(.plain)
            }
        }
    }
}

public extension CategoryPickerSectionContentView {
    
    typealias State = CategoryPickerSectionState<ServiceCategory>
    typealias Event = CategoryPickerSectionEvent<ServiceCategory>
    typealias Config = CategoryPickerSectionContentViewConfig
}

private extension CategoryPickerSectionState {
    
    var isLoadingFailed: Bool {
        
        !isLoading && suffix.isEmpty
    }
}

private extension CategoryPickerSectionContentView {
    
    @ViewBuilder
    func sectionHeader() -> some View {
        
        HStack {
            
            headerTitle()
            showAll()
        }
    }
    
    func headerTitle() -> some View {
        
        ZStack(alignment: .leading) {
            
            titlePlaceholder(config: config.titlePlaceholder)
                .opacity(state.isLoading ? 1 : 0)
            
            config.title.render()
                .opacity(state.isLoading ? 0 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeInOut, value: state.isLoading)
    }
    
    private func showAll() -> some View {
        
        itemView(item: .element(.init(.showAll)))
            .opacity(state.isLoading ? 0 : 1)
            .transition(transition)
            .animation(.easeInOut, value: state.isLoading)
    }
    
    private func titlePlaceholder(
        config: CategoryPickerSectionContentViewConfig.TitlePlaceholder
    ) -> some View {
        
        config.color
            .clipShape(RoundedRectangle(cornerRadius: config.radius))
            .frame(config.size)
            ._shimmering()
    }
    
    @ViewBuilder
    func itemView(
        item: State.Item
    ) -> some View {
        
        let label = itemLabel(item)
            .contentShape(Rectangle())
            .transition(transition(for: item))
        
        switch item {
        case .placeholder:
            label
            
        case let .element(identified):
            Button {
                event(.select(identified.element))
            } label: {
                label
            }
            .buttonStyle(.plain)
        }
    }
    
    func transition(
        for item: State.Item
    ) -> AnyTransition {
        
        switch item {
        case .placeholder:
            return transition
            
        case .element:
            return transition
        }
    }
}

struct CategoryPickerSectionContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            categoryPickerSectionContentView(.placeholders(count: 5))
            categoryPickerSectionContentView(.preview)
            categoryPickerSectionContentView(.placeholders(count: 0))
        }
    }
    
    private static func categoryPickerSectionContentView(
        _ items: [CategoryPickerSectionState<PreviewServiceCategory>.Item]
    ) -> some View {
        
        CategoryPickerSectionContentView(
            state: .init(prefix: [], suffix: items),
            event: { print($0) },
            config: .preview,
            itemLabel: { Text(String(describing: $0)) }
        )
    }
}

struct PreviewServiceCategory: Equatable {
    
}

extension Array where Element == CategoryPickerSectionState<PreviewServiceCategory>.Item {
    
    static func placeholders(count: Int) -> Self {
        
        (0..<count).map { _ in .placeholder(.init()) }
    }
    
    static var preview: Self {
        
        [PreviewServiceCategory].preview.map { .element(.init(.category($0))) }
    }
}

extension Array where Element == PreviewServiceCategory {
    
    static let preview: Self = [
        .init(), .init(), .init(), .init()
    ]
}

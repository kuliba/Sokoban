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
      ServiceCategory: Equatable & Identifiable {
    
    private let state: State
    private let event: (Event) -> Void
    private let select: (ServiceCategory) -> Void
    private let config: Config
    private let itemLabel: (State.Item) -> ItemLabel
    
    private let transition: AnyTransition = .opacity.combined(with: .scale)
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        select: @escaping (ServiceCategory) -> Void,
        config: Config,
        @ViewBuilder itemLabel: @escaping (State.Item) -> ItemLabel
    ) {
        self.state = state
        self.event = event
        self.select = select
        self.config = config
        self.itemLabel = itemLabel
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            config.headerHeight.map {
             
                headerTitle()
                    .frame(height: $0)
            }
            
            if isLoadingFailed {
                
                failureView(config: config.failure)
                    .padding(.top, config.spacing)
                
            } else {
                
                ScrollView(showsIndicators: false) {
                    
                    ForEach(state.items, content: itemView)
                        .animation(.easeInOut, value: state)
                }
                .padding(.horizontal, config.title.leadingPadding)
            }
        }
    }
}

public extension CategoryPickerSectionContentView {
    
    typealias Domain = CategoryPickerContentDomain<ServiceCategory>
    typealias State = Domain.State
    typealias Event = Domain.Event
    typealias Config = CategoryPickerSectionContentViewConfig
}

private extension CategoryPickerSectionContentView {
    
    var isLoadingFailed: Bool {
        
        !state.isLoading && state.items.isEmpty
    }
    
    func failureView(
        config: LabelConfig
    ) -> some View {
        
        VStack(spacing: config.spacing) {
            
            config.imageConfig.render()
                .clipShape(Circle())
            
            config.textConfig.render()
        }
    }
    
    func headerTitle() -> some View {
        
        ZStack(alignment: .leading) {
            
            titlePlaceholder(config: config.titlePlaceholder)
                .opacity(state.isLoading ? 1 : 0)
                .padding(.leading, config.title.leadingPadding)
            
            config.title.render()
                .opacity(state.isLoading ? 0 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                select(identified.element.entity)
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

// MARK: - Previews

struct CategoryPickerSectionContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            categoryPickerSectionContentView(.placeholders(count: 5))
            categoryPickerSectionContentView(.preview)
            categoryPickerSectionContentView(.placeholders(count: 0))
                .previewDisplayName("Failure")
        }
    }
    
    private static func categoryPickerSectionContentView(
        _ items: [CategoryPickerContentDomain<PreviewServiceCategory>.State.Item]
    ) -> some View {
        
        CategoryPickerSectionContentView(
            state: .init(prefix: [], suffix: items),
            event: { print($0) },
            select: { print($0) },
            config: .preview(),
            itemLabel: { item in
                
                HStack(spacing: 16) {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(.init(width: 40, height: 40))
                    
                    Text(String(describing: item).prefix(25).capitalized)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

struct PreviewServiceCategory: Equatable, Identifiable {
    
    let id = UUID()
}

extension Array where Element == CategoryPickerContentDomain<PreviewServiceCategory>.State.Item {
    
    static func placeholders(count: Int) -> Self {
        
        (0..<count).map { _ in .placeholder(.init()) }
    }
    
    static var preview: Self {
        
        [PreviewServiceCategory].preview.map { .element(.init(id: .init(), element: .init(entity: $0, state: .completed))) }
    }
}

extension Array where Element == PreviewServiceCategory {
    
    static let preview: Self = [
        .init(), .init(), .init(), .init()
    ]
}

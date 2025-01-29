//
//  SavingsAccountView.swift
//
//
//  Created by Andryusina Nataly on 18.11.2024.
//

import SwiftUI
import SharedConfigs
import DropDownTextListComponent

public struct SavingsAccountView: View {
    
    let state: SavingsAccountState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
        
    @State private(set) var selectedQuestion: Question?
    
    public init(
        state: SavingsAccountState,
        event: @escaping (SavingsAccountEvent) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            factory.makeBannerImageView(state.imageLink)
                .frame(height: config.bannerHeight)
                .aspectRatio(contentMode: .fit)
                .modifier(PaddingsModifier(bottom: -config.paddings.negativeBottomPadding, vertical: config.paddings.vertical))
            
            list(items: state.advantages)
                .modifier(PaddingsModifier(horizontal: config.paddings.list.horizontal))
            
            list(items: state.basicConditions)
                .modifier(PaddingsModifier(horizontal: config.paddings.list.horizontal))
            
            questionsView()
                .modifier(PaddingsModifier(horizontal: config.paddings.list.horizontal))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
        
    private func list(
        items: Items
    ) -> some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            
            items.title.map {
                $0.text(withConfig: config.list.title)
                    .accessibilityIdentifier("ItemsTitle")
            }
            
            ForEach(items.list, content: itemView)
                .accessibilityIdentifier("Items")
        }
        .modifier(PaddingsModifier(horizontal: config.paddings.list.horizontal, vertical: config.paddings.list.vertical))
        .modifier(BackgroundAndCornerRadiusModifier(background: config.list.background, cornerRadius: config.cornerRadius))
    }
    
    private func itemView (
        item: Items.Item
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            factory.makeIconView(item.md5hash)
                .aspectRatio(contentMode: .fit)
                .modifier(FrameWidthAndHeightAndCornerRadiusModifier(widthAndHeight: config.icon.widthAndHeight))
                .accessibilityIdentifier("ItemIcon")
            
            VStack(alignment: .leading, spacing: 0) {
                
                item.title.text(withConfig: config.list.item.title)
                    .accessibilityIdentifier("ItemTitle")
                
                item.subtitle.map {
                    $0.text(withConfig: config.list.item.subtitle)
                        .accessibilityIdentifier("ItemSubtitle")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func questionsView() -> some View {

        DropDownTextListView(
            config: config.dropDownTextListConfig,
            list: state.questions.dropDownTextList
        )
    }
    
    private struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

public extension SavingsAccountView {
    
    typealias Event = SavingsAccountEvent
    typealias Config = SavingsAccountConfig
    typealias Factory = ImageViewFactory
    
    typealias Items = SavingsAccountState.Items
    typealias Question = SavingsAccountState.Question
}

#Preview {
    
    NavigationView {
        SavingsAccountView(
            state: .preview,
            event: {
                switch $0 {
                case .dismiss:
                    print("dismiss")
                    
                case .continue:
                    print("continue")
                }
            },
            config: .preview,
            factory: .default)
    }
}


private struct BackgroundAndCornerRadiusModifier: ViewModifier {
    
    let background: Color
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(background)
            .cornerRadius(cornerRadius)
    }
}

private struct FrameWidthAndHeightAndCornerRadiusModifier: ViewModifier {
    
    let widthAndHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: widthAndHeight, height: widthAndHeight)
            .cornerRadius(widthAndHeight/2)
    }
}

private struct PaddingsModifier: ViewModifier {
    
    let bottom: CGFloat?
    let horizontal: CGFloat?
    let vertical: CGFloat?
    
    init(
        bottom: CGFloat? = nil,
        horizontal: CGFloat? = nil,
        vertical: CGFloat? = nil
    ) {
        self.bottom = bottom
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        
        switch (bottom, horizontal, vertical) {
        case (.none, .none, .none):
            content
        
        case let (.none, horizontal, .none):
            content
                .padding(.horizontal, horizontal)

        case let (.none, horizontal, vertical):
            content
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
            
        case let (bottom, .none, vertical):
            content
                .padding(.vertical, vertical)
                .padding(.bottom, bottom)
            
        case let (bottom, horizontal, .none):
            content
                .padding(.horizontal, horizontal)
                .padding(.bottom, bottom)
            
        case let (bottom, horizontal, vertical):
            content
                .padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
                .padding(.bottom, bottom)
        }
    }
}

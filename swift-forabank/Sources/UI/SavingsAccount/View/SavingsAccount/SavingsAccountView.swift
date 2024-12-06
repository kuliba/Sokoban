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
    
    private let coordinateSpace: String
    
    @State private(set) var selectedQuestion: Question?
    @State private(set) var isShowHeader = false
    
    public init(
        state: SavingsAccountState,
        event: @escaping (SavingsAccountEvent) -> Void,
        config: Config,
        factory: Factory,
        coordinateSpace: String = "scroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            ScrollView(showsIndicators: false) {
                landing()
            }
            .onPreferenceChange(ViewOffsetKey.self) { value in
                isShowHeader = value > config.offsetForDisplayHeader
            }
            .coordinateSpace(name: coordinateSpace)
        }
        .modifier(PaddingsModifier(horizontal: config.paddings.list.horizontal))
        .toolbar(content: toolbarContent)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            continueButton()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            header()
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            backButton()
        }
    }
    
    private func landing() -> some View {
        VStack {
            factory.makeBannerImageView(state.imageLink)
                .aspectRatio(contentMode: .fit)
                .modifier(PaddingsModifier(bottom: -config.paddings.negativeBottomPadding, vertical: config.paddings.vertical))
            
            list(items: state.advantages)
            list(items: state.basicConditions)
            questionsView()
        }
        .background(
            GeometryReader {
                Color.clear.preference(
                    key: ViewOffsetKey.self,
                    value: -$0.frame(in: .named(coordinateSpace)).origin.y)
            }
        )
    }
    
    private func continueButton() -> some View {
        
        Button(action: { event(.continue) }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: config.continueButton.cornerRadius)
                    .foregroundColor(config.continueButton.background)
                config.continueButton.label.text(withConfig: config.continueButton.title)
            }
        })
        .padding(.horizontal)
        .frame(height: config.continueButton.height)
        .frame(maxWidth: .infinity)
    }
    
    private func backButton() -> some View {
        
        Button(action: { event(.dismiss) }) { config.backImage }
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        if isShowHeader {
            VStack {
                state.title.text(withConfig: config.navTitle.title)
                state.subtitle.map { $0.text(withConfig: config.navTitle.subtitle)
                }
            }
        }
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
            config: config.map(),
            list: state.questions.map()
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

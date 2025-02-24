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
    
    let state: SavingsAccountState?
    let config: Config
    let factory: Factory
        
    @State private(set) var selectedQuestion: Question?
    
    public init(
        state: SavingsAccountState?,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        mainView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func mainView() -> some View {
        
        if let state {
            
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
        } else {
            Color.clear.frame(maxHeight: .infinity)
        }
    }
        
    private func list(
        items: ListItems
    ) -> some View {
        
        List(
            items: items,
            config: config.list,
            factory: factory
        )
        .modifier(PaddingsModifier(horizontal: config.paddings.list.horizontal, vertical: config.paddings.list.vertical))
        .modifier(BackgroundAndCornerRadiusModifier(background: config.list.background, cornerRadius: config.cornerRadius))
    }
    
    private func itemView (
        item: ListItems.Item
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
    
    @ViewBuilder
    private func questionsView() -> some View {

        if let list = state?.questions.dropDownTextList {
            DropDownTextListView(
                config: config.dropDownTextListConfig,
                list: list
            )
        }
    }
}

public extension SavingsAccountView {
    
    typealias Config = SavingsAccountConfig
    typealias Factory = ListImageViewFactory
    
    typealias Question = SavingsAccountState.Question
}

#Preview {
    
    ScrollView {
        SavingsAccountView(
            state: .preview,
            config: .preview,
            factory: .default
        )
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

//
//  DropDownTextListView.swift
//
//
//  Created by Valentin Ozerov on 05.12.2024.
//

import SwiftUI

public struct DropDownTextListView: View {
    
    @State private(set) var selectedItem: Item?

    private let config: Config
    private let list: TextList
    
    public init(config: Config, list: TextList) {
        self.config = config
        self.list = list
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            list.title.map { text in
                
                VStack(spacing: 0) {
                    
                    text.text(withConfig: config.fonts.title)
                        .modifier(
                            PaddingsModifier(
                                horizontal: config.layouts.horizontalPadding,
                                vertical: config.layouts.verticalPadding
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("ListTitle")
                    
                    config.colors.divider
                        .frame(height: 0.5)
                }
            }
            
            ForEach(list.items, id: \.titleWithSubtitle, content: itemView)
        }
        .modifier(BackgroundAndCornerRadiusModifier(
            background: config.colors.background,
            cornerRadius: config.cornerRadius
        ))
    }
    
    private func itemView(item: Item) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            titleAndSubTitleView(for: item)
            
            if list.items.last != item {
                
                config.colors.divider
                    .frame(height: 0.7)
            }
        }
    }
    
    private func titleAndSubTitleView(for item: Item) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Button(
                action: { withAnimation { selectedItem = selectedItem == item ? nil : item } },
                label: { titleView(for: item) }
            )
            
            if selectedItem == item {

                subTitleView(for: item)
            }
        }
    }
    
    private func titleView(for item: Item) -> some View {
        
        return HStack {
            
            item.title.text(withConfig: config.fonts.itemTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("Title")
                .fixedSize(horizontal: false, vertical: true)
            
            config.chevronDownImage
                .foregroundColor(.gray)
                .rotationEffect(selectedItem == item ? .degrees(180) : .degrees(0))
                .accessibilityIdentifier("ItemChevron")
        }
        .modifier(PaddingsModifier(horizontal: config.layouts.horizontalPadding))
        .if(config.layouts.minCellHeight != nil ) {
            $0.frame(minHeight :config.layouts.minCellHeight ?? 0)
        }
    }
    
    private func subTitleView(for item: Item) -> some View {
        
        item.subTitle.text(withConfig: config.fonts.itemSubtitle)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .modifier(PaddingsModifier(horizontal: config.layouts.horizontalPadding))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("SubTitle")
    }
}

private extension DropDownTextList.Item {
    
    var titleWithSubtitle: String { title + subTitle }
}

public extension DropDownTextListView {
    
    typealias Config = DropDownTextListConfig
    typealias TextList = DropDownTextList
    typealias Item = DropDownTextList.Item
}

//MARK: - Conditional View Modifier

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        
        DropDownTextListView(config: .preview, list: .preview)
    }
    .navigationViewStyle(.stack)
}

extension DropDownTextList {
    
    static let preview: Self = .init(
        title: "Часто задаваемые вопросы",
        items: [
            .init(
                title: "Какой кредит выгоднее оформить залоговый или взять несколько потребительских кредитов без обязательного подтверждения целевого использования и оформления залога?",
                subTitle: "При наличии, имущества которое можно передать в залог банку конечно выгоднее оформить залоговый кредит по таким кредитам процентная ставка будет значительно меньше, а срок и сумма кредита всегда больше чем у без залогового потребительского кредита."
            ),
            .init(
                title: "Какое имущество я могу передать в залог банку по кредиту?",
                subTitle: "В залог может быть передано любое движимое или недвижимое имущество, а также ценные бумаги, или права требования, передаваемом в залог имуществе не должно быть обременено правами третьих лиц."
            ),
            .init(
                title: "Как можно увеличить сумму кредита?",
                subTitle: "Если вашего дохода недостаточно, то вы можете привлечь созаемщика с доходом, созаемщиком может являться любое физическое лицо."
            ),
            .init(
                title: "Как можно увеличить сумму кредита?",
                subTitle: "Если вашего дохода недостаточно, то вы можете привлечь созаемщика с доходом, созаемщиком может являться любое физическое лицо."
            )
        ]
    )
}

extension DropDownTextListConfig {
    
    static let preview: Self = .init(
        cornerRadius: 16,
        chevronDownImage: Image(systemName: "chevron.down"),
        layouts: .init(
            horizontalPadding: 16,
            verticalPadding: 12,
            minCellHeight: 64
        ),
        colors: .init(
            divider: .gray,
            background: .gray30
        ),
        fonts: .init(
            title: .init(textFont: .title3, textColor: .green),
            itemTitle: .init(textFont: .footnote, textColor: .black),
            itemSubtitle: .init(textFont: .footnote, textColor: .gray)
        )
    )
}

extension Color {
    
    static let gray30: Self = .init(red: 211/255, green: 211/255, blue: 211/255, opacity: 0.3)
}

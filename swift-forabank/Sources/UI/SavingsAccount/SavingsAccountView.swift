//
//  SavingsAccountView.swift
//
//
//  Created by Andryusina Nataly on 18.11.2024.
//

import SwiftUI

struct SavingsAccountState {
    
    let imageLink: String
    let title: String
    let subtitle: String?
    let advantages: Items
    let basicConditions: Items
    let questions: Questions
    
    struct Questions {
        
        let title: String?
        let questions: [Question]
    }
    
    struct Question: Identifiable, Equatable {
        
        let id: UUID
        let question: String
        let answer: String
    }
    
    struct Items {
        
        let title: String?
        let list: [Item]
        
        struct Item: Identifiable {
            
            let id: UUID
            let md5hash: String
            let title: String
            let subtitle: String?
        }
    }
}

extension SavingsAccountState {
    
    static let preview: Self = .init(
        imageLink: "1",
        title: "Накопительный счет",
        subtitle: "до 8.5%",
        advantages: .advantages,
        basicConditions: .basicConditions,
        questions: .preview)
}

extension SavingsAccountState.Items {
    
    static let advantages: Self = .init(
        title: "Преимущества",
        list: [
            .init(id: .init(), md5hash: "1", title: "Снятие и пополнение без ограничений", subtitle: nil),
            .init(id: .init(), md5hash: "2", title: "Бесплатный счет", subtitle: "0 руб за открытие счета")
        ])
    
    static let basicConditions: Self = .init(
        title: "Основные условия",
        list: [
            .init(id: .init(), md5hash: "2", title: "Счет только в рублях", subtitle: nil),
            .init(id: .init(), md5hash: "3", title: "Выплата ежемесячно", subtitle: nil)
        ])
}

extension SavingsAccountState.Questions {
    
    static let preview: Self = .init(
        title: "Вопросы",
        questions: [
            .init(id: .init(), question: "вопрос1", answer: "ответ1"),
            .init(id: .init(), question: "вопрос2", answer: "ответ2"),
            .init(id: .init(), question: "вопрос3", answer: "ответ3"),
        ])
}

import SharedConfigs

struct SavingsAccountConfig {
    
    let cornerRadius: CGFloat
    let icon: Icon
    let list: List
    let paddings: Paddings
    let spacing: CGFloat
    let chevronDownImage: Image
    let divider: Color
    let navTitle: NavTitle
    let offsetForDisplayHeader: CGFloat

    struct NavTitle {
        
        let title: TextConfig
        let subtitle: TextConfig
    }
    
    struct Icon {
        let leading: CGFloat
        let widthAndHeight: CGFloat
    }
    
    struct Paddings {
        
        let negativeBottomPadding: CGFloat
        let vertical: CGFloat
        let list: List
        
        struct List {
            let leading: CGFloat
            let trailing: CGFloat
            let vertical: CGFloat
        }
    }
    
    struct List {
        
        let title: TextConfig
        let item: Item
        let background: Color
        
        struct Item {
            let title: TextConfig
            let subtitle: TextConfig
        }
    }
}

extension SavingsAccountConfig {
    
    static let preview: Self = .init(
        cornerRadius: 16,
        icon: .init(leading: 8, widthAndHeight: 40),
        list: .init(
            title: .init(textFont: .title3, textColor: .green),
            item: .init(
                title: .init(textFont: .footnote, textColor: .black),
                subtitle: .init(textFont: .footnote, textColor: .gray)),
            background: .gray30
        ),
        paddings: .init(
            negativeBottomPadding: 60,
            vertical: 16,
            list: .init(leading: 16, trailing: 15, vertical: 16)),
        spacing: 16, 
        chevronDownImage: Image(systemName: "chevron.down"),
        divider: .gray, 
        navTitle: .init(
            title: .init(textFont: .body, textColor: .black),
            subtitle: .init(textFont: .callout, textColor: .gray)),
        offsetForDisplayHeader: 100
    )
}

struct SavingsAccountView: View {
    
    let state: SavingsAccountState
    let config: SavingsAccountConfig
    let factory: ImageViewFactory
    
    typealias Config = SavingsAccountConfig
    typealias Factory = ImageViewFactory
    
    @State private(set) var selectedQuestion: SavingsAccountState.Question?
    @State private(set) var isShowHeader = false

    var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            ScrollView(showsIndicators: false) {
                VStack {
                    factory.makeBannerImageView(state.imageLink)
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical, config.paddings.vertical)
                        .padding(.bottom, -config.paddings.negativeBottomPadding)
                    
                    list(items: state.advantages)
                    list(items: state.basicConditions)
                    questionsView()
                }
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -$0.frame(in: .named("scroll")).origin.y)
                    }
                )
            }
            .onPreferenceChange(ViewOffsetKey.self) { value in
                isShowHeader = value > config.offsetForDisplayHeader
            }
            .coordinateSpace(name: "scroll")
        }
        .padding(.leading, config.paddings.list.leading)
        .padding(.trailing, config.paddings.list.trailing)
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                header()
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    var backButton : some View {
        
        Button(action: {

        }) { Image(systemName: "chevron.backward") }
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
        items: SavingsAccountState.Items
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            items.title.map {
                $0.text(withConfig: config.list.title)
                    .accessibilityIdentifier("ItemsTitle")
            }
            .padding(.leading, config.paddings.list.leading)
            .padding(.top, config.paddings.list.vertical)

            ForEach(items.list, content: itemView)
                .padding(.leading, config.paddings.list.leading)
                .padding(.trailing, config.paddings.list.trailing)
        }
        .padding(.bottom, config.paddings.list.vertical)
        .background(config.list.background)
        .cornerRadius(config.cornerRadius)
    }
    
    private func itemView (
        item: SavingsAccountState.Items.Item
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            factory.makeIconView(item.md5hash)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, config.icon.leading)
                .padding(.vertical, config.paddings.vertical)
                .frame(width: config.icon.widthAndHeight, height: config.icon.widthAndHeight)
                .cornerRadius(config.icon.widthAndHeight/2)
                .accessibilityIdentifier("ItemIcon")
            
            VStack(alignment: .leading) {
                
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
    
    
    func questionsView() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            state.questions.title.map { text in
                
                VStack {
                    
                    text.text(withConfig: config.list.title)
                        .padding(.leading, config.paddings.list.leading)
                        .padding(.top, config.paddings.list.vertical)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    config.divider
                        .frame(height: 0.5)
                }
            }
            
            ForEach(state.questions.questions, content: questionView)
        }
        .background(config.list.background)
        .cornerRadius(config.cornerRadius)
    }
               
    private func questionView(item: SavingsAccountState.Question) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Button(action: {
                    withAnimation {
                        
                        selectedQuestion = selectedQuestion == item ? nil : item
                    }

                }, label: {
                    
                    HStack {
                        
                        item.question.text(withConfig: config.list.item.title)
                            .accessibilityIdentifier("Question")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        config.chevronDownImage
                            .foregroundColor(.gray)
                            .rotationEffect(selectedQuestion == item ? .degrees(180) : .degrees(0))
                            .accessibilityIdentifier("ItemChevron")
                    }
                    .padding(.leading, config.paddings.list.leading)
                    .padding(.trailing, config.paddings.list.trailing)
                    .frame(height: 64)
                })
                
                if selectedQuestion == item {
                    Text(item.answer)
                        .multilineTextAlignment(.leading)
                        .accessibilityIdentifier("Answer")
                        .padding(.leading, config.paddings.list.leading)
                        .padding(.vertical, config.paddings.list.vertical)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            config.divider
                .frame(height: 0.5)
        }
    }
    
    struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

#Preview {
    
    NavigationView {
        SavingsAccountView(
            state: .preview,
            config: .preview,
            factory: .default)
    }
}

extension Color {
    
    static let gray30: Self = .init(red: 211/255, green: 211/255, blue: 211/255, opacity: 0.3)
}

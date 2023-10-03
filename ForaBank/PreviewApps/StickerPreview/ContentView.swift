//
//  ContentView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 26.09.2023.
//

import SwiftUI

struct ContentView: View {
    
    typealias ViewModel = OpenAccountItemViewModel.ViewModel
    
    private let viewModels: [ViewModel] = .openAccount
    
    var body: some View {
        VStack {
            
            ForEach(viewModels, id: \.currencyCode, content: openAccountItemView)
        }
        .padding()
    }
    
    private func openAccountItemView(
        viewModel: ViewModel
    ) -> some View {
        
        OpenAccountItemView(
            viewModel: viewModel,
            openAccountCardView: openAccountCardView,
            config: .preview
        )
    }
    
    private func openAccountCardView() -> some View {
        
        Text("CardView")
            .foregroundColor(.purple)
            .padding()
            .background(.blue.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Array where Element == OpenAccountItemViewModel.ViewModel {
    
    static let openAccount: Self = [
        .init(
            currency: "currency",
            conditionLinkURL: .init(stringLiteral: "conditionLinkURL"),
            ratesLinkURL: .init(stringLiteral: "ratesLinkURL"),
            currencyCode: 12,
            header: .init(
                title: "Header Title",
                detailTitle: "Detail Title"
            ),
            options: [
                .init(title: "Options Title 1")
            ],
            isAccountOpen: true
        )
    ]
}

extension OpenAccountItemViewModel.Config {
    
    static let preview: OpenAccountItemViewModel.Config = .init(
        rectangleColor: .red.opacity(0.2),
        configHeader: .init(
            titleFont: .title,
            titleColor: .brown,
            descriptionFont: .callout,
            descriptionColor: .secondary
        ),
        configOption: .init(
            titleFont: .largeTitle,
            titleColor: .primary,
            iconColor: .orange,
            descriptionFont: .subheadline,
            descriptionColor: .secondary
        )
    )
}

//
//  SubscriptionView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.07.2023.
//

import SwiftUI
import Combine

public class SubscriptionViewModel: ObservableObject, Identifiable {
    
    public typealias Token = String
    
    let token: Token
    public let name: String
    @Published public private(set) var image: Icon
    let subtitle: String
    let purposeTitle: String
    let trash: Image
    let config: ConfigSubscription
    let onDelete: (Token, String) -> Void
    let onDetail: (Token) -> Void
    
    public var id: Token { token }
    
    public init(
        token: SubscriptionViewModel.Token,
        name: String,
        image: Icon,
        subtitle: String,
        purposeTitle: String,
        trash: Image,
        config: ConfigSubscription,
        onDelete: @escaping (Token, String) -> Void,
        onDetail: @escaping (Token) -> Void
    ) {
        self.token = token
        self.name = name
        self.image = image
        self.subtitle = subtitle
        self.purposeTitle = purposeTitle
        self.trash = trash
        self.config = config
        self.onDelete = onDelete
        self.onDetail = onDetail
    }
    
    public enum Icon {
        
        case `default`(Image)
        case image(Image)
    }
}

public struct ConfigSubscription {

    let headerFont: Font
    let subtitle: Font
    
    public init(headerFont: Font, subtitle: Font) {
        self.headerFont = headerFont
        self.subtitle = subtitle
    }
}

struct SubscriptionView: View {
    
    let viewModel: SubscriptionViewModel
    
    var body: some View {
        
        Button(action: { viewModel.onDetail(viewModel.token) }) {
            
            VStack {
                
                HStack(spacing: 12) {
                    
                    switch viewModel.image {
                    case let .default(image):
                        logo(with: image)
                        
                    case let .image(image):
                        
                        image
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    }
                    
                    VStack(spacing: 8) {
                        
                        header(font: viewModel.config.headerFont)
                        
                        subtitle(font: viewModel.config.subtitle)
                    }
                    
                    Spacer()
                    
                    deleteButton(viewModel: viewModel)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 12)
                .padding(.trailing, 16)
            }
            .frame(height: 72)
        }
    }
    
    private func header(font: Font) -> some View {
        
        HStack {
            
            Text(viewModel.name)
                .font(font)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
    
    private func subtitle(font: Font) -> some View {
        
        HStack {
            
            Text(viewModel.subtitle)
                .font(font)
                .foregroundColor(.gray)
                .frame(alignment: .leading)
                .lineLimit(1)
            
            Spacer()
        }
    }
    
    private func deleteButton(viewModel: SubscriptionViewModel) -> some View {
        
        Button(action: { viewModel.onDelete(viewModel.token, viewModel.purposeTitle) }) {
            
            viewModel.trash
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.gray)
        }
    }
    
    private func logo(with image: Image) -> some View {
        
        VStack {
            
            ZStack {
                
                Circle()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color.green.opacity(0.4))
                
                image
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct SubscriptionView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        SubscriptionView(viewModel: .init(
            token: "Token",
            name: "Name",
            image: .default(.init(systemName: "trash")),
            subtitle: "Subtitle",
            purposeTitle: "PurposeTitle",
            trash: .init(systemName: "trash"),
            config: .init(headerFont: .body, subtitle: .callout),
            onDelete: { token, title  in },
            onDetail: { _ in })
        )
    }
}

//
//  SubscriptionView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.07.2023.
//

import SwiftUI

public struct SubscriptionViewModel: Identifiable {
    
    public typealias Token = String
    
    let token: Token
    let name: String
    let image: Image
    let subtitle: String
    let trash: Image
    let onDelete: (Token) -> Void
    
    public var id: Token { token }
    
    public init(
        token: SubscriptionViewModel.Token,
        name: String,
        image: Image,
        subtitle: String,
        trash: Image,
        onDelete: @escaping (Token) -> Void
    ) {
        self.token = token
        self.name = name
        self.image = image
        self.subtitle = subtitle
        self.trash = trash
        self.onDelete = onDelete
    }
}

struct SubscriptionView: View {
    
    let viewModel: SubscriptionViewModel
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            logo()
            
            VStack(spacing: 4) {
                
                header()
                
                subtitle()
            }
            
            Spacer()
            
            deleteButton(token: viewModel.token)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .padding(.vertical, 16)
    }
    
    private func header() -> some View {
        
        HStack {
            
            Text(viewModel.name)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
    
    private func subtitle() -> some View {
        
        HStack {
            
            Text(viewModel.subtitle)
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.3))
                .frame(alignment: .leading)
            
            Spacer()
        }
    }
    
    private func deleteButton(token: SubscriptionViewModel.Token) -> some View {
        
        Button(action: { viewModel.onDelete(token) }) {
            
            viewModel.trash
                .foregroundColor(.gray.opacity(0.3))
        }
    }
    
    private func logo() -> some View {
        
        VStack {
            
            viewModel.image
                .frame(width: 32, height: 32)
        }
    }
}

struct SubscriptionView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        SubscriptionView(viewModel: .init(
            token: "Token",
            name: "Name",
            image: .init(systemName: "image"),
            subtitle: "Subtitle",
            trash: .init(systemName: "trash"),
            onDelete: { token in })
        )
    }
}

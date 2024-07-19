//
//  ErrorView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

struct ErrorView: View {
    
    let icon: () -> Image
    let title: String
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            VStack(spacing: 24) {
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
                    .padding(20)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                
                Text("Нет подходящих операций. \n Попробуйте изменить параметры фильтра")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

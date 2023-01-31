//
//  ClientInformView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 31.01.2023.
//

import SwiftUI

struct ClientInformView: View {
    
    let viewModel: ClientInformViewModel
    @State private var contentHeight: CGFloat = 0
    private let maxHeight = UIScreen.main.bounds.height - 100
    
    var body: some View {
            
        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 24) {
                
                Circle()
                    .foregroundColor(.bGIconGrayLightest)
                    .frame(width: 64, height: 64)
                    .overlay13 { Image.ic24Tool
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                    }.padding(.top, 10)
                
                Text("Технические работы")
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    ForEach(viewModel.items) { item in
                        ClientInformItemView(viewModel: item)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
                .padding(.horizontal)
                
            }.readSize { contentHeight = $0.height }
        }
        .frame(height: maxHeight < contentHeight ? maxHeight : contentHeight)
        
    }
}

struct ClientInformItemView: View {
    
    let viewModel: ClientInformViewModel.ClientInformItemViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            Circle()
                .foregroundColor(.bGIconGrayLightest)
                .frame(width: 40, height: 40)
                .overlay13 { viewModel.icon }
            
            Text(viewModel.text)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Preview
struct ClientInformView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ClientInformView(viewModel: .init(model: .emptyMock, items: ClientInformViewModel.sampleItems))
    }
}



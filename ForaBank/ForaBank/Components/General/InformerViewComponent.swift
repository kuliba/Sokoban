//
//  InformerViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.06.2022.
//

import SwiftUI

extension InformerView {
    
    class ViewModel: ObservableObject {
        
        @Published var message: String?
        
        let icon: Image
        let color: Color
        
        init(message: String? = nil,
             icon: Image = .ic16Check,
             color: Color = .mainColorsBlack) {
            
            self.message = message
            self.icon = icon
            self.color = color
        }
    }
}

struct InformerView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        if let message = viewModel.message {
            
            ZStack {
                
                HStack(spacing: 10) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsWhite)
                    
                    Text(message)
                        .font(.textH4R16240())
                        .foregroundColor(.mainColorsWhite)
                }
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 12)
                
            }
            .background(viewModel.color)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.mainColorsBlackMedium, lineWidth: 1))
            
        } else {
            
            EmptyView()
        }
    }
}

struct InformerViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InformerView(viewModel: .init(message: "USD счет открывается", icon: .ic24RefreshCw))
            InformerView(viewModel: .init(message: "USD счет открыт"))
            InformerView(viewModel: .init(message: "USD счет не открыт", icon: .ic16Close))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

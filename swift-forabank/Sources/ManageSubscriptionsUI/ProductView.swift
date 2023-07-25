//
//  ProductView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.07.2023.
//

import SwiftUI

public struct ProductViewModel {
    
    let image: Image
    let title: String
    let paymentSystemIcon: Image?
    let name: String
    let balance: String
    let descriptions: [String]
    
    public init(
        image: Image,
        title: String,
        paymentSystemIcon: Image? = nil,
        name: String,
        balance: String,
        descriptions: [String]
    ) {
        self.image = image
        self.title = title
        self.paymentSystemIcon = paymentSystemIcon
        self.name = name
        self.balance = balance
        self.descriptions = descriptions
    }
}

public struct ProductView: View {
    
    let viewModel: ProductViewModel
    
    public init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack(alignment: .center) {
            
            HStack(alignment: .center ,spacing: 16) {
                
                viewModel.image
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    header()
                    
                    middleRow()
                    
                    description()
                    
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
        }
        .frame(height: 90)
        .padding(.horizontal, 12)
        .background(Color.clear)
    }
    
    private func header() -> some View {
        
        Text(viewModel.title)
            .font(.system(size: 18))
            .foregroundColor(Color.gray.opacity(0.3))
        
    }
    
    private func middleRow() -> some View {
        
        HStack {
            
            if let paymentSystemIcon = viewModel.paymentSystemIcon {
                
                paymentSystemIcon
                    .renderingMode(.original)
            }
            
            Text(viewModel.name)
                .lineLimit(1)
            
            Spacer()
            
            Text(viewModel.balance)
            
        }
        .font(.system(size: 16))
        .foregroundColor(.black.opacity(0.1))
    }
    
    private func description() -> some View {
        
        HStack(spacing: 8) {
            
            ForEach(viewModel.descriptions, id: \.self) { description in
                
                Circle()
                    .frame(width: 3)
                
                Text(description)
                    .font(.system(size: 18))
            }
            .foregroundColor(.gray.opacity(0.3))
            
        }
        .padding(.bottom, 12)
    }
}

struct ProductView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ProductView(viewModel: .init(
            image: .init("creditcard"),
            title: "Title",
            paymentSystemIcon: .init("personalhotspot"),
            name: "Name",
            balance: "Balance",
            descriptions: ["Description"])
        )
    }
}

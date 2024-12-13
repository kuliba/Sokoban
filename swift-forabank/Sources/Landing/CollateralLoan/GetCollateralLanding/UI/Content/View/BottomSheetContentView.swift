//
//  BottomSheetContentView.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

// Do not review, in progress!!

import SwiftUI

struct BottomSheetContentView: View {
    
    let items: [Item]
    let select: (String) -> Void

    var body: some View {
        
        ScrollView(.vertical) {

            VStack(spacing: 8) {
                
                ForEach(items, content: itemView)
            }
            
            Spacer()
        }
        .disabled(items.count < 6)
        .frame(height: height)
    }
    
    private func itemView(_ item: Item) -> some View {
        
        HStack {
            // simulacrum
            Circle()
                .fill(Color.init(red: 0.5, green: 0.8, blue: 0.76))
                .frame(
                    width: 40,
                    height: 40
                )
                .padding(16)
            
            Text(item.title)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }

    private var height: CGFloat {
        
        min((56 + 8) * CGFloat(items.count) + 20, UIScreen.main.bounds.height - 100)
    }
    
    typealias Item = GetCollateralLandingState.BottomSheet.Item
}

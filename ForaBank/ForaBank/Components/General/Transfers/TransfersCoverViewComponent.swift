//
//  TransfersCoverViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.12.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TransfersCoverView {
    
    class ViewModel: TransfersSectionViewModel {
        
        override var type: TransfersSectionType { .cover }
        let items: [PromotionViewModel]
        
        init(items: [PromotionViewModel]) {
            
            self.items = items
        }
        
        convenience init(data: [TransferAbroadResponseData.PromotionTransferData]) {
            
            let items = Self.reduce(data)
            self.init(items: items)
        }
        
    }
}

extension TransfersCoverView.ViewModel {
    
    struct PromotionViewModel: Identifiable {
        
        var id: String { title }
        
        let title: String
        let icon: Image
    }
}

extension TransfersCoverView.ViewModel {
    
    static func reduce(_ promotion: [TransferAbroadResponseData.PromotionTransferData]) -> [PromotionViewModel] {
        
        promotion.map { item in
            
            switch item.iconType {
            case .quickly: return .init(title: item.title, icon: .ic12Zap)
            case .safely: return .init(title: item.title, icon: .ic12Shield)
            case .profitably: return .init(title: item.title, icon: .ic12Percent)
            }
        }
    }
}

// MARK: - View

struct TransfersCoverView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            ForEach(viewModel.items) { item in
                
                HStack(spacing: 8) {
                    
                    item.icon
                        .foregroundColor(.mainColorsGrayMedium)

                    Text(item.title)
                        .font(.textBodySM12160())
                        .foregroundColor(.mainColorsGrayMedium)
                }
            }
        
        }.padding(.top, 8)
    }
}

// MARK: - Preview

extension TransfersCoverView.ViewModel {
    
    static let sample: TransfersCoverView.ViewModel = .init(
        items: [.init(title: "Быстро", icon: .ic12Zap),
                .init(title: "Безопасно", icon: .ic12Shield),
                .init(title: "Выгодно", icon: .ic12Percent)])
}

struct TransfersCoverView_Previews: PreviewProvider {
    static var previews: some View {
        TransfersCoverView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

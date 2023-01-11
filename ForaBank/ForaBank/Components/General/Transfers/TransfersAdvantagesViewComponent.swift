//
//  TransfersAdvantagesViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 28.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI

// MARK: - ViewModel

extension TransfersAdvantagesView {
    
    class ViewModel: TransfersSectionViewModel {
        
        typealias AdvantagesData = TransferAbroadResponseData.AdvantageTransferData
                
        override var type: TransfersSectionType { .advantages }
        let items: [AdvantagesItemViewModel]
        
        init(items: [AdvantagesItemViewModel]) {
            
            self.items = items
        }
        
        convenience init(data: AdvantagesData) {
            
            self.init(items: Self.reduce(data: data.content))
            self.title = data.title
        }
    }
}

extension TransfersAdvantagesView.ViewModel {
    
    static func reduce(data: [AdvantagesData.ContentData]) -> [AdvantagesItemViewModel] {
        
        data.map { dataItem in
        
            return .init(title: dataItem.title,
                         detailTitle: dataItem.description,
                         advantagesType: .init(rawValue: dataItem.iconType) ?? .others)
        }
    }
}

struct AdvantagesItemViewModel: Identifiable {
        
    let title: String
    let detailTitle: String
    let advantagesType: AdvantagesType
    
    var id: String { title }
    var icon: Image? { advantagesType.icon }
    
    enum AdvantagesType: String, CaseIterable {
        
        case profitably
        case immediately
        case permanently
        case comfortable
        case others
        
        var icon: Image? {
            
            switch self {
            case .profitably: return .init("Profitably")
            case .immediately: return .init("Immediately")
            case .permanently: return .init("Permanently")
            case .comfortable: return .init("Comfortable")
            case .others: return nil
            }
        }
    }
}

// MARK: - View

struct TransfersAdvantagesView: View {
    
    let viewModel: TransfersAdvantagesView.ViewModel
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading, spacing: 26) {

                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    ForEach(viewModel.items) { item in
                        AdvantagesItemView(viewModel: item)
                    }
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
            .padding(.horizontal)
        }
    }
}

struct AdvantagesItemView: View {
    
    let viewModel: AdvantagesItemViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            if let icon = viewModel.icon {
                
                icon
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 40, height: 40)
            } else {
                
                Spacer().frame(width: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.mainColorsBlack)
                
                Text(viewModel.detailTitle)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

// MARK: - Preview

extension TransfersAdvantagesView.ViewModel {
    
    static let sampleItems: [AdvantagesItemViewModel] = [
    
     .init(title: "Выгодно",
           detailTitle: "Низкие проценты",
           advantagesType: .profitably),
     .init(title: "Мгновенно",
           detailTitle: "На карту получателя",
           advantagesType: .immediately),
    .init(title: "Круглосуточно",
          detailTitle: "В мобильном приложении",
          advantagesType: .permanently),
    .init(title: "Удобно",
          detailTitle: "По номеру телефона",
          advantagesType: .comfortable),
     .init(title: "No Image",
           detailTitle: "Without icon",
           advantagesType: .others)
    ]
}

struct TransfersAdvantagesView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TransfersAdvantagesView(viewModel: .init(items: TransfersAdvantagesView.ViewModel.sampleItems))
            .fixedSize(horizontal: false, vertical: true)
            .previewLayout(.sizeThatFits)
            .padding(8)
    }
}

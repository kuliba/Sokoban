//
//  TransfersSupportViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TransfersSupportView {
    
    class ViewModel: TransfersSectionViewModel, ObservableObject {
        
        typealias SupportData = TransferAbroadResponseData.SupportTransferData
        
        override var type: TransfersSectionType { .support }
        
        let items: [ItemsViewModel]
        
        private var bindings = Set<AnyCancellable>()
        
        init(items: [ItemsViewModel]) {
            
            self.items = items
        }
        
        convenience init(data: SupportData) {
            
            self.init(items: Self.reduce(data: data.content))
            self.title = data.title
            bind()
        }
        
        private func bind() {
            
            for item in self.items {
                
                item.action
                    .receive(on: DispatchQueue.main)
                    .sink { action in

                        switch action {
                            
                        case let payload as TransfersSupportAction.Item.Tap:
                            Self.openURL(with: payload.supportType.link)
                            
                        default:
                            break
                        }

                    }.store(in: &bindings)
            }
        }
    }
}

extension TransfersSupportView.ViewModel {
    
    static func reduce(data: [SupportData.ContentData]) -> [ItemsViewModel] {
        
        data.compactMap { dataItem in
            
            if let type = ItemsViewModel.SupportType(rawValue: dataItem.iconType) {
            
                return .init(title: dataItem.title, supportType: type)
                
            } else {
                
                return nil
            }
        }
    }
    
    static func openURL(with link: String) {
        
        guard let url = URL(string: link) else {
            return
        }
        
        let application = UIApplication.shared
        
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension TransfersSupportView.ViewModel {
    
    class ItemsViewModel: Identifiable {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let supportType: SupportType
        let title: String
        
        lazy var onAction: () -> Void = { [weak self] in
            
            guard let self = self else { return }
            self.action.send(TransfersSupportAction.Item.Tap(supportType: self.supportType))
        }
        
        init(title: String, supportType: SupportType) {
            
            self.supportType = supportType
            self.title = title
        }
        
        enum SupportType: String {
            
            case telegram
            case whatsapp
            case viber
            case call
            
            var icon: Image {
                
                switch self {
                case .telegram: return .init("Telegram")
                case .whatsapp: return .init("Whatsapp")
                case .viber: return .init("Viber")
                case .call: return .init("Phone Call")
                }
            }
            
            var link: String {
                
                switch self {
                case .telegram: return .init("https://t.me/forabank_bot")
                case .whatsapp: return .init("https://wa.me/79257756555")
                case .viber: return .init("viber://pa?chatURI=forabank")
                case .call: return .init("telprompt://88001009889")
                }
            }
        }
    }
    
    // MARK: - Action

    enum TransfersSupportAction {

        enum Item {

            struct Tap: Action {

                let supportType: ItemsViewModel.SupportType
            }
        }
    }
}

// MARK: - View

struct TransfersSupportView: View {
    
    let viewModel: TransfersSupportView.ViewModel
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
                    .padding(.horizontal)
                
                ForEach(viewModel.items) { item in
                    SupportItemView(viewModel: item)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }
}

extension TransfersSupportView {
    
    struct SupportItemView: View {
        
        let viewModel: TransfersSupportView.ViewModel.ItemsViewModel

        var body: some View {
            
            Button(action: viewModel.onAction) {
                
                HStack(spacing: 10) {
                    
                    ZStack(alignment: .center) {
                        
                        Circle()
                            .foregroundColor(.mainColorsWhite)
                            .frame(width: 40, height: 40)
                        
                        viewModel.supportType.icon
                            .renderingMode(.original)
                            .frame(width: 24, height: 24)
                    }

                    Text(viewModel.title)
                        .font(.textH4R16240())
                        .foregroundColor(.mainColorsBlack)
                
                }.padding(.horizontal, 20)
            }
        }
    }
}

extension TransfersSupportView.ViewModel {
    
    static let sampleItems: [ItemsViewModel] = [
        .init(title: "Telegram", supportType: .telegram),
        .init(title: "WatsApp", supportType: .whatsapp),
        .init(title: "Viber", supportType: .viber),
        .init(title: "Call", supportType: .call)]
}

// MARK: - Preview

struct TransfersSupportView_Previews: PreviewProvider {
    static var previews: some View {
        TransfersSupportView(viewModel: .init(items: TransfersSupportView.ViewModel.sampleItems))
            .previewLayout(.sizeThatFits)
            .fixedSize(horizontal: false, vertical: true)
            .padding(8)
    }
}

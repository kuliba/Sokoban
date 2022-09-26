//
//  MainSectionFastOperationViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainSectionFastOperationView {
    
    class ViewModel: MainSectionCollapsableViewModel {
        
        override var type: MainSectionType { .fastOperations }
        @Published var items: [ButtonIconTextView.ViewModel]
        private let displayButtonsTypes: [FastOperations] = [.byQr, .byPhone, .templates]

        internal init(items: [ButtonIconTextView.ViewModel], isCollapsed: Bool) {
            
            self.items = []
            super.init(isCollapsed: isCollapsed)
            self.items = createItems()

        }
        
        init() {
            
            self.items = []
            super.init(isCollapsed: false)
            
            self.items = createItems()
        }
        
        private func createItems() -> [ButtonIconTextView.ViewModel] {
            
            displayButtonsTypes.map { type in
                
                let icon = type.icon
                let title = type.title
                let action: () -> Void = { [weak self] in
                    self?.action.send(MainSectionViewModelAction.FastPayment.ButtonTapped(operationType: type))
                }
            
                return ButtonIconTextView.ViewModel(icon: .init(image: icon, background: .circle), title: .init(text: title), orientation: .vertical, action: action)
            }
        }
        
        enum FastOperations {
            
            case byQr, byPhone, templates
            
            var title: String {
                
                switch self {
                case .byQr: return "Оплата по QR"
                case .byPhone: return "Перевод по телефону"
                case .templates: return "Шаблоны"
                }
            }
            
            var icon: Image {
                
                switch self {
                case .byQr: return .ic24BarcodeScanner2
                case .byPhone: return .ic24Smartphone
                case .templates: return .ic24Star
                }
            }
        }
    }
}


//MARK: - View

struct MainSectionFastOperationView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(alignment: .top, spacing: 4) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                       
                        ButtonIconTextView(viewModel: itemViewModel)
                            .frame(width: 80)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

//MARK: - Preview

struct MainSectionFastOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionFastOperationView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionFastOperationView.ViewModel {
    
    static let sample = MainSectionFastOperationView.ViewModel(items:[.qrPayment, .telephoneTranslation, .templates], isCollapsed: false)
}

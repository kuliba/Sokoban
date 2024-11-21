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
    
    class ViewModel: MainSectionCollapsableViewModel, ObservableObject {
        
        override var type: MainSectionType { .fastOperations }
        @Published var items: [ButtonIconTextView.ViewModel]
        private let displayButtonsTypes: [FastOperations] = [.byQr, .byPhone, .zku, .templates]

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
                
                createButtonViewModel(for: type) { [weak self] in
                    self?.action.send(MainSectionViewModelAction.FastPayment.ButtonTapped(operationType: type))
                }
            }
        }
        
        private func createButtonViewModel(for type: FastOperations, action: @escaping () -> Void) -> ButtonIconTextView.ViewModel {
            
            switch type {
            case .zku:
                return ButtonIconTextView.ViewModel(
                    icon: .init(
                        image: type.icon,
                        style: .original,
                        background: .circle,
                        badge: .init(
                            text: .init(
                                title: "0%",
                                font: .textBodySR12160(),
                                fontWeight: .bold
                            ),
                            backgroundColor: .mainColorsRed,
                            textColor: .white)
                    ),
                    title: .init(text: type.title),
                    orientation: .vertical,
                    action: action
                )
                
            default:
                return ButtonIconTextView.ViewModel(
                    icon: .init(
                        image: type.icon,
                        background: .circle
                    ),
                    title: .init(text: type.title),
                    orientation: .vertical,
                    action: action
                )
            }
        }
        
        enum FastOperations {
            
            case byQr, byPhone, templates, zku
            
            var title: String {
                
                switch self {
                case .byQr: return FastOperationsTitles.qr
                case .byPhone: return FastOperationsTitles.byPhone
                case .templates: return FastOperationsTitles.templates
                case .zku: return FastOperationsTitles.zku
                }
            }
            
            var icon: Image {
                
                switch self {
                case .byQr: return .ic24BarcodeScanner2
                case .byPhone: return .ic24Smartphone
                case .templates: return .ic24Star
                case .zku: return .ic24Bulb
                }
            }
        }
    }
}

enum FastOperationsTitles {
    
    static let qr = "Оплата по QR"
    static let byPhone = "Перевод по телефону"
    static let templates = "Шаблоны"
    static let zku = "Оплата ЖКУ"
    
}

//MARK: - View

struct MainSectionFastOperationView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(
            title: viewModel.title,
            canCollapse: false,
            isCollapsed: .constant(false)
        ) {
            
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

//
//  MainSectionFastOperationViewComponent.swift
//  Vortex
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import Foundation
import SwiftUI

// MARK: - ViewModel

extension MainSectionFastOperationView {
    
    class ViewModel: MainSectionCollapsableViewModel, ObservableObject {
        
        override var type: MainSectionType { .fastOperations }
        
        @Published var items: [ButtonIconTextView.ViewModel]
        
        typealias CreateItems = (@escaping (FastOperations) -> Void) -> [ButtonIconTextView.ViewModel]
        
        init(
            createItems: CreateItems,
            isCollapsed: Bool = false
        ) {
            self.items = []
            super.init(isCollapsed: isCollapsed)
            
            self.items = createItems { [weak self] type in
                
                self?.action.send(MainSectionViewModelAction.FastPayment.ButtonTapped(operationType: type))
            }
        }
        
        enum FastOperations { // TODO: move to composition?
            
            case byQr, byPhone, templates, utility
            
            var title: String {
                
                switch self {
                case .byQr:      return FastOperationsTitles.qr
                case .byPhone:   return FastOperationsTitles.byPhone
                case .templates: return FastOperationsTitles.templates
                case .utility:   return FastOperationsTitles.utilityPayment
                }
            }
            
            var icon: Image {
                
                switch self {
                case .byQr:      return .ic24BarcodeScanner2
                case .byPhone:   return .ic24Smartphone
                case .templates: return .ic24Star
                case .utility:   return .ic24Bulb
                }
            }
        }
    }
}

enum FastOperationsTitles {
    
    static let qr = "Оплата по QR"
    static let byPhone = "Перевод по телефону"
    static let templates = "Шаблоны"
    static let utilityPayment = "Оплата ЖКУ"
}

// MARK: - View

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

// MARK: - Preview

struct MainSectionFastOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionFastOperationView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

// MARK: - Preview Content

extension MainSectionFastOperationView.ViewModel {
    
    static let sample = MainSectionFastOperationView.ViewModel(createItems: { _ in [] }, isCollapsed: false)
}

//
//  NewProductButtonComponent.swift
//  Vortex
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import SwiftUI

// MARK: - ViewModel

extension NewProductButton {
    
    class ViewModel: ObservableObject {
        
        @Published var subTitle: String // used to update deposit rate only
        
        let type: OpenProductType
        let tapActionType: TapActionType
        
        init(
            openProductType type: OpenProductType,
            subTitle: String,
            action tapActionType: TapActionType
        ) {
            self.type = type
            self.subTitle = subTitle
            self.tapActionType = tapActionType
        }
        
        enum TapActionType {
            
            case action(() -> Void)
            case url(URL)
        }
    }
}

private extension OpenProductType {
    
    // special treatment for deposit product type to update deposit rate
    var productType: ProductType? {
        
        guard case .deposit = self else { return nil }
        
        return .deposit
    }
}

// MARK: - View

struct NewProductButton: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        switch viewModel.tapActionType {
        case let .action(action):
            Button(action: action, label: label)
                .buttonStyle(PushButtonStyle())
                .accessibilityIdentifier("buttonOpenNewProduct")
            
        case let .url(url):
            
            Link(destination: url, label: label)
                .buttonStyle(PushButtonStyle())
                .accessibilityIdentifier("linkOpenNewProduct")
        }
    }
    
    private func label() -> some View {
        
        NewProductButtonLabel(
            icon: viewModel.icon,
            title: viewModel.title,
            subTitle: viewModel.subTitle
        )
    }
}

extension NewProductButton.ViewModel {
    
    var id: String {
        
        // special treatment for deposit product type
        type.productType?.rawValue ?? type.openButtonTitle
    }
}

private extension NewProductButton.ViewModel {
    
    var icon: Image { type.openButtonIcon }
    var title: String { type.openButtonTitle }
}

struct NewProductButtonLabel: View {
    
    let icon: Image
    let title: String
    let subTitle: String
    var lineLimit: Int? = 1
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading) {
                
                icon
                    .renderingMode(.original)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(title)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                    Text(subTitle)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                        .lineLimit(lineLimit)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(11)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

struct NewProductButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            NewProductButton(viewModel: .sample)
                .previewLayout(.fixed(width: 112, height: 124))
            
            NewProductButton(viewModel: .sampleEmptySubtitle)
                .previewLayout(.fixed(width: 112, height: 124))
            
            NewProductButton(viewModel: .sampleLongSubtitle)
                .previewLayout(.fixed(width: 140, height: 80))
        }
    }
}

// MARK: - Preview Content

extension NewProductButton.ViewModel {
    
    static let sample =  NewProductButton.ViewModel.init(openProductType: .card, subTitle: "62 дня без %", action: .action({}))
    
    static let sampleAccount =  NewProductButton.ViewModel.init(openProductType: .account, subTitle: "Бесплатно", action: .action({}))
    
    static let sampleEmptySubtitle =  NewProductButton.ViewModel.init(openProductType: .card, subTitle: "", action: .action({}))
    
    static let sampleLongSubtitle =  NewProductButton.ViewModel.init(openProductType: .card, subTitle: "13,08 % годовых", action: .action({}))
}

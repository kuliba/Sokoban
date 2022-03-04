//
//  ButtonIconTextView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonIconTextView {
    
    struct ViewModel: Identifiable {
        
        let id: UUID
        let icon: Image
        let title: String
        let orientation: Orientation
        let appearance: Appearance
        let action: () -> Void
        
        enum Orientation {
            
            case vertical
            case horizontal
        }
        
        enum Appearance {
            
            case circle
            case square
        }
        
        internal init(id: UUID = UUID(), icon: Image, title: String, orientation: Orientation, appearance: Appearance, action: @escaping () -> Void) {
            self.id = id
            self.icon = icon
            self.title = title
            self.orientation = orientation
            self.appearance = appearance
            self.action = action
        }
        
        static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
            
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct ButtonIconTextView: View {
    
    var viewModel: ViewModel
    
    var body: some View {
        
        Button {
            viewModel.action()
        } label: {
            
            switch viewModel.orientation {

            case .vertical:

                VStack {
                    ZStack {
                        switch viewModel.appearance {
                                
                        case .circle:
                            RoundedRectangle(cornerRadius: 28)
                                .foregroundColor(.mainColorsGrayLightest)
                                .frame(width: 56, height: 56)
                            
                            viewModel.icon
                                .foregroundColor(.black)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                            
                        case .square:
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.mainColorsGrayLightest)
                                .frame(width: 48, height: 48)
                            
                            viewModel.icon
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                        }
                    }
                    
                    Text(verbatim: viewModel.title)
                        .font(.textBodySR12160())
                        .frame(width: 80, height: 32, alignment: .top)
                        .foregroundColor(.textSecondary)
                }
                
            case .horizontal:

                HStack {
                    ZStack {
                        
                        switch viewModel.appearance {
                                
                        case .circle:
                            RoundedRectangle(cornerRadius: 28)
                                .foregroundColor(.mainColorsGrayLightest)
                                .frame(width: 56, height: 56)
                            
                            viewModel.icon
                                .foregroundColor(.black)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                            
                        case .square:
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.mainColorsGrayLightest)
                                .frame(width: 48, height: 48)
                            
                            viewModel.icon
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                        }
                    }
                    
                    Text(verbatim: viewModel.title)
                        .font(.textBodySR12160())
                        .padding(.leading, 16)
                        .foregroundColor(.textSecondary)
                }
                .frame(width: 248, height: 48, alignment: .leading)
            }
        }
    }
}

//MARK: - Preview

struct FastOperationButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            ButtonIconTextView(viewModel: .telephoneTranslation)
            ButtonIconTextView(viewModel: .verticalSquare)
            ButtonIconTextView(viewModel: .horizontalSquare)
            ButtonIconTextView(viewModel: .horizontalCircle)
        }
    }
}

//MARK: - Preview Content

extension ButtonIconTextView.ViewModel {
    
    static let telephoneTranslation =  ButtonIconTextView.ViewModel.init(icon: .ic24Smartphone,
                                                                         title: "Перевод по телефону",
                                                                         orientation: .vertical,
                                                                         appearance: .circle,
                                                                         action: {})
    
    static let qrPayment = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2,
                                                             title: "Оплата\nпо QR",
                                                             orientation: .vertical,
                                                             appearance: .circle,
                                                             action: {})
    
    static let templates = ButtonIconTextView.ViewModel.init(icon: .ic24Star,
                                                             title: "Шаблоны",
                                                             orientation: .vertical,
                                                             appearance: .circle,
                                                             action: {})
    
    static let verticalSquare = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2,
                                                                  title: "Оплата\nпо QR",
                                                                  orientation: .vertical,
                                                                  appearance: .square,
                                                                  action: {})
    
    static let horizontalSquare = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2,
                                                                       title: "Оплата\nпо QR",
                                                                       orientation: .horizontal,
                                                                       appearance: .square,
                                                                       action: {})

    static let horizontalCircle = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2,
                                                                       title: "Оплата\nпо QR",
                                                                       orientation: .horizontal,
                                                                       appearance: .circle,
                                                                       action: {})

}

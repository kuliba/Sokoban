//
//  PaymentsSuccessLinkView.swift
//  Vortex
//
//  Created by Max Gribov on 21.03.2023.
//

import SwiftUI

//MARK: - Veiw Model

extension PaymentsSuccessLinkView {
    
    final class ViewModel: PaymentsParameterViewModel {
        
        let title: String
        let url: URL
        
        init(title: String, url: URL, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.title = title
            self.url = url
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessLink) {
            
            self.init(title: source.title, url: source.url, source: source)
        }
    }
}

//MARK: - Veiw

struct PaymentsSuccessLinkView: View {
    
    let viewModel: ViewModel
    @Environment(\.openURL) var openURL
    
    var body: some View {
        
        HStack(spacing: 11) {
            
            Image.ic24ExternalLink
                .foregroundColor(.iconGray)
                .accessibilityIdentifier("SuccessPageExternalLinkIcon")
            
            Text(viewModel.title)
                .font(.textBodyMM14200())
                .foregroundColor(.textSecondary)
                .onTapGesture {
                    
                    openURL(viewModel.url)
                }
                .accessibilityIdentifier("SuccessPageExternalLinkText")
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.mainColorsGrayLightest))
    }
}

//MARK: - Preview

struct PaymentsSuccessLinkView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSuccessLinkView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preveiw Content

extension PaymentsSuccessLinkView.ViewModel {
    
    static let sample = PaymentsSuccessLinkView.ViewModel(.init(parameterId: UUID().uuidString, title: "Вернуться в магазин", url: .init(string: "https://google.com")!))
}

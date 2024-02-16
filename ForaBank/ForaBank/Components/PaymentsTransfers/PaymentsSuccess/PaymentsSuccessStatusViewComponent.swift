//
//  PaymentsSuccessStatusView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2023.
//

import SwiftUI

//MARK: - View Model

extension PaymentsSuccessStatusView {
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {

        let icon: Image
        let color: Color
        
        init(icon: Image, color: Color, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.color = color
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessStatus) {
            
            self.init(icon: source.status.icon, color: source.status.color, source: source)
        }
    }
}

extension Payments.ParameterSuccessStatus.Status {
    
    var icon: Image {
        
        switch self {
        case .success: return .ic48Check
        case .accepted: return .ic48Clock
        case .transfer: return .ic48UploadToAccount
        case .suspended: return .ic48Clock
        case .error: return .ic48Close
        }
    }
    
    var color: Color {
        
        switch self {
        case .success: return .systemColorActive
        case .accepted: return .systemColorWarning
        case .transfer: return .systemColorWarning
        case .suspended: return .systemColorWarning
        case .error: return .systemColorError
        }
    }
}

//MARK: - View

struct PaymentsSuccessStatusView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        viewModel.icon
            .foregroundColor(.iconWhite)
            .frame(width: 88, height: 88)
            .background(Circle().foregroundColor(viewModel.color))
            .accessibilityIdentifier("SuccessPageStatusIcon")
            
    }
}

//MARK: - Preview

struct PaymentsSuccessStatusView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSuccessStatusView(viewModel: .sampleSuccess)
                .previewLayout(.fixed(width: 120, height: 120))
                .previewDisplayName("Success")
        
            PaymentsSuccessStatusView(viewModel: .sampleAccepted)
                .previewLayout(.fixed(width: 120, height: 120))
                .previewDisplayName("Accepted")
            
            PaymentsSuccessStatusView(viewModel: .sampleTransfer)
                .previewLayout(.fixed(width: 120, height: 120))
                .previewDisplayName("Transfer")
            
            PaymentsSuccessStatusView(viewModel: .sampleError)
                .previewLayout(.fixed(width: 120, height: 120))
                .previewDisplayName("Error")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSuccessStatusView.ViewModel {
    
    static let sampleSuccess = PaymentsSuccessStatusView.ViewModel(.init(status: .success))
    static let sampleAccepted = PaymentsSuccessStatusView.ViewModel(.init(status: .accepted))
    static let sampleTransfer = PaymentsSuccessStatusView.ViewModel(.init(status: .transfer))
    static let sampleError = PaymentsSuccessStatusView.ViewModel(.init(status: .error))
}

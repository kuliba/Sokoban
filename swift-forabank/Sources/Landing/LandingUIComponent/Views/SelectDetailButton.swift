//
//  SelectDetailButton.swift
//  
//
//  Created by Igor Malyarov on 05.09.2023.
//

import SwiftUI

struct SelectDetailButton: View {
    
    let detail: DetailDestination
    let selectDetail: (DetailDestination?) -> Void
    
    var body: some View {
        
        Button(
            action: { selectDetail(detail) },
            label: detailView
        )
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("SelectDetailButtonBody")
    }
    
    private func detailView() -> some View {
        
        Text(detail.description)
            .accessibilityIdentifier("SelectDetailButtonText")
    }
}

struct SelectDetailButton_Previews: PreviewProvider {
    static var previews: some View {
        
        SelectDetailButtonDemo()
    }
    
    private struct SelectDetailButtonDemo: View {
        
        @State private var alertID: AlertID?
        
        var body: some View {
            
            SelectDetailButton(
                detail: .preview,
                selectDetail: { alertID = .detail($0 ?? .init(groupID: "", viewID: "")) }
            )
        }
        
        private func alert(alertID: AlertID) -> Alert {
            
            switch alertID {
            case let .detail(detail):
                
                return Alert(title: Text(detail.description))
            }
        }
        
        enum AlertID: Identifiable, Hashable {
            
            case detail(DetailDestination)
            
            var id: Self { self }
        }
    }
}

private extension DetailDestination {
    
    static let preview: Self = .init(
        groupID: "DetailsGroupID_123",
        viewID: "DetailViewID_abc"
    )
    
    var description: String {
        "Detail with detailsGroupID \"\(groupID.rawValue)\" and detailViewID \"\(viewID.rawValue)\""
    }
}

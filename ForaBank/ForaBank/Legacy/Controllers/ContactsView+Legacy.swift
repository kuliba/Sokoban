//
//  PaymentByPhone.swift
//  ForaBank
//
//  Created by Дмитрий on 06.06.2022.
//

import Foundation
import SwiftUI

struct ContactsView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ContactsViewController {
        
        let vc = ContactsViewController()
        vc.modalPresentationStyle = .custom
  
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ContactsViewController, context: Context) {}
}

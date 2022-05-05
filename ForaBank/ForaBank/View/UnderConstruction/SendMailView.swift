//
//  SendMailView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 03.05.2022.
//

import MessageUI
import SwiftUI

struct SendMailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    var mailAddress: String
    
    static var isCanSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode

        init(presentation: Binding<PresentationMode>) {
          _presentation = presentation
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            $presentation.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator
        mailVC.setToRecipients([mailAddress])
        mailVC.setSubject("ФОРА-ОНЛАЙН")
        mailVC.setMessageBody("", isHTML: false)
        
        return mailVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation)
    }
    
}

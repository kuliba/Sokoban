//
//  ChatViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 29.04.2022.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    
    let title: String
    let subTitle: String
    let icon: Image

    var buttonBlock: ButtonBlockViewModel
    
    init() {
        self.title = "Раздел еще в разработке"
        self.subTitle = "Вы всегда можете обратиться в нашу службу поддержки с вопросами и предложениями"
        self.icon = Image("chatImage")
        self.buttonBlock = ButtonBlockViewModel()
    }
}

//MARK: - ButtonBlock ViewModel

extension ChatViewModel {

    class ButtonBlockViewModel: ObservableObject {
        @Published var isShowSendMail: Bool = false
        var buttons: [[ButtonViewModel]]
        
        init() {
            self.buttons = [[.phone(url: "telprompt://\("88001009889")", title: "8 (800) 100 9889"),
                             .email(mail: "fora-digital@forabank.ru")
                            ],
                            [.whatsapp(url: "https://api.whatsapp.com/send/?phone=%2B79257756555&text&app_absent=0"),
                             .telegram(url: "https://telegram.me/forabank_bot"),
                             .viber(url: "i don't know")
                           ]]
        }
            
        enum ButtonViewModel: Identifiable, Hashable {
            
            case phone(url: String, title: String)
            case email(mail: String)
            case whatsapp(url: String)
            case telegram(url: String)
            case viber(url: String)
            
            var id: String { self.appearance.url }
    
            var appearance: (title: String, icon: Image, url: String) {
                switch self {
                case let .email(mail): return ("Отправить e-mail", .ic24Mail, mail)
                case let .telegram(url): return ("Telegram", Image("telegram"), url)
                case let .whatsapp(url): return ("WhatsApp", Image("whatsup"), url)
                case let .viber(url): return ("Viber", Image("viber"), url)
                case let .phone(url, title): return (title, .ic24PhoneOutgoing, url)
                }
            }
        }
        
    }
}


/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

enum MessageType: String {
    case outgoing = "outgoing"
    case incoming = "incoming"
    case transferRequest = "transferRequest"
    case transferReply = "transferReply"
}

struct ChatMessage {
    let type: MessageType
    let time: String
    let message: String
    let isDelivered: Bool
    let amount: String
}

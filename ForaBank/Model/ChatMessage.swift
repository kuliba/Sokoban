//
//  Message.swift
//  ForaBank
//
//  Created by Sergey on 25/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

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

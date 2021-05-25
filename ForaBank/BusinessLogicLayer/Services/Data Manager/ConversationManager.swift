//
//  ConversationManager.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class ConversationManager {
  
  let service = FirestoreService()
  
  func currentConversations(_ completion: @escaping CompletionObject<[ObjectConversation]>) {
    guard let userID = UserManager().currentUserID() else { return }
    let query = FirestoreService.DataQuery(key: "userIDs", value: userID, mode: .contains)
    service.objectWithListener(ObjectConversation.self, parameter: query, reference: .init(location: .conversations)) { results in
      completion(results)
    }
  }
  
  func create(_ conversation: ObjectConversation, _ completion: CompletionObject<FirestoreResponse>? = nil) {
    FirestoreService().update(conversation, reference: .init(location: .conversations)) { completion?($0) }
  }
  
  func markAsRead(_ conversation: ObjectConversation, _ completion: CompletionObject<FirestoreResponse>? = nil) {
    guard let userID = UserManager().currentUserID() else { return }
    guard conversation.isRead[userID] == false else { return }
    conversation.isRead[userID] = true
    FirestoreService().update(conversation, reference: .init(location: .conversations)) { completion?($0) }
  }
}

//
//  SavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import Foundation

public struct SavingsAccountState: Equatable {
    
    let advantages: Items
    let basicConditions: Items
    let imageLink: String
    let questions: Questions
    let subtitle: String?
    let title: String
    
    public init(
        advantages: Items,
        basicConditions: Items,
        imageLink: String,
        questions: Questions,
        subtitle: String?,
        title: String
    ) {
        self.advantages = advantages
        self.basicConditions = basicConditions
        self.imageLink = imageLink
        self.questions = questions
        self.subtitle = subtitle
        self.title = title
    }
    
    public struct Questions: Equatable {
        
        let title: String?
        let questions: [Question]
        
        public init(title: String?, questions: [Question]) {
            self.title = title
            self.questions = questions
        }
    }
    
    public struct Question: Equatable, Identifiable {
        
        public let id: UUID
        let answer: String
        let question: String
        
        public init(id: UUID = .init(), answer: String, question: String) {
            self.id = id
            self.answer = answer
            self.question = question
        }
    }
    
    public struct Items: Equatable {
        
        let title: String?
        let list: [Item]
        
        public init(title: String?, list: [Item]) {
            self.title = title
            self.list = list
        }
        
        public struct Item: Equatable, Identifiable {
            
            public let id: UUID
            let md5hash: String
            let title: String
            let subtitle: String?
            
            public init(id: UUID = .init(), md5hash: String, title: String, subtitle: String?) {
                self.id = id
                self.md5hash = md5hash
                self.title = title
                self.subtitle = subtitle
            }
        }
    }
}

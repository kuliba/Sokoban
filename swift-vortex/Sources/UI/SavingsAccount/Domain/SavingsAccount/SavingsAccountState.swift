//
//  SavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import Foundation
import DropDownTextListComponent

public struct SavingsAccountState: Equatable {
    
    let advantages: ListItems
    let basicConditions: ListItems
    let imageLink: String
    let questions: Questions
    let subtitle: String?
    let title: String
    public var needShowHeader: Bool = false
    
    public init(
        advantages: ListItems,
        basicConditions: ListItems,
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
}

extension SavingsAccountState.Questions {
    
    var dropDownTextList: DropDownTextList {
        
        .init(
            title: title,
            items: questions.map { 
            
                .init(
                    title: $0.question,
                    subTitle: $0.answer
                )
            }
        )
    }
}

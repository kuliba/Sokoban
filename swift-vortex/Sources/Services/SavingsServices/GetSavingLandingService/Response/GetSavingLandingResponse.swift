//
//  GetSavingLandingResponse.swift
//
//
//  Created by Andryusina Nataly on 21.11.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetSavingLandingResponse = SerialStamped<String, GetSavingLandingData>
}

extension ResponseMapper {
    
    public struct GetSavingLandingData: Equatable {
        
        public let theme: String
        public let name: String
        public let marketing: Marketing?
        public let advantages: [Advantage]?
        public let basicConditions: [BasicCondition]?
        public let questions: [Question]?
        
        public init(
            theme: String,
            name: String,
            marketing: Marketing?,
            advantages: [Advantage]?,
            basicConditions: [BasicCondition]?,
            questions: [Question]?
        ) {
            self.theme = theme
            self.name = name
            self.marketing = marketing
            self.advantages = advantages
            self.basicConditions = basicConditions
            self.questions = questions
        }
        
        public struct Question: Equatable {
            public let question: String
            public let answer: String
            
            public init(question: String, answer: String) {
                self.question = question
                self.answer = answer
            }
        }
        
        public struct Advantage: Equatable {
            public let iconMd5hash: String
            public let title: String
            public let subtitle: String
            
            public init(iconMd5hash: String, title: String, subtitle: String) {
                self.iconMd5hash = iconMd5hash
                self.title = title
                self.subtitle = subtitle
            }
        }
        
        public struct BasicCondition: Equatable {
            public let iconMd5hash: String
            public let title: String
            
            public init(iconMd5hash: String, title: String) {
                self.iconMd5hash = iconMd5hash
                self.title = title
            }
        }
        
        public struct Marketing: Equatable {
            
            public let labelTag: String
            public let imageLink: String
            public let params: [String]
            
            public init(labelTag: String, imageLink: String, params: [String]) {
                self.labelTag = labelTag
                self.imageLink = imageLink
                self.params = params
            }
        }
    }
}

//
//  ResponseMapper+mapGetSavingLandingResponse.swift
//
//
//  Created by Andryusina Nataly on 21.11.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetSavingLandingResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetSavingLandingResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetSavingLandingResponse.init)
    }
}

private extension ResponseMapper.GetSavingLandingResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard let serial = data.serial, let product = data.product
        else { throw ResponseFailure() }
        
        self.init(
            list: [.init(product)],
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper.GetSavingLandingData {
    
    init(_ data: ResponseMapper._Data._Product) {
        
        let marketing = data.marketing ?? .init(labelTag: nil, imageLink: nil, params: nil)
        
        self.init(
            theme: data.theme.valueOrEmpty,
            name: data.name.valueOrEmpty,
            marketing: .init(marketing),
            advantages: data.advantages?.compactMap { .init($0) },
            basicConditions: data.basicConditions?.compactMap { .init($0) },
            questions: data.frequentlyAskedQuestions?.compactMap { .init($0) })
    }
}

private extension ResponseMapper.GetSavingLandingData.Marketing {
    
    init(_ data: ResponseMapper._Data._Product._Marketing) {
        
        let params = data.params ?? []
        self.init(labelTag: data.labelTag.valueOrEmpty, imageLink: data.imageLink.valueOrEmpty, params: params.map{$0})
    }
}

private extension ResponseMapper.GetSavingLandingData.Advantage {
    
    init(_ data: ResponseMapper._Data._Product._Advantage) {
        
        self.init(iconMd5hash: data.icon.valueOrEmpty, title: data.title.valueOrEmpty, subtitle: data.subTitle.valueOrEmpty)
    }
}

private extension ResponseMapper.GetSavingLandingData.BasicCondition {
    
    init(_ data: ResponseMapper._Data._Product._Condition) {
        
        self.init(iconMd5hash: data.icon.valueOrEmpty, title: data.title.valueOrEmpty)
    }
}

private extension ResponseMapper.GetSavingLandingData.Question {
    
    init(_ data: ResponseMapper._Data._Product._Question) {
        
        self.init(question: data.question.valueOrEmpty, answer: data.answer.valueOrEmpty)
        
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let product: _Product?
        
        struct _Product: Decodable {
            
            let theme: String?
            let name: String?
            let marketing: _Marketing?
            let advantages: [_Advantage]?
            let basicConditions: [_Condition]?
            let frequentlyAskedQuestions: [_Question]?
            
            struct _Marketing: Decodable {
                
                let labelTag: String?
                let imageLink: String?
                let params: [String]?
            }
            
            struct _Advantage: Decodable {
                let icon: String?
                let title: String?
                let subTitle: String?
            }
            
            struct _Condition: Decodable {
                let icon: String?
                let title: String?
            }
            
            struct _Question: Decodable {
                let question: String?
                let answer: String?
            }
        }
    }
}

extension Optional where Wrapped == String {
    
    var valueOrEmpty: String {
        
        guard let string = self else { return "" }
        
        return string
    }
}

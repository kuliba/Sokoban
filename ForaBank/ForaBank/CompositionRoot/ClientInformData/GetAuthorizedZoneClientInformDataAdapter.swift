//
//  GetAuthorizedZoneClientInformDataAdapter.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 22.10.2024.
//

import GetClientInformDataServices
import RemoteServices
import UIKitHelpers
import SwiftUI

extension GetAuthorizedZoneClientInformData {
    
    init(_ data: RemoteServices.ResponseMapper.GetAuthorizedZoneClientInformData) {
        
        self.init(
            title: data.title,
            image: .init(svg: data.svgImage),
            text: data.text.underlinedText,
            url: data.text.extractedURL
            )
    }
}

private extension String {
    
    var extractedURL: URL? {
        let pattern = #"((?:http|https)://[\w.-]+(?:\.[\w.-]+)+(?:/[\w./?%&=~-]*)?)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        
        if let match = regex.firstMatch(in: self, options: [], range: range),
           let matchRange = Range(match.range, in: self) {
            return URL(string: String(self[matchRange]))
        }
        
        return nil
    }
    
    var underlinedText: AttributedString {
        return .init(htmlStringToAttributedString)
    }
}

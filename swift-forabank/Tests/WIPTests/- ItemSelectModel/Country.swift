//
//  Country.swift
//  
//
//  Created by Igor Malyarov on 04.06.2023.
//

struct Country: Identifiable, Equatable {
    
    let id: String
    let name: String
    let md5hash: String?
}

extension Country {
    
    static let am: Self = .init(id: "AM", name: "Armenia", md5hash: "am")
    static let az: Self = .init(id: "AZ", name: "Azerbaijan", md5hash: "az")
    static let il: Self = .init(id: "IL", name: "Israel", md5hash: "il")
}

extension Array where Element == Country {
    
    static let all: Self = [.am, .az, .il]
}

//
//  Unknownable.swift
//  ForaBank
//
//  Created by Max Gribov on 30.06.2022.
//

import Foundation

protocol Unknownable: Decodable {
    
    static var unknown: Self { get }
}

extension Unknownable where Self: RawRepresentable, Self.RawValue == String {
    
    init(from decoder: Decoder) throws {
        
        do {
            
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
            
        } catch {
            
            self = .unknown
        }
    }
}

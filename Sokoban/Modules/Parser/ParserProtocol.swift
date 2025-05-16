//
//  ParserProtocol.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 14.05.2025.
//

import Foundation

protocol ParserProtocol {
    func parseCollection(name: String, data: Data) -> Collection?
    func parseLevel(_ raw: String, id: String) -> Level
}

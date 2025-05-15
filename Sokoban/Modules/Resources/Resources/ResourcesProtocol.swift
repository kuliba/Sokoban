//
//  ResourcesProtocol.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.05.2025.
//

protocol ResourcesProtocol: Sendable {
    static var shared: Resources { get }
    var collections: [Collection] { get async }
}

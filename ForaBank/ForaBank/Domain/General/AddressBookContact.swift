//
//  AddressBookContact.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.05.2022.
//

struct AddressBookContact: Identifiable {
    
    var id: String { phone }
    let phone: String
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let avatar: ImageData?
        
    var initials: String? {
        let letters = [firstName, lastName]
            .compactMap { $0?.replacingOccurrences(of: " ", with: "").first }
            .map{ $0.uppercased() }
        
        guard !letters.isEmpty else { return nil }
        return letters.reduce("", +)
    }
    
    var fullName: String? {
        
        let elements = [firstName, middleName, lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .map{ $0 + " " }
        
        guard elements.isEmpty == false else { return nil }
        return String(elements.reduce("", +).dropLast())
    }

    private func firstChar(_ str: String?) -> String {
        guard let first = str?.first else { return "" }
         return String(first)
    }

}

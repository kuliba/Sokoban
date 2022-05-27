//
//  AdressBookContact.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.05.2022.
//

struct AdressBookContact: Identifiable {
    
    var id: String { phone }
    let phone: String
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let avatar: ImageData?
        
    var initials: String? {
        let str = firstChar(firstName) + firstChar(lastName)
        return str.isEmpty ? nil : str.capitalized
    }
    
    var fullName: String? {
        var str = ""
        for elem in [firstName, middleName, lastName] {
            if let elem = elem {
                str += str.isEmpty ? elem : " " + elem
            }
        }
        
        return str.isEmpty ? nil : str
    }

    private func firstChar(_ str: String?) -> String {
        guard let str = str else { return "" }
        return String(str[str.startIndex])
    }

}

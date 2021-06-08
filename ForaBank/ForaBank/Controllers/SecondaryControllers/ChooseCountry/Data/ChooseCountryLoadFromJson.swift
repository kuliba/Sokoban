//
//  ChooseCountryLoadFromJson.swift
//  ForaBank
//
//  Created by Mikhail on 06.06.2021.
//

import UIKit


extension ChooseCountryTableViewController {
    
    
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }

    func parse(jsonData: Data) -> [Сountry] {
        do {
            let decodedData = try JSONDecoder().decode([Сountry].self, from: jsonData)
            return decodedData
        } catch {
            print("decode error")
        }
        return [Сountry]()
    }
    
    
}

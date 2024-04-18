//
//  String+splitDataType.swift
//
//
//  Created by Igor Malyarov on 03.04.2024.
//

extension String {
    
    /// Значение в виде «ключ=значение» через разделитель. Строка начинается с определения пары разделителей (первый – разделитель ключа и значения, второй – разделитель таких пар). Ключ – то, что будет записано в доп. реквизит. Значение – то, что увидит клиент. Например: «=;1=Москва;2=Краснодар;3=Самара»
    func splitDataType() throws -> [(key: String, value: String)] {
        
        enum SplitError: Error {
            
            case tooShortString
        }
        
        let body = dropFirst(2)
        
        guard
            let keyValueSeparator = first,
            let pairsSeparator = prefix(2).last,
            !body.isEmpty
        else { throw SplitError.tooShortString }
        
        return body.split(separator: pairsSeparator).compactMap {
            
            let splits = $0.split(separator: keyValueSeparator, maxSplits: 2)
            
            guard splits.count == 2,
                  let key = splits.first, !key.isEmpty,
                  let value = splits.last, !value.isEmpty
            else { return nil }
            
            return (.init(key), .init(value))
        }
    }
}

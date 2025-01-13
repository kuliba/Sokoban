//
//  Masker.swift
//  
//
//  Created by Igor Malyarov on 26.12.2024.
//

/// Utility for applying textual input masks to user-entered strings.
public enum Masker {}
    
public extension Masker {
    
    // MARK: - Token Definition
    
    /// Represents a piece of the parsed mask: a placeholder for digits or characters, or a literal string.
    enum MaskToken {
        
        /// A placeholder that requires `count` digits (0–9).
        case digit(count: Int)
        
        /// A placeholder that requires `count` arbitrary characters.
        case char(count: Int)
        
        /// A literal string inserted verbatim into the output.
        case literal(String)
    }
    
    // MARK: - primary method
    
    /// Applies `mask` to `input`. If `mask` is nil or empty, returns `input` as-is.
    ///
    /// - Parameters:
    ///   - input: The raw user-entered string.
    ///   - mask: The mask pattern, where digits are denoted by e.g. `"N"` or `"3N"`,
    ///           and arbitrary characters by `"_"` or `"5_"`. Other characters are treated as literals.
    /// - Returns: A new string formatted according to the mask.
    static func mask(
        _ input: String,
        with mask: String?
    ) -> String {
        
        let maskString = mask ?? ""
        
        guard !maskString.isEmpty else { return input }
        
        let tokens = parseMask(maskString)
        return applyTokens(tokens, to: input)
    }
}

extension Masker {
    
    // MARK: - Parsing
    
    /// Parses `mask` into an array of `MaskToken` placeholders and literals.
    ///
    /// - Parameter mask: A string describing the format (e.g. `"3N-__"`).
    /// - Returns: An ordered list of tokens (`digit`, `char`, or `literal`) to be applied later.
    static func parseMask(
        _ mask: String
    ) -> [MaskToken] {
        
        var tokens = [MaskToken]()
        let chars = Array(mask)
        var index = 0
        
        while index < chars.count {
            let c = chars[index]
            
            if c.isNumber {
                var numString = ""
                while index < chars.count, chars[index].isNumber {
                    numString.append(chars[index])
                    index += 1
                }
                
                guard index < chars.count else {
                    tokens.append(.literal(numString))
                    break
                }
                
                let nextChar = chars[index]
                index += 1
                
                if let count = Int(numString) {
                    switch nextChar {
                    case "N":
                        tokens.append(.digit(count: count))
                    case "_":
                        tokens.append(.char(count: count))
                    default:
                        tokens.append(.literal(numString + String(nextChar)))
                    }
                } else {
                    tokens.append(.literal(numString + String(nextChar)))
                }
            }
            else if c == "N" {
                tokens.append(.digit(count: 1))
                index += 1
            }
            else if c == "_" {
                tokens.append(.char(count: 1))
                index += 1
            }
            else {
                tokens.append(.literal(String(c)))
                index += 1
            }
        }
        
        return tokens
    }
    
    // MARK: - Apply Tokens
    
    /// Consumes characters from `input` according to the parsed tokens and returns a formatted output.
    ///
    /// - Parameters:
    ///   - tokens: The sequence of placeholders and literals (from `parseMask`).
    ///   - input: The user-entered text to be formatted.
    /// - Returns: The formatted string.
    static func applyTokens(
        _ tokens: [MaskToken],
        to input: String
    ) -> String {
        
        let chars = Array(input)
        var index = 0
        var result = ""
        
        for token in tokens {
            switch token {
            case .digit(let count):
                var taken = 0
                while taken < count, index < chars.count {
                    if chars[index].isNumber {
                        result.append(chars[index])
                        taken += 1
                    }
                    index += 1
                }
                
            case .char(let count):
                var taken = 0
                while taken < count, index < chars.count {
                    result.append(chars[index])
                    taken += 1
                    index += 1
                }
                
            case .literal(let s):
                result.append(s)
            }
        }
        
        return result
    }
}

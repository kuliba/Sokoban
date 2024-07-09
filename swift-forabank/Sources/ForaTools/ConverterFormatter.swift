//
//  ConverterFormatter.swift
//
//
//  Created by Igor Malyarov on 05.07.2024.
//

import Foundation

/// A utility class for cleaning up and formatting numeric strings based on a specified locale.
public final class ConverterFormatter {
    
    private let locale: Locale
    
    /// Initialises a converter formatter with the given locale.
    ///
    /// - Parameter locale: The locale to use for number formatting and cleaning up.
    public init(
        locale: Locale
    ) {
        self.locale = locale
    }
}

public extension ConverterFormatter {
    
    /// Converts and formats the input string into a formatted numeric string with a specified delimiter.
    ///
    /// - Parameters:
    ///   - input: The input string containing the numeric value.
    ///   - delimiter: The character to use as a delimiter in the formatted string.
    /// - Returns: A formatted numeric string with the specified delimiter, or `nil` if formatting fails.
    func convertAndFormat(
        _ input: String,
        delimiter: Character
    ) -> String? {
        
        // Cleanup the input
        let cleanedInput = cleanup(input)
        
        // Convert to decimal using the locale's formatter
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        
        guard let number = formatter.number(from: cleanedInput)?.decimalValue
        else { return nil }
        
        // Convert decimal number to string with the provided delimiter and no thousand separators
        let resultFormatter = NumberFormatter()
        resultFormatter.numberStyle = .decimal
        resultFormatter.minimumFractionDigits = 0
        resultFormatter.maximumFractionDigits = formatter.maximumFractionDigits
        resultFormatter.groupingSeparator = ""
        resultFormatter.decimalSeparator = String(delimiter)
        
        guard let formattedString = resultFormatter.string(from: number as NSNumber)
        else { return nil }
        
        return formattedString
    }
    
    /// Cleans up the input string by removing whitespace and preserving numeric characters and the decimal separator.
    ///
    /// - Parameter input: The input string to be cleaned up.
    /// - Returns: A cleaned up string containing only numeric characters and the decimal separator.
    func cleanup(_ input: String) -> String {
        
        // Trim whitespaces
        var cleanedString = input.trimmingCharacters(in: .whitespaces)
        
        // Get the decimal separator from the locale
        guard let decimalSeparator = locale.decimalSeparator
        else { return cleanedString }
        
        // Remove non-digits and preserve delimiter
        let digitSet = CharacterSet.decimalDigits
        cleanedString = cleanedString.filter {
            
            digitSet.contains(Unicode.Scalar(String($0))!) ||
            $0 == decimalSeparator.first
        }
        
        return cleanedString
    }
}

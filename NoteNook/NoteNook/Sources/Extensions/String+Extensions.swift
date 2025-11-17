//  macOS-only: String helpers used within a macOS-only AppKit application.
//  String+Extensions.swift
//  NoteNook
//
//  Useful string extensions for the application.
//  Swift 6 compatible with Sendable conformance.
//

import Foundation

extension String {
    
    /// Truncates the string to the specified length and adds ellipsis if needed
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            let index = self.index(self.startIndex, offsetBy: length)
            return String(self[..<index]) + trailing
        }
        return self
    }
    
    /// Returns true if the string is empty or contains only whitespace
    var isBlankOrEmpty: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}


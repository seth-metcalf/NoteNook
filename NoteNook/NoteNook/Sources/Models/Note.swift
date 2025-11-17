//  macOS-only: Note model used by a macOS-only AppKit application.
//  Note.swift
//  NoteNook
//
//  Model representing a single note with its metadata.
//  Swift 6 compatible with Sendable conformance.
//

import Foundation

struct Note: Codable, Identifiable, Sendable {
    
    // MARK: - Properties
    
    let id: UUID
    var title: String
    var content: String
    let createdAt: Date
    var modifiedAt: Date
    
    // MARK: - Initialization
    
    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date(), modifiedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    // MARK: - Computed Properties
    
    var preview: String {
        let maxLength = 100
        if content.count > maxLength {
            let index = content.index(content.startIndex, offsetBy: maxLength)
            return String(content[..<index]) + "..."
        }
        return content
    }
    
    var formattedCreatedDate: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    
    var formattedModifiedDate: String {
        modifiedAt.formatted(date: .abbreviated, time: .shortened)
    }
    
    var relativeTime: String {
        modifiedAt.formatted(.relative(presentation: .named))
    }
}

// MARK: - Equatable

extension Note: Equatable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension Note: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

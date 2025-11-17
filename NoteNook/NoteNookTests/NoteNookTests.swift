//
//  NoteNookTests.swift
//  NoteNookTests
//
//  Unit tests for the NoteNook application.
//

import XCTest
@testable import NoteNook

final class NoteNookTests: XCTestCase {
    
    var notesManager: NotesManager!
    
    override func setUpWithError() throws {
        // Initialize notes manager for each test
        notesManager = NotesManager.shared
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        notesManager = nil
    }
    
    func testNoteCreation() throws {
        // Test that a note can be created with proper properties
        let note = Note(title: "Test Note", content: "This is a test note")
        
        XCTAssertNotNil(note.id)
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.content, "This is a test note")
        XCTAssertNotNil(note.createdAt)
        XCTAssertNotNil(note.modifiedAt)
    }
    
    func testNoteEquality() throws {
        // Test that notes with the same ID are considered equal
        let id = UUID()
        let note1 = Note(id: id, title: "Note", content: "Content")
        let note2 = Note(id: id, title: "Different", content: "Different")
        
        XCTAssertEqual(note1, note2)
    }
    
    func testNotePreview() throws {
        // Test that note preview truncates long content
        let shortContent = "Short note"
        let shortNote = Note(title: "Short", content: shortContent)
        XCTAssertEqual(shortNote.preview, shortContent)
        
        let longContent = String(repeating: "a", count: 150)
        let longNote = Note(title: "Long", content: longContent)
        XCTAssertTrue(longNote.preview.hasSuffix("..."))
        XCTAssertLessThanOrEqual(longNote.preview.count, 103) // 100 + "..."
    }
    
    func testStringExtensions() throws {
        // Test string truncation
        let longString = "This is a very long string"
        let truncated = longString.truncated(to: 10)
        XCTAssertEqual(truncated, "This is a ...")
        
        // Test blank or empty check
        XCTAssertTrue("".isBlankOrEmpty)
        XCTAssertTrue("   ".isBlankOrEmpty)
        XCTAssertFalse("text".isBlankOrEmpty)
    }
}

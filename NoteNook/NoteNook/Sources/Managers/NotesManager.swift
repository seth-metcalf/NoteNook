//
//  NotesManager.swift
//  NoteNook
//
//  Manages note storage, retrieval, and persistence with encryption.
//  Provides a centralized, thread-safe interface for note operations.
//  Swift 6 compatible with full concurrency support.
//  macOS-only: This implementation is designed exclusively for macOS and uses AppKit-integrated patterns.
//

import Foundation
import OSLog

@MainActor
final class NotesManager: Sendable {
    
    // MARK: - Singleton
    
    static let shared = NotesManager()
    
    // MARK: - Properties
    
    private var notes: [Note] = []
    private let encryptionManager = EncryptionManager.shared
    private let notesKey = "EncryptedNotes"
    private let logger = Logger(subsystem: "com.notenook.NoteNook", category: "NotesManager")
    
    // MARK: - Initialization
    
    private init() {
        Task {
            await loadNotes()
        }
    }
    
    // MARK: - Public Methods
    
    func addNote(_ note: Note) {
        notes.insert(note, at: 0)
        Task {
            await saveNotes()
        }
        logger.info("Note added: \(note.title)")
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        Task {
            await saveNotes()
        }
        logger.info("Note deleted: \(note.title)")
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            Task {
                await saveNotes()
            }
            logger.info("Note updated: \(note.title)")
        }
    }
    
    func getAllNotes() -> [Note] {
        return notes
    }
    
    func getRecentNotes(limit: Int) -> [Note] {
        return Array(notes.prefix(limit))
    }
    
    func searchNotes(query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Encrypted Persistence
    
    func saveNotes() async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let jsonData = try encoder.encode(notes)
            
            // Encrypt the JSON data
            guard let encryptedData = await encryptionManager.encrypt(jsonData) else {
                logger.error("Failed to encrypt notes")
                return
            }
            
            // Store encrypted data locally
            let fileURL = getNotesFileURL()
            try encryptedData.write(to: fileURL, options: [.atomic, .completeFileProtection])
            
            logger.info("✅ Notes saved and encrypted successfully (\(self.notes.count) notes)")
        } catch {
            logger.error("Failed to save notes: \(error.localizedDescription)")
        }
    }
    
    private func loadNotes() async {
        do {
            let fileURL = getNotesFileURL()
            
            // Check if file exists
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                logger.info("No saved notes file found - starting fresh")
                return
            }
            
            // Read encrypted data
            let encryptedData = try Data(contentsOf: fileURL)
            
            // Decrypt the data
            guard let decryptedData = await encryptionManager.decrypt(encryptedData) else {
                logger.error("Failed to decrypt notes")
                return
            }
            
            // Decode JSON
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let decodedNotes = try decoder.decode([Note].self, from: decryptedData)
            notes = decodedNotes
            
            logger.info("✅ Loaded and decrypted \(self.notes.count) notes")
        } catch {
            logger.error("Failed to load notes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - File Management
    
    private func getNotesFileURL() -> URL {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupportURL.appendingPathComponent("com.notenook.NoteNook", conformingTo: .directory)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        return appDirectory.appendingPathComponent("notes.encrypted", conformingTo: .data)
    }
    
    // MARK: - Security
    
    /// Verifies encryption is working correctly
    func verifyEncryption() async -> Bool {
        return await encryptionManager.verifyEncryption()
    }
}

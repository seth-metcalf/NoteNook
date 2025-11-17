//
//  MenuBarController.swift
//  NoteNook
//
//  Manages the menu bar icon and dropdown menu for quick note access.
//  Provides the main user interface for interacting with notes from the menu bar.
//  Swift 6 compatible with macOS 16 Tahoe APIs.
//

import Cocoa
import OSLog

@MainActor
final class MenuBarController: NSObject {
    
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private let menu = NSMenu()
    private let notesManager = NotesManager.shared
    private let logger = Logger(subsystem: "com.notenook.NoteNook", category: "MenuBar")
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupMenuBar()
        setupMenu()
    }
    
    // MARK: - Setup Methods
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        NSLog("NSStatusItem created: \(statusItem != nil)")
        
        guard let statusItem = statusItem else { return }
        
        if let button = statusItem.button {
            if let symbolImage = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "NoteNook") {
                button.image = symbolImage
                button.image?.isTemplate = true
            } else {
                button.title = "NoteNook"
            }
        } else {
            NSLog("StatusItem button is nil")
        }
        
        statusItem.isVisible = true
        statusItem.menu = menu
        NSLog("StatusItem visible: \(statusItem.isVisible)")
        
        logger.info("✅ Menu bar icon configured")
    }
    
    private func setupMenu() {
        // Add menu items
        menu.addItem(withTitle: "Quick Note", action: #selector(createQuickNote), keyEquivalent: "n")
        menu.addItem(NSMenuItem.separator())
        
        // Add notes section (will be dynamically updated)
        updateNotesMenu()
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        menu.addItem(NSMenuItem.separator())
        
        // Security indicator with macOS 16 Tahoe branding
        let securityItem = NSMenuItem(title: "🔒 Local, Private & Encrypted", action: nil, keyEquivalent: "")
        securityItem.isEnabled = false
        menu.addItem(securityItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit NoteNook", action: #selector(quitApp), keyEquivalent: "q")
    }
    
    private func updateNotesMenu() {
        // Remove old note items (keep first 2 items and last 5 items)
        while menu.items.count > 7 {
            menu.removeItem(at: 2)
        }
        
        // Add recent notes
        let recentNotes = notesManager.getRecentNotes(limit: 5)
        
        if recentNotes.isEmpty {
            let noNotesItem = NSMenuItem(title: "No notes yet", action: nil, keyEquivalent: "")
            noNotesItem.isEnabled = false
            menu.insertItem(noNotesItem, at: 2)
        } else {
            for (index, note) in recentNotes.enumerated() {
                let noteTitle = note.title.isEmpty ? "Untitled Note" : note.title
                let noteItem = NSMenuItem(title: noteTitle, action: #selector(openNote(_:)), keyEquivalent: "")
                noteItem.representedObject = note
                menu.insertItem(noteItem, at: 2 + index)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func createQuickNote() {
        let alert = NSAlert()
        alert.messageText = "Create Quick Note"
        alert.informativeText = "Enter your note:"
        alert.alertStyle = .informational
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 60))
        textField.placeholderString = "Type your note here..."
        alert.accessoryView = textField
        
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn && !textField.stringValue.isEmpty {
            let note = Note(title: textField.stringValue, content: textField.stringValue)
            notesManager.addNote(note)
            updateNotesMenu()
            logger.info("✅ Quick note created and encrypted")
        }
    }
    
    @objc private func openNote(_ sender: NSMenuItem) {
        guard let note = sender.representedObject as? Note else { return }
        
        let alert = NSAlert()
        alert.messageText = note.title
        alert.informativeText = "\(note.content)\n\n\(note.relativeTime)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Delete")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            notesManager.deleteNote(note)
            updateNotesMenu()
            logger.info("✅ Note deleted")
        }
    }
    
    @objc private func openPreferences() {
        let preferencesWindow = PreferencesWindow()
        preferencesWindow.showWindow()
    }
    
    @objc private func quitApp() {
        logger.info("User requested quit")
        NSApplication.shared.terminate(nil)
    }
}

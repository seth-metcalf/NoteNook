//
//  PreferencesWindow.swift
//  NoteNook
//
//  Preferences window for app settings and configuration.
//  Swift 6 compatible with macOS 16 Tahoe APIs.
//

import Cocoa
import OSLog

@MainActor
final class PreferencesWindow: NSObject {
    
    // MARK: - Properties
    
    private var window: NSWindow?
    private let logger = Logger(subsystem: "com.notenook.NoteNook", category: "Preferences")
    
    // MARK: - Public Methods
    
    func showWindow() {
        if window == nil {
            createWindow()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        logger.info("Preferences window opened")
    }
    
    // MARK: - Private Methods
    
    private func createWindow() {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 380),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "NoteNook Preferences"
        window.center()
        window.isReleasedWhenClosed = false
        
        // Create content view
        let contentView = createContentView()
        window.contentView = contentView
        
        self.window = window
    }
    
    private func createContentView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 380))
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "Preferences")
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.frame = NSRect(x: 20, y: 320, width: 440, height: 40)
        view.addSubview(titleLabel)
        
        // Security section
        let securityLabel = NSTextField(labelWithString: "Security & Privacy")
        securityLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        securityLabel.frame = NSRect(x: 20, y: 280, width: 440, height: 20)
        view.addSubview(securityLabel)
        
        // Encryption info with macOS 16 Tahoe branding
        let encryptionInfo = NSTextField(wrappingLabelWithString: "🔒 All notes are encrypted with AES-256-GCM and stored locally on your device. Your encryption key is securely stored in the macOS Keychain and never leaves your device.\n\n✨ Optimized for macOS 16 Tahoe with Swift 6 concurrency.")
        encryptionInfo.font = NSFont.systemFont(ofSize: 12)
        encryptionInfo.textColor = .secondaryLabelColor
        encryptionInfo.frame = NSRect(x: 20, y: 180, width: 440, height: 90)
        view.addSubview(encryptionInfo)
        
        // General section
        let generalLabel = NSTextField(labelWithString: "General")
        generalLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        generalLabel.frame = NSRect(x: 20, y: 140, width: 440, height: 20)
        view.addSubview(generalLabel)
        
        // Launch at login checkbox
        let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Launch at login", target: nil, action: nil)
        launchAtLoginCheckbox.frame = NSRect(x: 20, y: 110, width: 440, height: 20)
        view.addSubview(launchAtLoginCheckbox)
        
        // Show in dock checkbox
        let showInDockCheckbox = NSButton(checkboxWithTitle: "Show icon in Dock", target: nil, action: nil)
        showInDockCheckbox.frame = NSRect(x: 20, y: 80, width: 440, height: 20)
        view.addSubview(showInDockCheckbox)
        
        // Notes section
        let notesLabel = NSTextField(labelWithString: "Notes")
        notesLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        notesLabel.frame = NSRect(x: 20, y: 40, width: 440, height: 20)
        view.addSubview(notesLabel)
        
        // Max notes to display
        let maxNotesLabel = NSTextField(labelWithString: "Maximum notes in menu:")
        maxNotesLabel.frame = NSRect(x: 20, y: 10, width: 200, height: 20)
        view.addSubview(maxNotesLabel)
        
        let maxNotesField = NSTextField(frame: NSRect(x: 230, y: 10, width: 60, height: 20))
        maxNotesField.placeholderString = "5"
        view.addSubview(maxNotesField)
        
        return view
    }
}

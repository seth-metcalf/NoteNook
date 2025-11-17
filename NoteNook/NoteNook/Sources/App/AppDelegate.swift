//
//  AppDelegate.swift
//  NoteNook
//
//  Main application delegate for the NoteNook menu bar app.
//  Handles application lifecycle and initializes core components.
//  Swift 6 compatible with macOS 16 Tahoe APIs.
//

import Cocoa
import OSLog

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var menuBarController: MenuBarController?
    private let notesManager = NotesManager.shared
    private let logger = Logger(subsystem: "com.notenook.NoteNook", category: "AppDelegate")
    
    // MARK: - Application Lifecycle
    
    nonisolated func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("applicationDidFinishLaunching")
        Task { @MainActor in
            await initializeApp()
        }
    }
    
    private func initializeApp() async {
        NSLog("initializeApp start")
        logger.info("🚀 NoteNook launching on macOS 16 Tahoe...")
        
        // Verify encryption is working
        let encryptionWorking = await notesManager.verifyEncryption()
        if encryptionWorking {
            logger.info("✅ AES-256-GCM encryption system verified and operational")
        } else {
            logger.error("❌ Encryption verification failed - app may not function correctly")
        }
        
        // Set up the menu bar controller
        menuBarController = MenuBarController()
        NSLog("MenuBarController created: \(menuBarController != nil)")
        
        // Hide the dock icon to make this a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        logger.info("✅ NoteNook launched successfully - Local, Private & Encrypted")
    }
    
    nonisolated func applicationWillTerminate(_ aNotification: Notification) {
        Task { @MainActor in
            await shutdown()
        }
    }
    
    private func shutdown() async {
        logger.info("🛑 NoteNook shutting down...")
        
        // Save any pending data before termination
        await notesManager.saveNotes()
        
        logger.info("✅ NoteNook terminated cleanly - All data encrypted and saved")
    }
    
    nonisolated func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

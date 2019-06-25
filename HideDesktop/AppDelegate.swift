//
//  AppDelegate.swift
//  HideDesktop
//
//  Created by Derek Carter on 3/5/19.
//  Copyright © 2019 Derek Carter. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var desktopIsHidden: String = "false"
    let statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menuItem: NSMenuItem = NSMenuItem.init(title: "Hide Desktop Icons", action: #selector(didSelectHideMenuItem(sender:)), keyEquivalent: "")
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Status bar icon
        let statusIcon = NSImage.init(named: "DesktopIcon-Transparent")
        statusIcon?.isTemplate = true
        statusItem.image = statusIcon
        
        // Menu
        let menu = NSMenu()
        menu.addItem(self.menuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.init(title: "Quit", action: #selector(didSelectQuitMenuItem), keyEquivalent: ""))
        
        // Read previous state
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.finder", "CreateDesktop"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        let file = pipe.fileHandleForReading
        task.launch()
        
        desktopIsHidden = NSString.init(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue)! as String
        desktopIsHidden = desktopIsHidden.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Desktop is set to hide
        if desktopIsHidden == "false" {
            menuItem.title = "Show Desktop Icons"
        }
        else {
            menuItem.title = "Hide Desktop Icons"
        }
        
        // Set the new menu to the status item
        statusItem.menu = menu
    }
    
    
    // MARK: - Menu Action Methods
    
    @objc func didSelectHideMenuItem(sender: NSMenuItem) {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        
        if desktopIsHidden == "true" {
            task.arguments = ["write", "com.apple.finder", "CreateDesktop", "false"]
            desktopIsHidden = "false"
            menuItem.title = "Show Desktop Icons"
        }
        else {
            task.arguments = ["write", "com.apple.finder", "CreateDesktop", "true"]
            desktopIsHidden = "true"
            menuItem.title = "Hide Desktop Icons"
        }
        task.launch()
        task.waitUntilExit()
        
        let kill = Process()
        kill.launchPath = "/usr/bin/killall"
        kill.arguments = ["Finder"]
        kill.launch()
    }
    
    @objc func didSelectQuitMenuItem() {
        // Force icons to appear on quit
        if desktopIsHidden == "false" {
            let task = Process()
            task.launchPath = "/usr/bin/defaults"
            task.arguments = ["write", "com.apple.finder", "CreateDesktop", "true"]
            desktopIsHidden = "true"
            task.launch()
            task.waitUntilExit()
            
            let kill = Process()
            kill.launchPath = "/usr/bin/killall"
            kill.arguments = ["Finder"]
            kill.launch()
        }
        NSApplication.shared.terminate(self)
    }
    
}

//
//  ThermoApp.swift
//  Thermo
//
//  Created by Heiko Panjas on 19.07.24.
//

import SwiftUI

@main
struct ThermoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


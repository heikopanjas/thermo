import SwiftUI
import WeatherKit
import CoreLocation
import LaunchAtLogin

class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    var statusItem: NSStatusItem!
    var weatherService = WeatherService.shared
    var locationManager = CLLocationManager()
    var updateTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaultSettings = ["startAtLogin": "false"]
        UserDefaults.standard.register(defaults: defaultSettings)

        // Initialize Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "-"

        statusItem.menu = NSMenu()
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.tag = 0
        statusItem.menu?.addItem(settingsItem)

        statusItem.menu?.addItem(.separator())

        let startAtLoginItem = NSMenuItem(title: "Start at Login", action: #selector(startAtLogin), keyEquivalent: "")
        startAtLoginItem.tag = 1
        statusItem.menu?.addItem(startAtLoginItem)

        let aboutItem = NSMenuItem(title: "About...", action: #selector(about), keyEquivalent: "")
        aboutItem.tag = 2
        statusItem.menu?.addItem(aboutItem)

        statusItem.menu?.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.tag = 3
        statusItem.menu?.addItem(quitItem)

        updateMenuStatus()

        // Initialize Location Manager
        locationManager.delegate = self
//        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100

        // Set up timer to update weather every minute
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem);
    }

    @objc func requestLocation() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            fetchWeather(for: location)

//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { (placemarks, _) in
//                if let placemark = placemarks?.first {
//                    if let subAdministrativeArea = placemark.subAdministrativeArea {
//                        print("\(subAdministrativeArea)")
//                    }
//                }
//            }

            locationManager.stopUpdatingLocation()
        }
    }

    func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let apparentTemperature = weather.currentWeather.apparentTemperature
                updateMenuBar(with: apparentTemperature)
            } catch {
                print("Failed to fetch weather: \(error)")
            }
        }
    }

    func updateMenuBar(with temperature: Measurement<UnitTemperature>) {
        DispatchQueue.main.async {
            self.statusItem.button?.title = String(format: "%.1f°", temperature.value)
        }
    }

    func updateMenuStatus() {
        let userDefaults = UserDefaults.standard
        for menuItem in statusItem.menu!.items {
            if menuItem.tag == 1 {
                if userDefaults.bool(forKey: "startAtLogin") {
                    menuItem.state = .on
                    LaunchAtLogin.isEnabled = true
                }
                else {
                    menuItem.state = .off
                    LaunchAtLogin.isEnabled = false                }
            }
        }
    }

    @objc func showSettings(_ sender: NSMenuItem) {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        guard let viewController = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
//            return
//        }
//
//        let popoverView = NSPopover()
//        popoverView.contentViewController = viewController
//        popoverView.behavior = .transient
//        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }

    @objc func startAtLogin() {
        let userDefaults = UserDefaults.standard
        let start = userDefaults.bool(forKey: "startAtLogin")
        for menuItem in statusItem.menu!.items {
            if menuItem.tag == 1 {
                userDefaults.set(start ? false : true, forKey: "startAtLogin")
            }
        }
        updateMenuStatus()
    }

    @objc func about() {
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

}


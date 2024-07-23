import SwiftUI
import WeatherKit
import CoreLocation

@Observable class ViewModel: NSObject, CLLocationManagerDelegate {
    var temperature: Double = 0.0
    var apparentTemperature: Double = 0.0
    var place = "You are here"

    private var locationManager = CLLocationManager()
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private var updateTimer: Timer?
    private var weatherService = WeatherService.shared

    override init() {
        super.init()

        // Initialize Location Manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100

        // Set up timer to update weather every 10 minutes
        updateTimer = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: true)
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    @objc func requestLocation() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            locationManager.stopUpdatingLocation()
            Task {
                await reverseGeocodeLocation(location: location)
                await fetchWeather(for: location)
            }
        }
    }

    private func fetchWeather(for location: CLLocation) async -> Void {
        do {
            let weather = try await weatherService.weather(for: location)
            temperature = weather.currentWeather.temperature.value
            apparentTemperature = weather.currentWeather.apparentTemperature.value
        } catch {
            print("Failed to fetch weather: \(error)")
        }
    }

    private func reverseGeocodeLocation(location: CLLocation) async -> Void {
        do {
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                place = ""
                if let thoroughfare = placemark.thoroughfare, let subThoroughfare = placemark.subThoroughfare {
                    place += thoroughfare + " " + subThoroughfare
                }
                if let postalCode = placemark.postalCode, let locality = placemark.locality {
                    if place.isEmpty == false {
                        place += ", "
                    }
                    place += postalCode + " " + locality
                    if let subLocality = placemark.subLocality {
                        if place.isEmpty == false {
                            place += "-"
                        }
                        place += subLocality
                    }
                }
                if place.isEmpty == true {
                    place = "You are here"
                }
            }
        } catch {
            print("Failed to reverse geocode location: \(error)")
        }
    }
}

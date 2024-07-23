import SwiftUI

@main
struct ThermoApp: App {
    @State var viewModel = ViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Text(String(format: "%.1f°", viewModel.apparentTemperature))
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }
}


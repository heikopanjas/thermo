import MapKit
import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.black)
            .scaleEffect(configuration.isPressed ? 2.0 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ContentView: View {
    @State private var viewModel = ViewModel();
    @State private var cameraRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.518889, longitude: 13.365278), span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)))

    var body: some View {
        VStack {
            HStack {
                Text(viewModel.place)
                    .font(.headline)
                Spacer()
                HStack {
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    }
                    .buttonStyle(GrowingButton())
                    .focusable(false)
                }
            }
            .padding()
            Map(position: $cameraRegion, interactionModes: .zoom)
            {
                Annotation(coordinate: viewModel.coordinate, anchor: .leading) {
                    Text(String(format: "%.1f°", viewModel.apparentTemperature))
                        .font(.title)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(.opacity(0.125))
                        .foregroundStyle(.black)
                        .clipShape(.capsule(style: .continuous))
                } label: {
                }
            }
            .onAppear() {
                withAnimation {
                    cameraRegion = .region(updateCameraRegion())
                }
            }
            .onChange(of: viewModel) {
                withAnimation {
                    cameraRegion = .region(updateCameraRegion())
                }
            }
        }
        .frame(width: 800, height: 600)
    }

    func updateCameraRegion() -> MKCoordinateRegion {
        let mapPoint = MKMapPoint(viewModel.coordinate)
        let mapRect = MKMapRect(x: mapPoint.x - 9_000, y: mapPoint.y - 9_000, width: 18_000, height: 18_000)
        var newRegion = MKCoordinateRegion(mapRect)
        newRegion.span.latitudeDelta *= 1.0
        newRegion.span.longitudeDelta *= 1.0
        return newRegion
    }
}

#Preview {
    ContentView()
}

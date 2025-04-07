import SwiftUI
import OSCAWaste
import CoreLocation

struct LocationNavigationView: View {
    var position: Position
    @State var isRouteDialogPresented = false
    
    var body: some View {
        Button(action: {
            isRouteDialogPresented = true
        }) {
            Image("ic_navigation", bundle: OSCAWasteUI.bundle)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding(15)
                .foregroundStyle(Color.white)
        }.cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("PrimaryColor", bundle: OSCAWasteUI.bundle))
            )
            .confirmationDialog("select_map_app", isPresented: $isRouteDialogPresented) {
                let coordinate2D = CLLocationCoordinate2D(
                    latitude: position.latitude,
                    longitude: position.longitude
                )
                Button(action: {openRouteTo(coordinate: coordinate2D, mapType: .AppleMaps)}) {
                    Text("apple_maps", bundle: OSCAWasteUI.bundle)
                    
                }
                Button(action: {openRouteTo(coordinate: coordinate2D, mapType: .GoogleMaps)}) {
                    Text("google_maps", bundle: OSCAWasteUI.bundle)
                }
            }.accentColor(Color(UIColor.systemBlue))
    }
}


enum MapType {
    case GoogleMaps, AppleMaps
}

func openRouteTo(coordinate: CLLocationCoordinate2D, mapType: MapType) {
    switch mapType {
    case .AppleMaps:
        if let url = URL(string: "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)&dirflg=w") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    case .GoogleMaps:
        if let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(coordinate.latitude),\(coordinate.longitude)&travelmode=walking") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

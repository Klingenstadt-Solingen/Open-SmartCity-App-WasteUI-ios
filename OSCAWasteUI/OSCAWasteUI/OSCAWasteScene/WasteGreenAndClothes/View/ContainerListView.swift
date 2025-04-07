import SwiftUI
import Foundation

struct ContainerListView: View {
    @StateObject var viewModel: OSCAWasteGreenAndClothesViewModel
    
    var body: some View {
        switch (viewModel.greenAndClothesLoadingState) {
        case .Loaded:
            ScrollViewReader { value in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.wasteLocations, id: \.self) { location in
                            let streetNumber = location.streetNumber.isEmpty ? "" : " \(location.streetNumber)"
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(alignment: .top, spacing: 9) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(verbatim: location.street)
                                            .font(.system(size: 28).bold())
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        let district = location.district.replacingOccurrences(
                                            of: "\n",
                                            with: " "
                                        )
                                        Text(verbatim: "\(location.street)\(streetNumber), \(location.zipCode) \(district)")
                                            .font(.system(size: 16))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .multilineTextAlignment(.leading)
                                    }.frame(maxWidth: .infinity)
                                    LocationNavigationView(
                                        position: location.position
                                    )
                                }
                                Text("waste_opening_hours_title", bundle: OSCAWasteUI.bundle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 22).bold())
                                    .multilineTextAlignment(.leading)
                                ForEach(location.openingHours, id: \.self) { openingHour in
                                    Text(verbatim: openingHour)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: 14))
                                        .multilineTextAlignment(.leading)
                                }
                            }.id(location.objectId)
                                .frame(maxWidth: .infinity).padding(15).background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color.white)
                                        .shadow(radius: 3)
                                )
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).padding(.vertical, 10).padding(.horizontal, 20)
                }.onChange(of: viewModel.scrollObjectId) { newValue in
                    if let newValue = newValue {
                        value.scrollTo(newValue, anchor: .top)
                    }
                }
            }
        case .Initializing:
            Text("waste_select_district", bundle: OSCAWasteUI.bundle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .Empty:
            Text("waste_green_mobile_waste_empty_list", bundle: OSCAWasteUI.bundle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .Loading:
            ZStack(alignment: .center) {
                ProgressView()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}



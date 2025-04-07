import OSCANetworkService
import OSCAWaste
import Foundation
import Combine

public final class OSCAWasteGreenAndClothesViewModel: ObservableObject {
    public enum GreenAndClothesLoadingState {
        case Initializing, Loading, Empty, Loaded
    }
    
  let wasteLocationType: WasteLocationType
  
  let dataCache = NSCache<NSString, NSData>()
  let dataModule: OSCAWaste
  private var bindings = Set<AnyCancellable>()
  

  public init(wasteLocationType: WasteLocationType, dataModule: OSCAWaste) {
    self.wasteLocationType = wasteLocationType
    self.dataModule = dataModule
      
    if(self.wasteLocationType == .Altkleidercontainer ) {
          self.screenTitle = NSLocalizedString(
            "waste_old_clothes_waste_title",
            bundle: self.bundle,
            comment: "The title for green cuttings waste")
      }
      else {
          self.screenTitle = NSLocalizedString(
            "waste_green_mobile_waste_title",
            bundle: self.bundle,
            comment: "The title for green cuttings waste")
      }
  }
  
  @Published var wasteLocations: [OSCAWasteGreenAndClothesLocation] = []
  @Published var wasteDistricts: [OSCAWasteGreenAndClothesDistrict] = []
  @Published var scrollObjectId: Int? = nil
    @Published var greenAndClothesLoadingState: GreenAndClothesLoadingState = .Initializing
  
  var bundle: Bundle = {
      return OSCAWasteUI.bundle
  }()
  

    var screenTitle: String = ""
  
  
    private func getWasteDistricts(callback: @escaping(_ districts: [OSCAWasteGreenAndClothesDistrict])->Void) {
        self.dataModule.fetchWasteGreenAndClothesDistrict(wasteLocationType: self.wasteLocationType )
      .sink { completion in
        switch completion {
        case .finished:
          print(".finished \(#function)")
          
        case .failure:
          print(completion)
          print(".failure \(#function)")
        }
        
      } receiveValue: { wasteDistricts in
        self.wasteDistricts = wasteDistricts
        callback(wasteDistricts)
      }
      .store(in: &self.bindings)
  }
  
    private func fetchAllWasteLocations(id: String) {
        greenAndClothesLoadingState = .Loading
        // ...
        let idEncodedNewlines = id.replacingOccurrences(of: "\n", with: "%0A")
        self.dataModule.fetchWasteGreenAndClothesLocation(id: idEncodedNewlines, wasteLocationType: self.wasteLocationType)
      .sink { completion in
        switch completion {
        case .finished:
          print(".finished getWasteLocations()")
          
        case .failure:
          print(".failure getWasteLocation()")
        }
        
      } receiveValue: { wasteLocations in
          self.wasteLocations.append(contentsOf: wasteLocations)
          self.greenAndClothesLoadingState = self.wasteLocations.isEmpty ? .Empty : .Loaded
      }
      .store(in: &bindings)
  }
    
    private func initFetchAllWaste() {
        greenAndClothesLoadingState = .Loading
        if let userDistricts: [String] = UserDefaults.standard.stringArray(
            forKey: OSCAWaste.greenWasteAppointmentDistrictsKey
        ), !userDistricts.isEmpty {
            let publishers = userDistricts.map(
                { district in
                    let idEncodedNewlines = district.replacingOccurrences(of: "\n", with: "%0A")
                    return self.dataModule
                        .fetchWasteGreenAndClothesLocation(
                            id: idEncodedNewlines,
                            wasteLocationType: .Grünschnittcontainer
                        )
                })
            Publishers.MergeMany(publishers).collect().sink { completion in
                switch completion {
                case .finished:
                    print(".finished getWasteLocations()")
                    
                case .failure:
                    print(".failure getWasteLocation()")
                }
                
            } receiveValue: { wasteLocationsArrays in
                for wasteLocations in wasteLocationsArrays {
                    self.wasteLocations.append(contentsOf: wasteLocations)
                }
                self.greenAndClothesLoadingState = self.wasteLocations.isEmpty ? .Empty : .Loaded
            }
            .store(in: &bindings)
        } else {
            self.greenAndClothesLoadingState = .Initializing
        }
    }
}

extension OSCAWasteGreenAndClothesViewModel {
    func viewDidLoad(callback:@escaping (_ districts: [OSCAWasteGreenAndClothesDistrict])->Void) {
        self.getWasteDistricts(callback: callback)
        if (self.wasteLocationType == .Grünschnittcontainer) {
            self.initFetchAllWaste()
        }
  }
  
  func didSelect(at title: String) {
      var id = self.wasteDistricts.first(where: { $0.name == title })?.objectId
      self.fetchAllWasteLocations(id: id!)
  }
    func didDeselect(at title: String) {
        self.wasteLocations.removeAll(where: { $0.district == title })
        if (self.wasteLocations.isEmpty) {
            self.greenAndClothesLoadingState = .Initializing
        }
    }
}

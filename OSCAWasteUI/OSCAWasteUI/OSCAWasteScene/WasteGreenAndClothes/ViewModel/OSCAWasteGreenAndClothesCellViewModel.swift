import OSCAWaste
import Foundation
import Combine

public final class OSCAWasteGreenAndClothesCellViewModel {
  
  let dataCache: NSCache<NSString, NSData>
  let dataModule: OSCAWaste
  let wasteGreenAndClothesLocation: OSCAWasteGreenAndClothesLocation
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste, dataCache: NSCache<NSString, NSData>, wasteGreenAndClothesLocation: OSCAWasteGreenAndClothesLocation) {
    self.dataModule = dataModule
    self.dataCache = dataCache
    self.wasteGreenAndClothesLocation = wasteGreenAndClothesLocation
  }
  
  private var bindings = Set<AnyCancellable>()

  public var adresstitle: String { ("Standort " + self.wasteGreenAndClothesLocation.street) ?? "" }
  public var adressLable: String { self.wasteGreenAndClothesLocation.street + " " + self.wasteGreenAndClothesLocation.streetNumber + " " + self.wasteGreenAndClothesLocation.zipCode + " " + self.wasteGreenAndClothesLocation.district ?? "" }
  public var openingHoursTitle: String { "Öffnungszeiten" }
  public var openingHoursLable: [String] { self.wasteGreenAndClothesLocation.openingHours ?? [""] }
}

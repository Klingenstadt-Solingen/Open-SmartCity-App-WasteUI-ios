//
//  OSCAWasteDescriptionViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 01.08.22.
//

import OSCAEssentials
import OSCAWaste
import Foundation
import CoreLocation
import class MapKit.MKMapItem
import class MapKit.MKPlacemark
import var MapKit.MKLaunchOptionsDirectionsModeKey
import var MapKit.MKLaunchOptionsDirectionsModeDriving
import struct MapKit.MKCoordinateRegion

public struct OSCAWasteDescriptionViewModelActions {
  let showContactOnWebsite: (URL) -> Void
}

public final class OSCAWasteDescriptionViewModel {
  
  private let actions: OSCAWasteDescriptionViewModelActions?
  let wasteInfo: OSCAWasteInfo?
  let wasteType: OSCAWasteType
  let wasteSubtype: OSCAWasteSubtype?
  let wasteSpecialSubtype: OSCAWasteLocation?
  let defaultLocation: OSCAGeoPoint?
  
  // MARK: Initializer
  public init(actions: OSCAWasteDescriptionViewModelActions,
              wasteInfo: OSCAWasteInfo?,
              wasteType: OSCAWasteType,
              wasteSuptype: OSCAWasteSubtype?,
              wasteSpecialSubtype: OSCAWasteLocation?,
              defaultLocation: OSCAGeoPoint? = nil) {
    self.actions = actions
    self.wasteInfo = wasteInfo
    self.wasteType = wasteType
    self.wasteSubtype = wasteSuptype
    self.wasteSpecialSubtype = wasteSpecialSubtype
    self.defaultLocation = defaultLocation
  }
  
  // MARK: - OUTPUT
  
  /**
   Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
   - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
   */
  var bundle: Bundle = {
    if let bundle = OSCAWasteUI.configuration.externalBundle {
      return bundle
    }
    else { return OSCAWasteUI.bundle }
  }()
  
  var screenTitle: String {
    switch wasteType {
    case .pickedUp:
      if let waste = wasteInfo {
        return waste.title ?? ""
      }
      
    case .special:
      if let name = wasteSpecialSubtype?.name {
        return name
      }
    }
    return ""
  }
  
  var description: String {
    switch wasteType {
    case .pickedUp:
      if let waste = wasteInfo {
        return waste.description ?? ""
      }
      
    case .special:
      if let description = wasteSpecialSubtype?.description {
        return description
      }
    }
    return ""
  }
  
  var mondayHours: String {
    let weekday = "\(OSCAWeekday.monday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.monday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var tuesdayHours: String {
    let weekday = "\(OSCAWeekday.tuesday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.tuesday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var wednesdayHours: String {
    let weekday = "\(OSCAWeekday.wednesday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.wednesday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var thursdayHours: String {
    let weekday = "\(OSCAWeekday.thursday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.thursday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var fridayHours: String {
    let weekday = "\(OSCAWeekday.friday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.friday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var saturdayHours: String {
    let weekday = "\(OSCAWeekday.saturday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.saturday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var sundayHours: String {
    let weekday = "\(OSCAWeekday.sunday.weekdaySymbol()): "
    guard let hours = wasteSpecialSubtype?.openingHours?.sunday?.first
    else { return "\(weekday) ---" }
    return "\(weekday) \(hours)"
  }
  
  var email: String {
    guard let email = wasteSpecialSubtype?.email else { return "\(emailTitle): ---" }
    return "\(emailTitle): \(email)"
  }
  var emailUrl: String { wasteSpecialSubtype?.email ?? "" }
  var emailUrlRange: NSRange { (email as NSString).range(of: emailUrl) }
  
  var telephone: String {
    guard let telephone = wasteSpecialSubtype?.telephone else { return "\(telephoneTitle): ---" }
    return "\(telephoneTitle): \(telephone)"
  }
  var telephoneUrl: String { wasteSpecialSubtype?.telephone ?? "" }
  var telephoneUrlRange: NSRange { (telephone as NSString).range(of: telephoneUrl) }
  
  var phoneUrl: URL? {
    guard let phone = self.telephoneUrl.convertToPhoneNumber(),
          let url = URL(string: "tel://\(phone)")
    else { return nil }
    return url
  }
  
  var website: String {
    guard let website = wasteSpecialSubtype?.url else { return "\(websiteTitle): ---" }
    return "\(websiteTitle): \(website)"
  }
  var websiteUrl: String { wasteSpecialSubtype?.url ?? "" }
  var websiteUrlRange: NSRange { (website as NSString).range(of: websiteUrl) }
  
  var address: String {
    guard let address = wasteSpecialSubtype?.location?.address else { return "" }
    var firstLine = ""
    var secondLine = ""
    if let streetAddress = address.streetAddress {
      firstLine = "\(streetAddress)\n"
    }
    if let postalCode = address.postalCode, let addressLocality = address.addressLocality {
      secondLine = "\(postalCode), \(addressLocality)"
    }
    return "\(firstLine)\(secondLine)"
  }
  
  var coordinate: CLLocationCoordinate2D?	 {
    let defaultGeopoint: CLLocationCoordinate2D? = self.defaultLocation?.clLocationCoordinate2D
    guard let lat = wasteSpecialSubtype?.location?.geopoint?.latitude,
          let lon = wasteSpecialSubtype?.location?.geopoint?.longitude
    else { return defaultGeopoint }
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
  
  var region: MKCoordinateRegion? {
    if let coordinate = self.coordinate {
      return MKCoordinateRegion(center: coordinate,
                                latitudinalMeters: 500,
                                longitudinalMeters: 500)
    } else {
      return nil
    }
  }
  
  var annotation: OSCAMapAnnotation? {
    if let coordinate = self.coordinate {
      let annotation = OSCAMapAnnotation()
      annotation.coordinate = coordinate
      return annotation
    } else {
      return nil
    }
  }
  
  // MARK: Localized Strings
  
  var openingHoursTitle: String { NSLocalizedString(
    "waste_opening_hours_title",
    bundle: self.bundle,
    comment: "The title for opening hours") }
  var contactTitle: String { NSLocalizedString(
    "waste_contact_title",
    bundle: self.bundle,
    comment: "The title for contact") }
  var emailTitle: String { NSLocalizedString(
    "waste_email_title",
    bundle: self.bundle,
    comment: "The title for contact email") }
  var telephoneTitle: String { NSLocalizedString(
    "waste_telephone_title",
    bundle: self.bundle,
    comment: "The title for contact telephone") }
  var websiteTitle: String { NSLocalizedString(
    "waste_website_title",
    bundle: self.bundle,
    comment: "The title for contact website") }
  var locationTitle: String { NSLocalizedString(
    "waste_location_title",
    bundle: self.bundle,
    comment: "The title for location") }
  var routeTitle: String { NSLocalizedString(
    "waste_route_title",
    bundle: self.bundle,
    comment: "The title for route") }
}

// MARK: - Input, view event methods
extension OSCAWasteDescriptionViewModel {
  func viewDidLoad() {}
  
  func websiteLabelTouch() {
    guard let url = URL(string: websiteUrl) else { return }
    actions?.showContactOnWebsite(url)
  }
  
  func routeButtonTouch() {
    guard let coordinate = self.coordinate else { return }
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = wasteSpecialSubtype?.name ?? address
    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
  }
}

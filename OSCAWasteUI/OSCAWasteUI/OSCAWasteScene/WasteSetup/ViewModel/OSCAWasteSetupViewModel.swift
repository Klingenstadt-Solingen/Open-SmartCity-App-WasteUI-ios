//
//  OSCAWasteSetupViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 08.07.22.
//

import OSCAEssentials
import OSCAWaste
import Foundation
import Combine

public struct OSCAWasteSetupViewModelActions {
  let showWaste: ((Bool, OSCAWasteAddress, Bool) -> Void)?
  let closeWasteSetup: () -> Void
}

public enum OSCAWasteSetupViewModelError: Error, Equatable {
  case wasteAddressFetch
  case wasteAddressSave
}

public enum OSCAWasteSetupViewModelState: Equatable {
  case loading
  case finishedLoading
  case selectedWasteAddress
  case deselectedWasteAddress
  case error(OSCAWasteSetupViewModelError)
}

public final class OSCAWasteSetupViewModel {
  
  private let dataModule: OSCAWaste
  private let actions: OSCAWasteSetupViewModelActions?
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste,
              actions: OSCAWasteSetupViewModelActions) {
    self.dataModule = dataModule
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  enum Section { case wasteAddress }
  
  @Published private(set) var state: OSCAWasteSetupViewModelState = .loading
  @Published var searchedWasteAddress: [OSCAWasteAddress] = []
  
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
  
  var selectedWasteAddress: OSCAWasteAddress?
  var alertMessageError: String { OSCAObjectSavableError.unableToEncode.localizedDescription }
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "waste_setup_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
  var alertTitleError: String { NSLocalizedString(
    "waste_alert_title_error",
    bundle: self.bundle,
    comment: "The alert title for an error") }
  var alertActionConfirm: String { NSLocalizedString(
    "waste_alert_title_confirm",
    bundle: self.bundle,
    comment: "The alert action title to confirm") }
  var addressSetupDescription: String { NSLocalizedString(
    "waste_address_setup_description",
    bundle: self.bundle,
    comment: "The description for setting up the user waste address") }
  var searchPlaceholder: String { NSLocalizedString(
    "waste_search_placeholder",
    bundle: self.bundle,
    comment: "Placeholder for searchbar") }
  
  // MARK: - Private
  
  private func getWasteAddress(for searchText: String) {
    self.dataModule.elasticSearch(for: searchText, isRaw: false)
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.wasteAddressFetch)
        }
      } receiveValue: { wasteAddress in
        self.searchedWasteAddress = wasteAddress
        
        self.state = .deselectedWasteAddress
      }
      .store(in: &bindings)
  }
  
  private func saveWasteAddress() {
    guard let address = selectedWasteAddress else { return }
    
    do {
      try self.dataModule.userDefaults.setOSCAWasteAddress(address)
      OSCAWasteUI.configuration.userAddress = address
      
      if let showWaste = self.actions?.showWaste {
        showWaste(true, address, true)
      }
      else { self.actions?.closeWasteSetup() }
    }
    catch {
      state = .error(.wasteAddressSave) }
  }
}

// MARK: - Input, view event methods
extension OSCAWasteSetupViewModel {
  func viewDidLoad() {
    state = .deselectedWasteAddress
  }
  
  func updateSearchResults(for searchText: String) {
    if !searchText.isEmpty {
      getWasteAddress(for: searchText)
    }
  }
  
  func didSelectItem(at index: Int) {
    selectedWasteAddress = searchedWasteAddress[index]
    state = .selectedWasteAddress
  }
  
  func saveBarButtonItemTouch() {
    saveWasteAddress()
  }
}

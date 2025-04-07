//
//  OSCAWasteFlowCoordinator.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 23.06.22.
//  Reviewed by Stephan Breidenbach on 09.09.2022
//

import OSCAEssentials
import OSCAWaste
import Foundation
import OSCASafariView

public protocol OSCAWasteFlowCoordinatorDependencies {
  var deeplinkScheme: String { get }
  var defaultLocation: OSCAGeoPoint? { get }
  func makeOSCAWasteSetupViewController(actions: OSCAWasteSetupViewModelActions) -> OSCAWasteSetupViewController
  func makeOSCAWasteViewController(actions: OSCAWasteViewModelActions,
                                   userAddress: OSCAWasteAddress) -> OSCAWasteViewController
  func makeOSCAWasteAppointmentViewController(wasteCollectsAtAddress: OSCAWasteCollectsAtAddress,
                                              binTypes: [Int]) -> OSCAWasteAppointmentViewController
  func makeOSCAWasteInfoViewController(actions: OSCAWasteInfoViewModelActions,
                                       wasteType: OSCAWasteType) -> OSCAWasteInfoViewController
    
  func makeOSCAWasteGreenAndClothesViewController(wasteLocationType: WasteLocationType) -> OSCAWasteGreenAndClothesViewController
    
  func makeOSCAWasteDescriptionViewController(actions: OSCAWasteDescriptionViewModelActions,
                                              wasteInfo: OSCAWasteInfo?,
                                              wasteType: OSCAWasteType,
                                              wasteSubtype: OSCAWasteSubtype?,
                                              wasteSpecialSubtype: OSCAWasteLocation?,
                                              defaultLocation: OSCAGeoPoint?) -> OSCAWasteDescriptionViewController
  func makeSafariViewFlowCoordinator(router: Router, url: URL) -> OSCASafariViewFlowCoordinator
}

public final class OSCAWasteFlowCoordinator: Coordinator {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  
  /**
   router injected via initializer: `router` will be used to push and pop view controllers
   */
  public let router: Router
  
  /**
   dependencies injected via initializer DI conforming to the `OSCAWasteFlowCoordinatorDependencies` protocol
   */
  let dependencies: OSCAWasteFlowCoordinatorDependencies
  
  /**
   waste view controller `OSCAWasteSetupViewController`
   */
  private weak var wasteSetupVC: OSCAWasteSetupViewController?
  /**
   waste view controller `OSCAWasteViewController`
   */
  private weak var wasteVC: OSCAWasteViewController?
  /**
   web view flow coordinator`Coordinator`
   */
  private weak var webViewFlow: Coordinator?
  
  public init(router: Router,
              dependencies: OSCAWasteFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }
  
  // MARK: - Waste Description Actions
  
  private func showContactOnWebsite(url: URL) {
    if let webViewFlow = self.webViewFlow {
      removeChild(webViewFlow)
      self.webViewFlow = nil
    }
    let flow = dependencies.makeSafariViewFlowCoordinator(router: router, url: url)
    presentChild(flow, animated: true) {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
    }
    self.webViewFlow = flow
  }
  
  // MARK: - Waste Info Actions
  
  private func showWasteDescription(wasteType: OSCAWasteType,
                                    wasteInfo: OSCAWasteInfo?,
                                    wasteSubtype: OSCAWasteSubtype?,
                                    wasteSpecialSubtype: OSCAWasteLocation?) {
    let actions = OSCAWasteDescriptionViewModelActions(
      showContactOnWebsite: self.showContactOnWebsite)
    let defaultLocation = dependencies.defaultLocation
    let vc = self.dependencies.makeOSCAWasteDescriptionViewController(
      actions: actions,
      wasteInfo: wasteInfo,
      wasteType: wasteType,
      wasteSubtype: wasteSubtype,
      wasteSpecialSubtype: wasteSpecialSubtype,
      defaultLocation: defaultLocation)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
  }
  
  // MARK: - Waste Actions
  
  private func showWasteAppointment(wasteCollectsAtAddress: OSCAWasteCollectsAtAddress, binTypes: [Int]) {
    let vc = self.dependencies.makeOSCAWasteAppointmentViewController(wasteCollectsAtAddress: wasteCollectsAtAddress, binTypes: binTypes)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
  }
  
  private func showWasteInfo(wasteType: OSCAWasteType) {
    let actions = OSCAWasteInfoViewModelActions(showWasteDescription: self.showWasteDescription)
    let vc = self.dependencies.makeOSCAWasteInfoViewController(actions: actions, wasteType: wasteType)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
  }
    
    private func showWasteGreenAndClothes(wasteLocationType: WasteLocationType) {
    let vc = self.dependencies.makeOSCAWasteGreenAndClothesViewController(wasteLocationType: wasteLocationType)
    self.router.present(vc,
                          animated: true,
                          onDismissed: nil)
  }
  
  // MARK: Waste Setup Actions
  
  private func showWaste(isNavigatingFromWasteSetup: Bool = false, userAddress: OSCAWasteAddress, animated: Bool) {
    let actions = OSCAWasteViewModelActions(
      showWasteAppointment: self.showWasteAppointment,
      showWasteInfo: self.showWasteInfo,
      showWasteGreenAndClothes: self.showWasteGreenAndClothes
    )
    
    let vc = self.dependencies.makeOSCAWasteViewController(actions: actions, userAddress: userAddress)
    
    if isNavigatingFromWasteSetup {
      self.router.navigateBack(animated: false)
      self.router.present(vc,
                          animated: false,
                          onDismissed: nil)
      
      
    } else {
      self.router.present(vc,
                          animated: animated,
                          onDismissed: nil)
    }
    
    self.wasteVC = vc
  }
  
  private func closeWasteSetup() {
    self.router.navigateBack(animated: true)
  }
  
  func showWasteMain(animated: Bool,
                     onDismissed: (() -> Void)?) -> Void {
    if let userAddress = OSCAWasteUI.configuration.userAddress {
      showWaste(userAddress: userAddress, animated: animated)
    } else {
      let actions = OSCAWasteSetupViewModelActions(
        showWaste: self.showWaste,
        closeWasteSetup: self.closeWasteSetup)
      let vc = self.dependencies.makeOSCAWasteSetupViewController(actions: actions)
      self.router.present(vc,
                          animated: animated,
                          onDismissed: onDismissed)
      self.wasteSetupVC = vc
    }// end if
  }// end func showWasteMain
  
  public func present(animated: Bool,
                      onDismissed: (() -> Void)?) {
    showWasteMain(animated: animated,
                  onDismissed: onDismissed)
  }// end func present
}

extension OSCAWasteFlowCoordinator {
  /**
   add `child` `Coordinator`to `children` list of `Coordinator`s and present `child` `Coordinator`
   */
  public func presentChild(_ child: Coordinator,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) {
    self.children.append(child)
    child.present(animated: animated) { [weak self, weak child] in
      guard let self = self, let child = child else { return }
      self.removeChild(child)
      onDismissed?()
    }
  }
  
  private func removeChild(_ child: Coordinator) {
    /// `children` includes `child`!!
    guard let index = children.firstIndex(where: { $0 === child }) else { return }
    children.remove(at: index)
  }
}

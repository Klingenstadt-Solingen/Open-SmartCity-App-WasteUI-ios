//
//  OSCAWasteSetupFlowCoordinator.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 19.07.22.
//

import OSCAEssentials
import OSCAWaste
import UIKit

public protocol OSCAWasteSetupFlowCoordinatorDependencies {
  var deeplinkScheme: String { get }
  func makeOSCAWasteSetupViewController(actions: OSCAWasteSetupViewModelActions) -> OSCAWasteSetupViewController
}

public final class OSCAWasteSetupFlowCoordinator: Coordinator {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  
  /**
   router injected via initializer: `router` will be used to push and pop view controllers
   */
  public let router: Router
  
  /**
   dependencies injected via initializer DI conforming to the `OSCAWasteSetupFlowCoordinatorDependencies` protocol
   */
  private let dependencies: OSCAWasteSetupFlowCoordinatorDependencies
  
  /**
   waste view controller `OSCAWasteSetupViewController`
   */
  private weak var wasteSetupVC: OSCAWasteSetupViewController?
  
  public init(router: Router, dependencies: OSCAWasteSetupFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }
  
  // MARK: Waste Setup Actions
  
  private func closeWasteSetup() {
    self.router.navigateBack(animated: true)
  }
  
  public func present(animated: Bool, onDismissed: (() -> Void)?) {
    let actions = OSCAWasteSetupViewModelActions(
      showWaste: nil,
      closeWasteSetup: self.closeWasteSetup)
    let vc = self.dependencies.makeOSCAWasteSetupViewController(actions: actions)
    let nav = UINavigationController(rootViewController: vc)
    self.router.presentModalViewController(nav,
                                           animated: animated,
                                           onDismissed: onDismissed)
    self.wasteSetupVC = vc
  }
}

//
//  OSCAWasteWidgetFlowCoordinator.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 21.03.23.
//

import OSCAEssentials
import Foundation

public protocol OSCAWasteWidgetFlowCoordinatorDependencies {
  func makeOSCAWasteAppointmentViewControllerWidget(actions: OSCAWasteAppointmentViewModelWidget.Actions) -> OSCAWasteAppointmentViewControllerWidget
}

public final class OSCAWasteWidgetFlowCoordinator: Coordinator {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  
  /**
   router injected via initializer: `router` will be used to push and pop view controllers
   */
  public let router: Router
  
  /**
   dependencies injected via initializer DI conforming to the `OSCAWasteWidgetFlowCoordinatorDependencies` protocol
   */
  let dependencies: OSCAWasteWidgetFlowCoordinatorDependencies
  
  /**
   waste view controller `OSCAWasteAppointmentViewControllerWidget`
   */
  public weak var wasteWidgetVC: OSCAWasteAppointmentViewControllerWidget?
  
  public init(router: Router, dependencies: OSCAWasteWidgetFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }
  
  func showWasteWidget(animated: Bool, onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let actions = OSCAWasteAppointmentViewModelWidget.Actions()
    let vc = self.dependencies
      .makeOSCAWasteAppointmentViewControllerWidget(actions: actions)
//    self.router.present(vc,
//                        animated: animated,
//                        onDismissed: onDismissed)
    self.wasteWidgetVC = vc
  }
  
  public func present(animated: Bool, onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.showWasteWidget(animated: animated,
                         onDismissed: onDismissed)
  }
}

extension OSCAWasteWidgetFlowCoordinator {
  /**
   add `child` `Coordinator`to `children` list of `Coordinator`s and present `child` `Coordinator`
   */
  public func presentChild(_ child: Coordinator, animated: Bool, onDismissed: (() -> Void)? = nil) {
    self.children.append(child)
    child.present(animated: animated) { [weak self, weak child] in
      guard let self = self, let child = child else { return }
      self.removeChild(child)
      onDismissed?()
    }
  }
  
  private func removeChild(_ child: Coordinator) {
    /// `children` includes `child`!!
    guard let index = self.children.firstIndex(where: { $0 === child }) else { return }
    self.children.remove(at: index)
  }
}

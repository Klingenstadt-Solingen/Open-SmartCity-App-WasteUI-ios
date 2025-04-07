//
//  WasteFlow+OSCADeeplinkHandeble.swift
//  OSCAWasteUI
//
//  Created by Stephan Breidenbach on 08.09.22.
//

import Foundation
import OSCAEssentials

extension OSCAWasteFlowCoordinator: OSCADeeplinkHandeble {
  ///```console
  ///xcrun simctl openurl booted \
  /// "solingen://waste/"
  /// ```
  public func canOpenURL(_ url: URL) -> Bool {
    let deeplinkScheme: String = dependencies
      .deeplinkScheme
    return url.absoluteString.hasPrefix("\(deeplinkScheme)://waste")
  }// end public func canOpenURL
  
  public func openURL(_ url: URL,
                      onDismissed: (() -> Void)?) throws -> Void {
    guard canOpenURL(url)
    else { return }
      showWasteMain(animated: true,
                    onDismissed: onDismissed)
  }// end public func openURL
}// end extension final class OSCAWasteFlowCoordinator

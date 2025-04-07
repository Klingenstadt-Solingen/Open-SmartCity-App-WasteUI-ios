//
//  OSCAWasteDescriptionViewController.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 01.08.22.
//

import OSCAEssentials
import UIKit
import MapKit

public final class OSCAWasteDescriptionViewController: UIViewController {
  
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var mainStack: UIStackView!
  @IBOutlet private var descriptionContainer: UIView!
  @IBOutlet private var descriptionTextView: UITextView!
  @IBOutlet private var openingHoursContainer: UIView!
  @IBOutlet private var openingHoursTitleLabel: UILabel!
  @IBOutlet private var openingHoursView: UIView!
  @IBOutlet private var mondalLabel: UILabel!
  @IBOutlet private var tuesdayLabel: UILabel!
  @IBOutlet private var wednesdayLabel: UILabel!
  @IBOutlet private var thursdayLabel: UILabel!
  @IBOutlet private var fridayLabel: UILabel!
  @IBOutlet private var saturdayLabel: UILabel!
  @IBOutlet private var sundayLabel: UILabel!
  @IBOutlet private var contactContainer: UIView!
  @IBOutlet private var contactTitleLabel: UILabel!
  @IBOutlet private var contactView: UIView!
  @IBOutlet private var emailLabel: UILabel!
  @IBOutlet private var telephoneLabel: UILabel!
  @IBOutlet private var websiteLabel: UILabel!
  @IBOutlet private var locationContainer: UIView!
  @IBOutlet private var locationTitleLabel: UILabel!
  @IBOutlet private var locationView: UIView!
  @IBOutlet private var addressLabel: UILabel!
  @IBOutlet private var mapView: MKMapView!
  @IBOutlet private var routeButton: UIButton!
  
  private var viewModel: OSCAWasteDescriptionViewModel!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupBindings()
    viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.view.backgroundColor = OSCAWasteUI.configuration.colorConfig.backgroundColor
    
    self.navigationItem.title = viewModel.screenTitle
    
    scrollView.alwaysBounceVertical = true
    scrollView.backgroundColor = .clear
    
    mainStack.axis = .vertical
    mainStack.alignment = .fill
    mainStack.distribution = .equalSpacing
    mainStack.spacing = 16
    
    for view in mainStack.arrangedSubviews {
      switch view {
      case descriptionContainer: view.isHidden = false
        
      case contactContainer:
        view.isHidden = self.viewModel.wasteType == .special
          ? false
          : true
        
      case openingHoursContainer, locationContainer:
        if viewModel.wasteType == .special {
          if let wasteSubtype = viewModel.wasteSpecialSubtype?.wasteType {
            switch wasteSubtype {
            case .wasteToEnergy, .disposalYard:
              view.isHidden = false
              
            default: view.isHidden = true
            }
          }
        }
        else { view.isHidden = true }
        
      default: view.isHidden = true
      }
    }
    
    descriptionContainer.backgroundColor = .clear
    
    let size = OSCAWasteUI.configuration
      .fontConfig.bodyLight.pointSize
    let fontSize = "\(size)"
    let css = "<style> body {font-stretch: normal; font-size: \(fontSize)px; line-height: normal; font-family: 'Helvetica Neue'} </style>"
    let htmlString = "\(css)\(self.viewModel.description)"
    
    self.descriptionTextView.attributedText = try? NSMutableAttributedString(
      HTMLString: htmlString,
      color: OSCAWasteUI.configuration.colorConfig.textColor)
    self.descriptionTextView.linkTextAttributes = [
      .foregroundColor: OSCAWasteUI.configuration.colorConfig.primaryColor]
    self.descriptionTextView.backgroundColor = .clear
    self.descriptionTextView.sizeToFit()
    self.descriptionTextView.isScrollEnabled = false
    self.descriptionTextView.isEditable = false
    self.descriptionTextView.dataDetectorTypes = [
      .address,
      .link,
      .phoneNumber]
    
    openingHoursContainer.backgroundColor = .clear
    
    openingHoursTitleLabel.text = viewModel.openingHoursTitle
    openingHoursTitleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    openingHoursTitleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    openingHoursView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    openingHoursView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    openingHoursView.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    mondalLabel.text = viewModel.mondayHours
    mondalLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    mondalLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    tuesdayLabel.text = viewModel.tuesdayHours
    tuesdayLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    tuesdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    wednesdayLabel.text = viewModel.wednesdayHours
    wednesdayLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    wednesdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    thursdayLabel.text = viewModel.thursdayHours
    thursdayLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    thursdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    fridayLabel.text = viewModel.fridayHours
    fridayLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    fridayLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    saturdayLabel.text = viewModel.saturdayHours
    saturdayLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    saturdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    sundayLabel.text = viewModel.sundayHours
    sundayLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    sundayLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    contactContainer.backgroundColor = .clear
    
    contactTitleLabel.text = viewModel.contactTitle
    contactTitleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    contactTitleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    contactView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    contactView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    contactView.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    emailLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    emailLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    emailLabel.setTextWithLinks(
      text: viewModel.email,
      links: [viewModel.emailUrl],
      color: OSCAWasteUI.configuration.colorConfig.primaryColor)
    emailLabel.isUserInteractionEnabled = true
    
    telephoneLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    telephoneLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    telephoneLabel.setTextWithLinks(
      text: viewModel.telephone,
      links: [viewModel.telephoneUrl],
      color: OSCAWasteUI.configuration.colorConfig.primaryColor)
    telephoneLabel.isUserInteractionEnabled = true
    
    websiteLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    websiteLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    websiteLabel.setTextWithLinks(
      text: viewModel.website,
      links: [viewModel.websiteUrl],
      color: OSCAWasteUI.configuration.colorConfig.primaryColor)
    websiteLabel.isUserInteractionEnabled = true
    
    locationContainer.backgroundColor = .clear
    
    locationTitleLabel.text = viewModel.locationTitle
    locationTitleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    locationTitleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    locationView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    locationView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    locationView.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    addressLabel.text = viewModel.address
    addressLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    addressLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    addressLabel.numberOfLines = 2
    
    if let region = viewModel.region,
       let annotation = viewModel.annotation {
      mapView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
      mapView.showsUserLocation = true
      mapView.setRegion(region, animated: true)
      mapView.addAnnotation(annotation)
    } else {
      mapView.isHidden = true
    }
    
    if viewModel.coordinate == nil {
      routeButton.isEnabled = false
      routeButton.isHidden = true
    } else {
      routeButton.isEnabled = true
      routeButton.isHidden = false
      routeButton.setTitle(viewModel.routeTitle, for: .normal)
      routeButton.titleLabel?.font = OSCAWasteUI.configuration.fontConfig.subheaderLight
      let buttonTitleColor = OSCAWasteUI.configuration.colorConfig.primaryColor.isDarkColor
      ? OSCAWasteUI.configuration.colorConfig.whiteDark
      : OSCAWasteUI.configuration.colorConfig.blackColor
      routeButton.setTitleColor(
        buttonTitleColor,
        for: .normal)
      routeButton.backgroundColor = OSCAWasteUI.configuration.colorConfig.primaryColor
      routeButton.addLimitedCornerRadius(OSCAWasteUI.configuration.cornerRadius)
    }
  }
  
  private func setupBindings() {}
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAWasteUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAWasteUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAWasteUI.configuration.colorConfig.navigationBarColor)
  }
  
  @IBAction func emailLabelTouch(_ gesture: UITapGestureRecognizer) {
    if gesture.didTapAttributedTextInLabel(
      label: emailLabel,
      inRange: viewModel.emailUrlRange) {
      guard let url = URL(string: "mailto:\(viewModel.emailUrl)"),
            UIApplication.shared.canOpenURL(url)
      else { return }
      UIApplication.shared.open(url)
    }
  }
  
  @IBAction func telephoneLabelTouch(_ gesture: UITapGestureRecognizer) {
    if gesture.didTapAttributedTextInLabel(
      label: telephoneLabel,
      inRange: viewModel.telephoneUrlRange) {
      guard let url = self.viewModel.phoneUrl,
            UIApplication.shared.canOpenURL(url)
      else { return }
      UIApplication.shared.open(url)
    }
  }
  
  @IBAction func websiteLabelTouch(_ gesture: UITapGestureRecognizer) {
    if gesture.didTapAttributedTextInLabel(
      label: websiteLabel,
      inRange: viewModel.websiteUrlRange) {
      viewModel.websiteLabelTouch()
    }
  }
  
  @IBAction func routeButtonTouch(_ sender: UIButton) {
    viewModel.routeButtonTouch()
  }
}

// MARK: - instantiate view conroller
extension OSCAWasteDescriptionViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAWasteDescriptionViewModel) -> OSCAWasteDescriptionViewController {
    let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

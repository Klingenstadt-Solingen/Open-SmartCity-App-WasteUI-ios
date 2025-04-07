//
//  OSCAWasteViewController.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 23.06.22.
//

import OSCAEssentials
import OSCAWaste
import UIKit
import Combine
import SwiftUI

@_implementationOnly
import SwiftDate

public final class OSCAWasteViewController: UIViewController {
  
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var mainStack: UIStackView!
  @IBOutlet private var calendarView: UIView!
  @IBOutlet private var calendarStack: UIStackView!
  @IBOutlet private var dateLabel: UILabel!
  @IBOutlet private var addressLabel: UILabel!
  @IBOutlet private var weekdayStack: UIStackView!
  @IBOutlet private var previousWeekButton: UIButton!
  @IBOutlet private var nextWeekButton: UIButton!
  @IBOutlet private var mondayView: UIView!
  @IBOutlet private var mondayLabel: UILabel!
  @IBOutlet private var tuesdayView: UIView!
  @IBOutlet private var tuesdayLabel: UILabel!
  @IBOutlet private var wednesdayView: UIView!
  @IBOutlet private var wednesdayLabel: UILabel!
  @IBOutlet private var thursdayView: UIView!
  @IBOutlet private var thursdayLabel: UILabel!
  @IBOutlet private var fridayView: UIView!
  @IBOutlet private var fridayLabel: UILabel!
  @IBOutlet private var saturdayView: UIView!
  @IBOutlet private var saturdayLabel: UILabel!
  @IBOutlet private var sundayView: UIView!
  @IBOutlet private var sundayLabel: UILabel!
  @IBOutlet private var reminderView: UIView!
  @IBOutlet private var reminderStack: UIStackView!
  @IBOutlet private var reminderLabel: UILabel!
  @IBOutlet private var reminderSwitch: UISwitch!
  @IBOutlet private var appointmentView: UIView!
  @IBOutlet private var appointmentStack: UIStackView!
  @IBOutlet private var appointmentTitleStack: UIStackView!
  @IBOutlet private var appointmentTitleLabel: UILabel!
  @IBOutlet private var allAppointmentButton: UIButton!
  @IBOutlet private var appointmentCollectionView: UICollectionView!
  @IBOutlet private var infoView: UIView!
  @IBOutlet private var infoStack: UIStackView!
  @IBOutlet private var infoLabel: UILabel!
  @IBOutlet private var wasteTypeStack: UIStackView!
  @IBOutlet private var wasteTypeStack2: UIStackView!
  @IBOutlet private var greenMobileWasteView: UIView!
  @IBOutlet private var greenMobileWasteImageView: UIImageView!
  @IBOutlet private var greenMobileWasteLabel: UILabel!
  @IBOutlet private var greenMobileWasteButton: UIButton!
  @IBOutlet private var oldClothesWasteView: UIView!
  @IBOutlet private var oldClothesWasteImageView: UIImageView!
  @IBOutlet private var oldClothesWasteLabel: UILabel!
  @IBOutlet private var oldClothesWasteButton: UIButton!
  @IBOutlet private var pickedUpWasteView: UIView!
  @IBOutlet private var pickedUpWasteImageView: UIImageView!
  @IBOutlet private var pickedUpWasteLabel: UILabel!
  @IBOutlet private var pickedUpWasteButton: UIButton!
  @IBOutlet private var specialWasteView: UIView!
  @IBOutlet private var specialWasteImageView: UIImageView!
  @IBOutlet private var specialWasteLabel: UILabel!
  @IBOutlet private var specialWasteButton: UIButton!
  @IBOutlet private var additionalSpaceTextView: UITextView!
  @IBOutlet private var button: UIButton!
  @IBOutlet private var subscribeCalendarButton: UIButton!
  
  @IBOutlet private var appointmentCollectionViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var emptyListLabel: UILabel!

    @IBOutlet var greenWasteDistrictAppointmentsButton: UIButton!
  
  private var viewModel: OSCAWasteViewModel!
  private var bindings = Set<AnyCancellable>()
  
  private var bottomSheetVC: BottomSheetViewController!
  
  var dataSource: UICollectionViewDiffableDataSource<OSCAWasteViewModel.Section, OSCAWasteCollect>!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupBindings()
    self.viewModel.viewDidLoad(callback: self.createDistrictsButtonMenu)
  }
  
  private func setupViews() {
    bottomSheetVC = BottomSheetViewController()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.toogleReminder),
      name: .wasteReminderDidChange,
      object: nil)
    
    self.navigationItem.title = self.viewModel.screenTitle
    
    view.backgroundColor = OSCAWasteUI.configuration.colorConfig.backgroundColor
    
    scrollView.alwaysBounceVertical = true
    
    mainStack.axis = .vertical
    mainStack.alignment = .fill
    mainStack.distribution = .equalSpacing
    mainStack.spacing = 32
    
    calendarView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    calendarView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    calendarView.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    calendarStack.axis = .vertical
    calendarStack.alignment = .fill
    calendarStack.distribution = .fill
    calendarStack.spacing = 8
    calendarStack.setCustomSpacing(16, after: addressLabel)
    
    dateLabel.text = viewModel.dateOfToday
    dateLabel.font = OSCAWasteUI.configuration.fontConfig.subheaderHeavy
    dateLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    addressLabel.text = viewModel.wasteUserFullStreetAddress
    addressLabel.font = OSCAWasteUI.configuration.fontConfig.subheaderLight
    addressLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    addressLabel.numberOfLines = 2
    
    weekdayStack.axis = .horizontal
    weekdayStack.alignment = .top
    weekdayStack.distribution = .equalSpacing
    weekdayStack.spacing = 0
    
    let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
    let previousImage = UIImage(
      systemName: "chevron.left",
      withConfiguration: symbolConfig)
    self.previousWeekButton.setImage(previousImage,
                                     for: .normal)
    self.previousWeekButton.tintColor = OSCAWasteUI.configuration
      .colorConfig.primaryColor
    
    let nextImage = UIImage(
      systemName: "chevron.right",
      withConfiguration: symbolConfig)
    self.nextWeekButton.setImage(nextImage,
                                 for: .normal)
    self.nextWeekButton.tintColor = OSCAWasteUI.configuration
      .colorConfig.primaryColor
    
    mondayView.backgroundColor = .clear
    mondayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    mondayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    tuesdayView.backgroundColor = .clear
    tuesdayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    tuesdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    wednesdayView.backgroundColor = .clear
    wednesdayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    wednesdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    thursdayView.backgroundColor = .clear
    thursdayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    thursdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    fridayView.backgroundColor = .clear
    fridayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    fridayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    saturdayView.backgroundColor = .clear
    saturdayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    saturdayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    sundayView.backgroundColor = .clear
    sundayLabel.font = OSCAWasteUI.configuration.fontConfig.captionLight
    sundayLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    
    for i in 0...6 {
      setupWeek(for: i)
    }
    
    reminderView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    reminderView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    reminderView.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    reminderStack.axis = .horizontal
    reminderStack.alignment = .center
    reminderStack.distribution = .fill
    reminderStack.spacing = 8
    
    reminderLabel.text = viewModel.reminderTitle
    reminderLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    reminderLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    
    self.reminderSwitch.isOn = self.viewModel.dataModule
      .userDefaults.getOSCAWasteReminder()
    reminderSwitch.onTintColor = OSCAWasteUI.configuration.colorConfig.primaryColor
    
    appointmentView.backgroundColor = .clear
    
    appointmentStack.axis = .vertical
    appointmentStack.alignment = .fill
    appointmentStack.distribution = .fill
    appointmentStack.spacing = 0
    
    appointmentTitleStack.axis = .horizontal
    appointmentTitleStack.alignment = .fill
    appointmentTitleStack.distribution = .fill
    appointmentTitleStack.spacing = 0
    
    appointmentTitleLabel.text = viewModel.nextAppointmentTitle
    appointmentTitleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    appointmentTitleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    allAppointmentButton.setTitle(viewModel.allAppointmentTitle, for: .normal)
    allAppointmentButton.titleLabel?.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    allAppointmentButton.setTitleColor(
      OSCAWasteUI.configuration.colorConfig.primaryColor,
      for: .normal)
    
    appointmentCollectionView.backgroundColor = .clear
    appointmentCollectionView.clipsToBounds = false
    self.appointmentCollectionView.collectionViewLayout = self.createLayout()
    self.appointmentCollectionViewHeightConstraint.constant = 0
    
    self.infoView.isHidden = OSCAWasteUI.configuration
      .isWasteInfoHidden
    self.infoView.backgroundColor = .clear
    
    infoStack.axis = .vertical
    infoStack.alignment = .fill
    infoStack.distribution = .fill
    infoStack.spacing = 16
    
    infoLabel.text = viewModel.wasteTypeTitle
    infoLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    infoLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    wasteTypeStack.axis = .horizontal
    wasteTypeStack.alignment = .fill
    wasteTypeStack.distribution = .fillEqually
    wasteTypeStack.spacing = 16
      
    wasteTypeStack2.axis = .horizontal
    wasteTypeStack2.alignment = .fill
    wasteTypeStack2.distribution = .fillEqually
    wasteTypeStack2.spacing = 16
      
    greenMobileWasteView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    greenMobileWasteView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    greenMobileWasteView.addShadow(with: OSCAWasteUI.configuration.shadow)

    let greenMobileImage = UIImage(named: "green_waste", in: OSCAWasteUI.bundle, with: nil)
    greenMobileImage?.withRenderingMode(.alwaysTemplate)
    greenMobileWasteImageView.image = greenMobileImage
      greenMobileWasteImageView.tintColor = UIColor(Color(
        "GreenWasteColor",
        bundle: OSCAWasteUI.bundle
      ))
      
    greenMobileWasteLabel.text = viewModel.greenMobileWasteTitle
    greenMobileWasteLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    greenMobileWasteLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
      
    greenMobileWasteButton.setTitle("", for: .normal)
      
    oldClothesWasteView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    oldClothesWasteView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    oldClothesWasteView.addShadow(with: OSCAWasteUI.configuration.shadow)
      
    let oldClothesImage = UIImage(named: "old_clothes", in: OSCAWasteUI.bundle, with: nil)
    oldClothesImage?.withRenderingMode(.alwaysTemplate)
    oldClothesWasteImageView.image = oldClothesImage
    oldClothesWasteImageView.tintColor = .black

    oldClothesWasteLabel.text = viewModel.oldClothesWasteTitle
    oldClothesWasteLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    oldClothesWasteLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor

    oldClothesWasteButton.setTitle("", for: .normal)
      
    pickedUpWasteView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    pickedUpWasteView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    pickedUpWasteView.addShadow(with: OSCAWasteUI.configuration.shadow)
          
    let infoImage = UIImage(systemName: "info.circle.fill")
    infoImage?.withRenderingMode(.alwaysTemplate)
    pickedUpWasteImageView.image = infoImage
    pickedUpWasteImageView.tintColor = OSCAWasteUI.configuration.colorConfig.grayLight
    
    pickedUpWasteLabel.text = viewModel.pickedUpWasteTitle
    pickedUpWasteLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    pickedUpWasteLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    pickedUpWasteButton.setTitle("", for: .normal)
    
    specialWasteView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    specialWasteView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    specialWasteView.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    let specialWasteImage = UIImage(systemName: "arrow.3.trianglepath")
    specialWasteImage?.withRenderingMode(.alwaysTemplate)
    specialWasteImageView.image = specialWasteImage
    specialWasteImageView.tintColor = OSCAWasteUI.configuration.colorConfig.grayLight
    
    specialWasteLabel.text = viewModel.specialWasteTitle
    specialWasteLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    specialWasteLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    specialWasteButton.setTitle("", for: .normal)
    
    self.additionalSpaceTextView.isHidden = OSCAWasteUI.configuration
      .isAdditionalSpaceHidden
    self.additionalSpaceTextView.backgroundColor = OSCAWasteUI.configuration
      .colorConfig.secondaryBackgroundColor
    self.additionalSpaceTextView.layer.cornerRadius = OSCAWasteUI.configuration
      .cornerRadius
    let shadow = OSCAWasteUI.configuration.shadow
    self.additionalSpaceTextView.addShadow(with: shadow)
    let size = OSCAWasteUI.configuration
      .fontConfig.bodyLight.pointSize
    let fontSize = "\(size)"
    let css = "<style> body {font-stretch: normal; font-size: \(fontSize)px; line-height: normal; font-family: 'Helvetica Neue'} </style>"
    let htmlString = "\(css)\(OSCAWasteUI.configuration.additionalSpaceText)"
    self.additionalSpaceTextView.attributedText = try? NSMutableAttributedString(
      HTMLString: htmlString,
      color: OSCAWasteUI.configuration.colorConfig.textColor)
    self.additionalSpaceTextView.font = OSCAWasteUI.configuration
      .fontConfig.bodyLight
    self.additionalSpaceTextView.linkTextAttributes = [
      .foregroundColor: OSCAWasteUI.configuration.colorConfig.primaryColor]
    self.additionalSpaceTextView.isEditable = false
    self.additionalSpaceTextView.isScrollEnabled = false
    self.additionalSpaceTextView.dataDetectorTypes = [
      .address,
      .phoneNumber,
      .link]
    self.additionalSpaceTextView.textContainerInset = UIEdgeInsets(
      top: 16,
      left: 16,
      bottom: 16,
      right: 16)
    self.additionalSpaceTextView.textContainer.lineFragmentPadding = 0
    self.additionalSpaceTextView.sizeToFit()
    
    self.button.isHidden = !OSCAWasteUI.configuration.enableBinTypeFilter
    self.button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    self.button.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    self.button.backgroundColor = OSCAWasteUI.configuration.colorConfig.primaryColor
    self.button.tintColor = OSCAWasteUI.configuration.colorConfig.primaryColor
    
    setFilterButtonTitle()
    self.button.titleLabel?.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor
    
    self.bottomSheetVC.confirmTitle = viewModel.filterConfirmTitle
    self.bottomSheetVC.cancelTitle = viewModel.filterCancelButtonTitle
    
    self.bottomSheetVC.onSelectionChange = { selectedTypes in
      self.viewModel.onFiltersSelected(selectedTypes)
      self.setFilterButtonTitle(selectedFiltersCount: selectedTypes.count)
    }
    
    setupEmptyListLabel()
      self.subscribeCalendarButton.titleLabel?.text = String(
        localized: "waste_subscribe_calendar",
        bundle: OSCAWasteUI.bundle
      )
      self.subscribeCalendarButton.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
      self.subscribeCalendarButton.backgroundColor = OSCAWasteUI.configuration.colorConfig.primaryColor
      self.subscribeCalendarButton.tintColor = OSCAWasteUI.configuration.colorConfig.primaryColor
      
      self.greenWasteDistrictAppointmentsButton.titleLabel?.text = String(
        localized: "waste_green_waste_appointments",
        bundle: OSCAWasteUI.bundle
      )
      
      self.greenWasteDistrictAppointmentsButton.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
      self.greenWasteDistrictAppointmentsButton.backgroundColor = OSCAWasteUI.configuration.colorConfig.primaryColor
      self.greenWasteDistrictAppointmentsButton.tintColor = OSCAWasteUI.configuration.colorConfig.primaryColor
  }
  
  private func setupBindings() {
    viewModel.$mondayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 1, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$tuesdayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 2, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$wednesdayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 3, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$thursdayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 4, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$fridayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 5, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$saturdayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 6, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$sundayCollections
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] collections in
        guard let `self` = self else { return }
        self.setupWeek(for: 0, with: collections)
      })
      .store(in: &bindings)
    
    viewModel.$wasteCollects
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] wasteCollects in
        guard let `self` = self else { return }
        emptyListLabel.isHidden = !wasteCollects.isEmpty
        appointmentCollectionView.isHidden = wasteCollects.isEmpty
        self.addressLabel.text = self.viewModel
          .wasteUserFullStreetAddress
        self.updateCells()
      })
      .store(in: &bindings)
    
    viewModel.$filterTypes
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] availableFilters in
        guard let `self` = self else { return }
        self.bottomSheetVC.options = availableFilters
        
        let seeAllFilter = OSCAWasteCollectBinType.with(id: -1, name: viewModel.showAllFilterOptionTitle)
        self.bottomSheetVC.options.insert(seeAllFilter, at: 0)
        
        let selectedFilterIds = self.viewModel.dataModule.userDefaults.getOSCAWasteSelectedBinTypeIds()
        
        self.bottomSheetVC.selectedOptions = availableFilters.filter {
          $0.id != nil && selectedFilterIds.contains($0.id!)
        }
        
        setFilterButtonTitle(selectedFiltersCount: selectedFilterIds.count)
      })
      .store(in: &bindings)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAWasteUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAWasteUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAWasteUI.configuration.colorConfig.navigationBarColor)
    
    self.weekdayStack.layoutIfNeeded()
  }
  
  @objc private func toogleReminder() {
    self.reminderSwitch.isOn = self.viewModel.dataModule
      .userDefaults.getOSCAWasteReminder()
  }
  
  @objc func didTapButton() {
        present(bottomSheetVC, animated: true, completion: nil)
    }
  
  private func setFilterButtonTitle(selectedFiltersCount: Int = 0) {
    if(selectedFiltersCount > 0){
      let updatedTitle = "\(self.viewModel.filterButtonTitle) (\(selectedFiltersCount))"
      self.button.setTitle(updatedTitle, for: .normal)
    } else {
      self.button.setTitle(self.viewModel.filterButtonTitle, for: .normal)
    }
  }
  
  private func setupWeek(for day: Int, with collections: [OSCAWasteCollect] = []) {
    let calendar = Calendar.current
    let symbols = calendar.shortWeekdaySymbols[day]
    let dateDay = getDateDay(for: day)
    let spacing = 8.0
    let colorConfig = OSCAWasteUI.configuration.colorConfig
    
    var attachments: [UIImage] = []
    for collection in collections {
      let collectionColor = UIColor(hex: collection.color ?? "")
        ?? .clear
      let borderColor = colorConfig.secondaryBackgroundColor.isDarkColor
        ? colorConfig.whiteColor
        : colorConfig.blackColor.withAlphaComponent(0.75)
      let colors: [UIColor] = [
        collectionColor,
        borderColor]
      let imageConfiguration = UIImage
        .SymbolConfiguration(paletteColors: colors)
      let image = UIImage(
        systemName: "circle.inset.filled",
        withConfiguration: imageConfiguration)
        ?? UIImage()
      attachments.append(image)
    }
    
    switch day {
    case 0:
      sundayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                       alignment: .vertical,
                       lineSpacing: spacing,
                       attachments: attachments,
                       attachmentBeforeText: false)
    case 1:
      mondayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                       alignment: .vertical,
                       lineSpacing: spacing,
                       attachments: attachments,
                       attachmentBeforeText: false)
    case 2:
      tuesdayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                        alignment: .vertical,
                        lineSpacing: spacing,
                        attachments: attachments,
                        attachmentBeforeText: false)
    case 3:
      wednesdayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                          alignment: .vertical,
                          lineSpacing: spacing,
                          attachments: attachments,
                          attachmentBeforeText: false)
    case 4:
      thursdayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                         alignment: .vertical,
                         lineSpacing: spacing,
                         attachments: attachments,
                         attachmentBeforeText: false)
    case 5:
      fridayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                       alignment: .vertical,
                       lineSpacing: spacing,
                       attachments: attachments,
                       attachmentBeforeText: false)
    case 6:
      saturdayLabel.with(text: "\(symbols)\n\(dateDay)\n",
                         alignment: .vertical,
                         lineSpacing: spacing,
                         attachments: attachments,
                         attachmentBeforeText: false)
      
    default: break
    }
  }
  
  private func getDateDay(for currentDay: Int) -> Int {
    let date = Date().dateByAdding(self.viewModel.currentWeek, .weekOfYear)
      .date
    
    let weekday = date.weekday - 1
    var dateDay: Int = 0
    var newDate: Date = date
    
    if currentDay > weekday {
      newDate = date.dateByAdding(abs(currentDay - weekday), .day).date
    }
    if currentDay < weekday {
      newDate = date.dateByAdding(-abs(currentDay - weekday), .day).date
    }
    if currentDay == weekday {
      newDate = date
    }
    
    dateDay = currentDay == 0
      ? newDate.dateByAdding(1, .weekOfYear).day
      : newDate.day
    
    return dateDay
  }
  
  private func configureDataSource() {
    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: appointmentCollectionView,
      cellProvider: { (collectionView, indexPath, collection) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAWasteAppointmentCollectionViewCell.identifier,
          for: indexPath) as? OSCAWasteAppointmentCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAWasteAppointmentCellViewModel(
          dataModule: self.viewModel.dataModule,
          dataCache: self.viewModel.dataCache,
          wasteCollect: collection)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
  
  private func updateCells() {
    configureDataSource()
    let limitNumberOfItems = 2
    
    self.appointmentCollectionViewHeightConstraint.constant = CGFloat(limitNumberOfItems * 100 + ((limitNumberOfItems - 1) * 8))
    
    let array = Array(viewModel.wasteCollects.prefix(limitNumberOfItems))
    
    var snapshot = NSDiffableDataSourceSnapshot<OSCAWasteViewModel.Section, OSCAWasteCollect>()
    snapshot.appendSections([.wasteAppointment])
    snapshot.appendItems(array)
    
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func createLayout() -> UICollectionViewLayout {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: size)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .absolute(100))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 0,
      leading: 0,
      bottom: 0,
      trailing: 0)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  @IBAction func nextWeekButtonTouch(_ sender: UIButton) {
    self.viewModel.nextWeekButtonTouch()
    self.dateLabel.text = self.viewModel.dateOfToday
  }
  
  @IBAction func previousWeekButtonTouch(_ sender: UIButton) {
    self.viewModel.previousWeekButtonTouch()
    self.dateLabel.text = self.viewModel.dateOfToday
  }
  
  @IBAction func reminderSwitchTouch(_ sender: UISwitch) {
    self.viewModel.reminderSwitchTouch(sender.isOn)
  }
  
  @IBAction func allAppointmentButtonTouch(_ sender: UIButton) {
    viewModel.allAppointmentButtonTouch()
  }
  
  @IBAction func greenWasteButtonTouch(_ sender: UIButton) {
      viewModel.greenAndClothesWasteButtonTouch(wasteLocationType: WasteLocationType.Grünschnittcontainer)
  }
    
  @IBAction func clothesWasteButtonTouch(_ sender: UIButton) {
      viewModel.greenAndClothesWasteButtonTouch(wasteLocationType: WasteLocationType.Altkleidercontainer)
  }
  
  @IBAction func specialpWasteButtonTouch(_ sender: UIButton) {
    viewModel.specialWasteButtonTouch(wasteType: .special)
  }
    
    @IBAction func pickedUpWasteButtonTouch(_ sender: UIButton) {
      viewModel.pickedUpWasteButtonTouch(wasteType: .pickedUp)
    }
  
    @IBAction func subscribeCalendarButtonTouch(_ sender: UIButton) {
        if let addressId = viewModel.userAddress.objectId,
           let parseBaseUrl = UserDefaults.standard.value(forKey: "parseBaseUrl") as? String {
            let prefixlessUrl = parseBaseUrl.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
            var urlString = "webcal://\(prefixlessUrl)/waste-calendar?wasteAddress=\(addressId)"
            if let userDistricts = UserDefaults.standard.stringArray(
                forKey: OSCAWaste.greenWasteAppointmentDistrictsKey
            ), let encodedDistricts = try? JSONEncoder().encode(userDistricts),
                let jsonString = String(data: encodedDistricts, encoding: .utf8),
                let encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlString += "&greenWasteDistricts=\(encodedString)"
            }
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func createDistrictsButtonMenu(districts: [OSCAWasteGreenAndClothesDistrict]) {
        DispatchQueue.main.async {
            let items = districts
            let userDistricts = UserDefaults.standard.stringArray(
                forKey: OSCAWaste.greenWasteAppointmentDistrictsKey
              )
            let actions: [UIAction] = items.map { item in
                let action = UIAction(title: item.name!) { action in
                    // The following updates the original UIAction without crashing
                    if let act = self.greenWasteDistrictAppointmentsButton.menu?.children.first(where: {
                        $0.title == action.title
                    }), let act = act as? UIAction {
                        if act.state == .on {
                            act.state = .off
                            self.viewModel.didDeselect(at: act.title)
                        } else {
                            act.state = .on
                            self.viewModel.didSelect(at: act.title)
                        }
                    }
                }
                if let userDistricts = userDistricts {
                    action.state = userDistricts
                        .contains(where: { district in action.title == district }) ? .on : .off
                } else {
                    action.state = .off
                }
                return action
            }
            
            self.greenWasteDistrictAppointmentsButton.menu = UIMenu(children: actions)
            self.greenWasteDistrictAppointmentsButton.showsMenuAsPrimaryAction = true
        }
    }
    
  private func setupEmptyListLabel() {
    emptyListLabel.text = viewModel.noAppointmentsText
    emptyListLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor.lighter(componentDelta: 0.7)
    emptyListLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy.withSize(12)
    emptyListLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      emptyListLabel.heightAnchor.constraint(equalToConstant: 200)
    ])
  }
}

// MARK: - instantiate view conroller
extension OSCAWasteViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAWasteViewModel) -> OSCAWasteViewController {
    let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

class BottomSheetViewController: UIViewController {
  public var cancelTitle: String = "Cancel"
  public var confirmTitle: String = "Ok"
  
  var tableView: UITableView!
  var onSelectionChange: (([OSCAWasteCollectBinType] ) -> Void)? = nil
  
  public static var seeAllOptionId = -1
  var options: [OSCAWasteCollectBinType] = []
  var selectedOptions: [OSCAWasteCollectBinType] = [] {
    didSet {
      guard let seeAllOption = getSeeAllOption() else { return }
      let validFilters = selectedOptions.filter { $0 != seeAllOption }
      
      if self.selectedOptions.isEmpty {
        self.selectedOptions = [seeAllOption]
      }
      if !validFilters.isEmpty {
        self.selectedOptions.removeAll { $0 == seeAllOption }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 100))
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
    view.addSubview(tableView)
    
    let cancelButton = UIButton(type: .system)
    cancelButton.setTitle(self.cancelTitle, for: .normal)
    cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    cancelButton.setTitleColor(OSCAWasteUI.configuration.colorConfig.textColor, for: .normal)
    view.addSubview(cancelButton)
    
    let doneButton = UIButton(type: .system)
    doneButton.setTitle(self.confirmTitle, for: .normal)
    doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    doneButton.setTitleColor(OSCAWasteUI.configuration.colorConfig.primaryColor, for: .normal)
    view.addSubview(doneButton)
    
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    doneButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36),
      doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36),
      cancelButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor)
    ])
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8)
    ])
    
    view.backgroundColor = .white
  }
  
  @objc func didTapDone() {
    let validSelectedOptions = self.selectedOptions.filter { $0.id != Self.seeAllOptionId }
    self.onSelectionChange?(validSelectedOptions)
    dismiss(animated: true, completion: nil)
  }
  
  @objc func didTapCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  private func getSeeAllOption() -> OSCAWasteCollectBinType? {
    return options.first { $0.id == Self.seeAllOptionId }
  }
}

extension BottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return options.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
    cell.tintColor = OSCAWasteUI.configuration.colorConfig.primaryColor
    cell.textLabel?.text = options[indexPath.row].name
    if selectedOptions.contains(options[indexPath.row]) {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedOption = options[indexPath.row]
    let isSeeAllSelected = selectedOption.id == Self.seeAllOptionId && !selectedOptions.isEmpty
    
    if isSeeAllSelected {
      resetSelection()
    } else {
      selectedOptions.removeAll { $0.id == Self.seeAllOptionId }
      updateSelection(selectedOption: selectedOption)
    }
    tableView.reloadData()
  }
  
  private func resetSelection() {
    selectedOptions = options.filter { $0.id == Self.seeAllOptionId }
  }
  
  private func updateSelection(selectedOption: OSCAWasteCollectBinType){
    if selectedOptions.contains(selectedOption) {
      selectedOptions = selectedOptions.filter { $0 != selectedOption }
    } else {
      selectedOptions.append(selectedOption)
    }
  }
}

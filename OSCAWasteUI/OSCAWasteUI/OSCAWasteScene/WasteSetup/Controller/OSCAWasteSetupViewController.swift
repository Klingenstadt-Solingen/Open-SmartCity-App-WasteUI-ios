//
//  OSCAWasteSetupViewController.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 08.07.22.
//

import OSCAEssentials
import OSCAWaste
import UIKit
import Combine

public final class OSCAWasteSetupViewController: UIViewController, Alertable {
  
  @IBOutlet private var mainStack: UIStackView!
  @IBOutlet private var addressSetupDescriptionView: UIView!
  @IBOutlet private var addressSetupDescriptionLabel: UILabel!
  @IBOutlet private var separatorView: UIView!
  @IBOutlet private var collectionView: UICollectionView!
  
  private var saveBarButtonItem: UIBarButtonItem!
  private let searchController = UISearchController(searchResultsController: nil)
  
  private typealias DataSource = UICollectionViewDiffableDataSource<OSCAWasteSetupViewModel.Section, OSCAWasteAddress>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<OSCAWasteSetupViewModel.Section, OSCAWasteAddress>
  
  private var viewModel: OSCAWasteSetupViewModel!
  private var bindings = Set<AnyCancellable>()
  
  private var dataSource: DataSource!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.saveBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(self.saveBarButtonItemTouch(_:)))
    self.saveBarButtonItem.tintColor = OSCAWasteUI.configuration.colorConfig.navigationTintColor
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.searchController.searchResultsUpdater = self
    self.searchController.obscuresBackgroundDuringPresentation = true
    self.searchController.searchBar.placeholder = self.viewModel.searchPlaceholder
    self.navigationItem.searchController = self.searchController
    
    if let textfield = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
      textfield.textColor = OSCAWasteUI.configuration.colorConfig.blackColor
      textfield.tintColor = OSCAWasteUI.configuration.colorConfig.navigationTintColor
      textfield.backgroundColor = OSCAWasteUI.configuration.colorConfig.grayLighter
      textfield.leftView?.tintColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
      textfield.returnKeyType = .done
      textfield.keyboardType = .default
      textfield.enablesReturnKeyAutomatically = false
      textfield.delegate = self
      
      if let clearButton = textfield.value(forKey: "_clearButton") as? UIButton {
        let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(templateImage, for: .normal)
        clearButton.tintColor = OSCAWasteUI.configuration.colorConfig.grayDarker
      }
      
      if let label = textfield.value(forKey: "placeholderLabel") as? UILabel {
        label.attributedText = NSAttributedString(
          string: viewModel.searchPlaceholder,
          attributes: [.foregroundColor: OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)])
      }
    }
    
    self.view.backgroundColor = OSCAWasteUI.configuration.colorConfig.backgroundColor
    
    self.mainStack.axis = .vertical
    self.mainStack.alignment = .fill
    self.mainStack.distribution = .fill
    self.mainStack.spacing = 0
    
    self.addressSetupDescriptionView.backgroundColor = OSCAWasteUI.configuration.colorConfig.navigationBarColor
    
    self.addressSetupDescriptionLabel.text = self.viewModel.addressSetupDescription
    self.addressSetupDescriptionLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    self.addressSetupDescriptionLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    self.addressSetupDescriptionLabel.numberOfLines = 0
    
    self.separatorView.backgroundColor = OSCAWasteUI.configuration.colorConfig.grayColor
    
    self.collectionView.delegate = self
    self.collectionView.backgroundColor = .clear
    self.collectionView.collectionViewLayout = self.createLayout()
  }
  
  private func setupBindings() {
    self.viewModel.$searchedWasteAddress
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] searchedWasteAddress in
        guard let `self` = self else { return }
        
        if !searchedWasteAddress.isEmpty {
          self.updateSections(searchedWasteAddress)
          self.separatorView.isHidden = false
        }
        else { self.separatorView.isHidden = true }
      })
      .store(in: &self.bindings)
    
    let stateValueHandler: (OSCAWasteSetupViewModelState) -> Void = { [weak self] state in
      guard let `self` = self else { return }
      
      switch state {
      case .loading:
        self.startLoading()
        
      case .finishedLoading:
        self.finishLoading()
        
      case .selectedWasteAddress:
        self.saveBarButtonItem.isEnabled = true
        
      case .deselectedWasteAddress:
        self.saveBarButtonItem.isEnabled = false
        self.viewModel.selectedWasteAddress = nil
        
      case .error(.wasteAddressFetch):
        self.finishLoading()
        
      case .error(.wasteAddressSave):
        self.showAlert(title: self.viewModel.alertTitleError,
                       message: self.viewModel.alertMessageError,
                       actionTitle: self.viewModel.alertActionConfirm)
      }
    }
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAWasteUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAWasteUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAWasteUI.configuration.colorConfig.navigationBarColor)
  }
  
  private func updateSections(_ wasteAddress: [OSCAWasteAddress]) {
    self.configureDataSource()
    var snapshot = Snapshot()
    snapshot.appendSections([.wasteAddress])
    snapshot.appendItems(wasteAddress)
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(80))
    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
    
    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
    section.interGroupSpacing = 8
    
    section.boundarySupplementaryItems = [header]
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func startLoading() {
    self.collectionView.refreshControl?.beginRefreshing()
  }
  
  private func finishLoading() {
    self.collectionView.refreshControl?.endRefreshing()
  }
  
  @objc private func saveBarButtonItemTouch(_ barButtonItem: UIBarButtonItem) {
    self.viewModel.saveBarButtonItemTouch()
  }
}

// MARK: - instantiate view conroller
extension OSCAWasteSetupViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAWasteSetupViewModel) -> OSCAWasteSetupViewController {
    let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCAWasteSetupViewController {
  private func configureDataSource() -> Void {
    self.dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { (collectionView, indexPath, wasteAddress) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAWasteSetupCollectionViewCell.identifier,
          for: indexPath) as? OSCAWasteSetupCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAWasteSetupCellViewModel(wasteAddress: wasteAddress)
        cell.fill(with: cellViewModel)
        
        return cell
      })
    
    self.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: OSCAWasteSetupCollectionReusableView.identifier,
          for: indexPath) as? OSCAWasteSetupCollectionReusableView
        else { return UICollectionReusableView() }
        
        let headerViewModel = OSCAWasteSetupReusableViewModel()
        header.fill(with: headerViewModel)
        
        return header
        
      default: return UICollectionReusableView()
      }
    }
  }
}

extension OSCAWasteSetupViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
    guard let text = searchController.searchBar.text else { return }
    self.viewModel.updateSearchResults(for: text)
  }
}

extension OSCAWasteSetupViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.viewModel.didSelectItem(at: indexPath.row)
  }
}

extension OSCAWasteSetupViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.searchController.isActive = false
    return true
  }
}

//
//  OSCAWasteAppointmentViewControllerWidget.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 21.03.23.
//

import OSCAWaste
import OSCAEssentials
import UIKit
import Combine

public final class OSCAWasteAppointmentViewControllerWidget: UIViewController, Alertable, WidgetExtender {
  public var didLoadContent: ((Int) -> Void)? = nil
  
  public var performNavigation: ((Any) -> Void)? = nil
  
  public func refreshContent() {
    self.viewModel.viewDidLoad()
  }
  
  
  @IBOutlet public var collectionView: UICollectionView!
  
  private var viewModel: OSCAWasteAppointmentViewModelWidget!
  private var bindings = Set<AnyCancellable>()
  private var emptyListLabel = UILabel()
  
  private typealias WasteDataSource = UICollectionViewDiffableDataSource<OSCAWasteAppointmentViewModelWidget.Section, OSCAWasteCollect>
  private typealias WasteSnapshot = NSDiffableDataSourceSnapshot<OSCAWasteAppointmentViewModelWidget.Section, OSCAWasteCollect>
  private var dataSource: WasteDataSource!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.widgetTitle
    
    self.view.backgroundColor = .clear
    
    self.collectionView.backgroundColor = .clear
    self.collectionView.collectionViewLayout = self.createLayout()
    
    self.configureDataSource()
    
    setupEmptyListLabel()
  }
  
  private func setupBindings() {
    self.viewModel.$wasteCollects
      .sink(receiveValue: { [weak self] wasteCollects in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          self.emptyListLabel.isHidden = !wasteCollects.isEmpty
          self.updateSections(wasteCollects)
        }
      })
      .store(in: &self.bindings)
  
    let stateValueHandler: (OSCAWasteAppointmentViewModelWidget.State) -> Void = { [weak self] state in
      guard let `self` = self else { return }
      switch state {
      case .loading:
        self.beginLoading()
        
      case .finishedLoading:
        self.finishLoading()
        
      case let .error(error):
        self.finishLoading()
        self.showAlert(
          title: self.viewModel.alertTitleError,
          error: error,
          actionTitle: self.viewModel.alertActionConfirm)
      }
    }
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }
  
  private func setupEmptyListLabel() {
    emptyListLabel.text = viewModel.noAppointmentsText
    emptyListLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor.lighter(componentDelta: 0.7)
    emptyListLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy.withSize(12)
    emptyListLabel.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(emptyListLabel)
    NSLayoutConstraint.activate([
      emptyListLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyListLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: self.viewModel.moduleConfig.colorConfig.navigationTintColor,
      titleTextColor: self.viewModel.moduleConfig.colorConfig.navigationTitleTextColor,
      barColor: self.viewModel.moduleConfig.colorConfig.navigationBarColor)
  }
  
  
  private func beginLoading() {}
  
  private func finishLoading() -> Void {}
  
  private func configureDataSource() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: self.collectionView,
      cellProvider: { (collectionView, indexPath, collection) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAWasteAppointmentCollectionViewCell.identifier,
          for: indexPath) as? OSCAWasteAppointmentCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAWasteAppointmentCellViewModel(
          dataModule: self.viewModel.dataModule,
          dataCache: self.viewModel.dependencies.dataCache,
          wasteCollect: collection)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
  
  private func updateSections(_ wasteCollect: [OSCAWasteCollect]) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var snapshot = WasteSnapshot()
    snapshot.appendSections([.wasteAppointment])
    let numberOfItems = self.viewModel.numberOfVisibleItems
    let items = Array(wasteCollect.prefix(numberOfItems))
    snapshot.appendItems(items)
    self.dataSource.apply(snapshot, animatingDifferences: true)
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
}

// MARK: - Instantiate view conroller
extension OSCAWasteAppointmentViewControllerWidget: StoryboardInstantiable {
  public static func create(with viewModel: OSCAWasteAppointmentViewModelWidget) -> OSCAWasteAppointmentViewControllerWidget {
    let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

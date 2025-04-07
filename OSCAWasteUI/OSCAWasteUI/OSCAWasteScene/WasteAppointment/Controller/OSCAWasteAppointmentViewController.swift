//
//  OSCAWasteAppointmentViewController.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 24.06.22.
//

import OSCAEssentials
import OSCAWaste
import UIKit

public final class OSCAWasteAppointmentViewController: UIViewController {
  
  @IBOutlet private var appointmentCollectionView: UICollectionView!
  
  private var viewModel: OSCAWasteAppointmentViewModel!
  
  var dataSource: UICollectionViewDiffableDataSource<OSCAWasteAppointmentViewModel.Section, OSCAWasteCollect>!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCAWasteUI.configuration.colorConfig.backgroundColor
    
    self.appointmentCollectionView.alwaysBounceVertical = true
    self.appointmentCollectionView.backgroundColor = .clear
    self.appointmentCollectionView.collectionViewLayout = self.createLayout()
    
    updateCells()
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
  
  private func configureDataSource() {
    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: self.appointmentCollectionView,
      cellProvider: { (collectionView, indexPath, collection) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAWasteAppointmentCollectionViewCell.identifier,
          for: indexPath) as? OSCAWasteAppointmentCollectionViewCell
        else { return UICollectionViewCell() }
        
        if indexPath.item < self.viewModel.appointmentViewModels.count {
          let cellViewModel = self.viewModel.appointmentViewModels[indexPath.item]
          cell.fill(with: cellViewModel)
        }
        
        return cell
      })
  }
  
  private func updateCells() {
    self.configureDataSource()
    var snapshot = NSDiffableDataSourceSnapshot<OSCAWasteAppointmentViewModel.Section, OSCAWasteCollect>()
    
    snapshot.appendSections([.wasteAppointment])
    snapshot.appendItems(self.viewModel.sortedCollections)
    
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

// MARK: - instantiate view conroller
extension OSCAWasteAppointmentViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAWasteAppointmentViewModel) -> OSCAWasteAppointmentViewController {
    let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

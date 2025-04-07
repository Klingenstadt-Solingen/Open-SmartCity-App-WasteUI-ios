//
//  OSCAWasteInfoViewController.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 04.07.22.
//

import OSCAEssentials
import OSCAWaste
import UIKit
import Combine

public final class OSCAWasteInfoViewController: UIViewController {
  
  @IBOutlet private var mainView: UIView!
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var wasteDescriptionLabel: UILabel!
  @IBOutlet private var collectionView: SelfSizedCollectionView!
  
  private typealias DataSourceInfo = UICollectionViewDiffableDataSource<OSCAWasteInfoViewModel.Section, OSCAWasteInfo>
  private typealias SnapshotInfo = NSDiffableDataSourceSnapshot<OSCAWasteInfoViewModel.Section, OSCAWasteInfo>
  private typealias DataSourceSubtype = UICollectionViewDiffableDataSource<OSCAWasteInfoViewModel.Section, OSCAWasteSubtype>
  private typealias SnapshotSubtype = NSDiffableDataSourceSnapshot<OSCAWasteInfoViewModel.Section, OSCAWasteSubtype>
  
  private var viewModel: OSCAWasteInfoViewModel!
  private var bindings = Set<AnyCancellable>()
  
  private var dataSourceInfo: DataSourceInfo!
  private var dataSourceSubtype: DataSourceSubtype!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.view.backgroundColor = OSCAWasteUI.configuration.colorConfig.backgroundColor
    
    self.navigationItem.title = viewModel.screenTitle
    
    self.scrollView.alwaysBounceVertical = true
    
    self.mainView.backgroundColor = .clear
    
    self.wasteDescriptionLabel.text = viewModel.wasteDescription
    self.wasteDescriptionLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    self.wasteDescriptionLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    self.wasteDescriptionLabel.numberOfLines = 0
    
    self.collectionView.delegate = self
    self.collectionView.backgroundColor = .clear
    self.collectionView.collectionViewLayout = createLayout()
  }
  
  private func setupBindings() {
    self.viewModel.$wasteInfos
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] wasteInfos in
        guard let `self` = self else { return }
        self.updateSectionInfo(wasteInfos)
      })
      .store(in: &self.bindings)
    
    self.viewModel.$wasteSpecialSubtypes
        .receive(on: RunLoop.main)
        .dropFirst()
        .sink(receiveValue: { [weak self] wasteSpecialSubtypes in
          guard let `self` = self else { return }
          self.updateSectionSubtype(wasteSpecialSubtypes)
        })
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
  
  private func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(3/11),
      heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let itemSpacing = NSCollectionLayoutSpacing.fixed(8)
    item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: itemSpacing, top: itemSpacing, trailing: itemSpacing, bottom: itemSpacing)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(110))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = NSCollectionLayoutSpacing.flexible(0)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func updateSectionInfo(_ wasteInfo: [OSCAWasteInfo]) {
    self.configureDataSourceInfo()
    var snapshot = SnapshotInfo()
    snapshot.appendSections([.wasteInfo])
    snapshot.appendItems(wasteInfo)
    self.dataSourceInfo.apply(snapshot, animatingDifferences: true)
  }
  
  private func updateSectionSubtype(_ wasteSubtype: [OSCAWasteSubtype]) {
    self.configureDataSourceSubtype()
    var snapshot = SnapshotSubtype()
    snapshot.appendSections([.wasteType])
    snapshot.appendItems(wasteSubtype)
    self.dataSourceSubtype.apply(snapshot, animatingDifferences: true)
  }
}

extension OSCAWasteInfoViewController {
  private func configureDataSourceInfo() -> Void {
    self.dataSourceInfo = DataSourceInfo(
      collectionView: self.collectionView,
      cellProvider: { (collectionView, indexPath, wasteInfo) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAWasteInfoCollectionViewCell.identifier,
          for: indexPath) as? OSCAWasteInfoCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAWasteInfoCellViewModel(
          dataModule: self.viewModel.dataModule,
          dataCache: self.viewModel.dataCache,
          wasteInfo: wasteInfo)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
  
  private func configureDataSourceSubtype() -> Void {
    self.dataSourceSubtype = DataSourceSubtype(
      collectionView: self.collectionView,
      cellProvider: { (collectionView, indexPath, wasteSubtype) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAWasteInfoSpecialCollectionViewCell.identifier,
          for: indexPath) as? OSCAWasteInfoSpecialCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAWasteInfoSpecialCellViewModel(
          wasteSubtype: wasteSubtype)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
}

// MARK: - instantiate view conroller
extension OSCAWasteInfoViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAWasteInfoViewModel) -> OSCAWasteInfoViewController {
    let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCAWasteInfoViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.viewModel.didSelect(at: indexPath.row)
  }
}

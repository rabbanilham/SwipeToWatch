//
//  SettingsViewController.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import SnapKit
import UIKit

final class SettingsViewController: UIViewController {
    private let viewModel = SettingsViewModel()
    private let settings = AppSettings.allSettings()
    
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        
        view.addSubview(settingsTableView)
        settingsTableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        return view
    }()
    
    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsAppCell.self, forCellReuseIdentifier: "\(SettingsAppCell.self)")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // limitation in iOS 13 or lower: cannot use default content configuration to show detail label of a cell
        let cell = SettingsAppCell(style: .subtitle, reuseIdentifier: "\(SettingsAppCell.self)")
        cell.delegate = self
        cell.configure(with: settings[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = settings[indexPath.row]
        switch setting.name {
        case .clearCache:
            showClearCacheAlert()
        case .playbackQuality:
            showPlaybackQualityOptionAlert()
        default:
            break
        }
    }
}

extension SettingsViewController: SettingsAppCellDelegate {
    func didChangeSetting(name: String, to value: Any) {
        viewModel.handleChangeSettings(name: name, to: value)
    }
}

private extension SettingsViewController {
    func configureUI() {
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
    }
    
    func showClearCacheAlert() {
        let alert = UIAlertController(
            title: "Clear Cache",
            message: "Are you sure want to clear video cache?",
            preferredStyle: .alert
        )
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.clearVideoCache()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func showPlaybackQualityOptionAlert() {
        let alert = UIAlertController(
            title: "Playback Quality",
            message: "Choose a playback quality. Higher quality playback takes more time to load. Needs refresh to take effect.",
            preferredStyle: .actionSheet
        )
        
        let uhdAction = UIAlertAction(title: "Ultra HD (1440p or 4K)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.handleChangeSettings(name: .playbackQuality, to: VideoQuality.uhd)
            self.settingsTableView.reloadData()
        }
        let hdAction = UIAlertAction(title: "HD (720p or 1080p)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.handleChangeSettings(name: .playbackQuality, to: VideoQuality.hd)
            self.settingsTableView.reloadData()
        }
        let sdAction = UIAlertAction(title: "SD (360p, 480p, or 640p)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.handleChangeSettings(name: .playbackQuality, to: VideoQuality.sd)
            self.settingsTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        [uhdAction, hdAction, sdAction, cancelAction].forEach({ alert.addAction($0) })
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

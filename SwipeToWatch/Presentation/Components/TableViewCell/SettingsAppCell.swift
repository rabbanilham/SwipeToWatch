//
//  SettingsAppCell.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//


import SnapKit
import UIKit

protocol SettingsAppCellDelegate: AnyObject {
    func didChangeSetting(name: String, to value: Any)
}


final class SettingsAppCell: UITableViewCell {
    // MARK: - Private Properties -
    
    private var setting: AppSettings?
    private var settingName: String?
    private var transparent = false
    
    // MARK: - Public Properties -
    
    weak var delegate: SettingsAppCellDelegate?
    
    // MARK: - UI Properties -
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.setOn(false, animated: true)
        toggle.onTintColor = .systemPink
        toggle.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let setting = setting {
            configureContentConfiguration(with: setting, transparent: transparent)
        }
    }
    
    func configure(with setting: AppSettings, transparent: Bool = false) {
        selectionStyle = .none
        self.setting = setting
        settingName = setting.name
        self.transparent = transparent
        configureContentConfiguration(with: setting, transparent: transparent)
        if transparent {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }
    }
    
    func configureContentConfiguration(with setting: AppSettings, transparent: Bool = false) {
        textLabel?.attributedText = createAttributedText(setting.title)
        switch setting.name {
        case .playbackQuality:
            detailTextLabel?.attributedText = createSecondaryAttributedText(UserPreference.shared.playbackQuality.rawValue.uppercased(), size: 12)
        default:
            detailTextLabel?.attributedText = createSecondaryAttributedText(setting.description ?? "", size: 12)
        }
        detailTextLabel?.numberOfLines = 0
        
        accessoryView = {
            switch setting.name {
            case .shuffleFeeds:
                toggleSwitch.setOn(UserPreference.shared.shuffleFeeds, animated: true)
                return toggleSwitch
            case .simulateFetchError:
                toggleSwitch.setOn(UserPreference.shared.simulateFetchError, animated: true)
                return toggleSwitch
            case .useApiCall:
                toggleSwitch.setOn(UserPreference.shared.useApiCall, animated: true)
                return toggleSwitch
            default:
                return nil
            }
        }()
        accessoryType = {
            switch setting.name {
            case .preferredOrientation, .playbackQuality:
                return .disclosureIndicator
            default:
                return .none
            }
        }()
    }
    
    private func createAttributedText(_ text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label, .paragraphStyle: createParagraphStyle()])
    }
    
    private func createSecondaryAttributedText(_ text: String, size: CGFloat) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: size), .foregroundColor: UIColor.secondaryLabel, .paragraphStyle: createParagraphStyle()])
    }
    
    private func createParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        return paragraphStyle
    }
    
    @objc
    private func switchChanged(_ sender: UISwitch) {
        if let settingName = settingName {
            delegate?.didChangeSetting(name: settingName, to: sender.isOn)
        }
    }
}

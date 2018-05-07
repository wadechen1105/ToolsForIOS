import UIKit

fileprivate enum DeviceInfoLabel {
    case language
}

class DeviceinfoViewController: UITableViewController {

    let cellName = "device_ui_cell"

    private let label: [DeviceInfoLabel] = [.language]

    override func viewDidLoad() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellName)
    }

    ////////////// callback //////////////////
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return label.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.d("index row :\(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: false)

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = cellName

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch label[indexPath.row] {
        case .language:
            let lan = Locale.preferredLanguages[0]
            let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? ""
            cell.textLabel?.text = "la: \(lan), locale: \(countryCode)"
        default:
            break
        }
        
        return cell
    }

//    private func registerSystemTimeService() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleTimeChanged),
//                                               name: NSNotification.Name.UIApplicationSignificantTimeChange,
//                                               object: nil)
//    }
//
//    private func registerSystemLocaleService() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleLocaleChanged),
//                                               name: NSNotification.Name.NSCalendarDayChanged,
//                                               object: nil)
//    }
//
//    @objc private func handleTimeChanged() {
//        Log.d("### receive system time changed!!")
//    }
//
//    @objc private func handleLocaleChanged() {
//        Log.d("### receive system locale changed!!")
//    }

}

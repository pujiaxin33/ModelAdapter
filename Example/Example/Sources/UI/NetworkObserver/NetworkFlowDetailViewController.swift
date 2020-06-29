//
//  NetworkFlowDetailViewController.swift
//  JXCaptain
//
//  Created by jiaxin on 2019/9/2.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

class NetworkFlowDetailViewController: UITableViewController {
    let flowModel: NetworkFlowModel
    var dataSource = [NetworkFlowDetailSectionModel]()

    init(flowModel: NetworkFlowModel) {
        self.flowModel = flowModel
        super.init(style: .grouped)

        let request = flowModel.request
        let response = flowModel.response
        var responseBodyCellModel: NetworkFlowDetailCellModel?
        if NetworkObserverSoldier.shared.cache.object(forKey: flowModel.requestID as AnyObject) == nil {
            responseBodyCellModel = cellModel(title: "Response Body", detail: "no in cache")
        }else {
            responseBodyCellModel = cellModel(type: .responseBody, title: "Response Body", detail: "tap to view")
        }
        var generalItems = [cellModel(title: "Request URL", detail: request.url?.absoluteString),
                            cellModel(title: "Request Method", detail: request.httpMethod),
                            cellModel(title: "Request Body Size", detail: flowModel.requestBodySize),
                            cellModel(type: .requestBody, title: "Request Body", detail: "tap to view"),
                            cellModel(title: "Status Code", detail: flowModel.statusCodeString),
                            responseBodyCellModel!,
                            cellModel(title: "Response Size", detail: flowModel.downFlow),
                            cellModel(title: "MIME Type", detail: flowModel.mimeType),
                            cellModel(title: "Start Time", detail: flowModel.startDateString),
                            cellModel(title: "Total Duration", detail: flowModel.durationString)]
        if flowModel.errorString != nil {
            generalItems.insert(cellModel(title: "Error", detail: flowModel.errorString), at: 2)
        }
        let generalSection = NetworkFlowDetailSectionModel(title: "General", items: generalItems)
        dataSource.append(generalSection)

        if let headerFileds = request.allHTTPHeaderFields, !headerFileds.isEmpty {
            var requestItems = [NetworkFlowDetailCellModel]()
            for (key, value) in headerFileds {
                requestItems.append(cellModel(title: key, detail: value))
            }
            dataSource.append(NetworkFlowDetailSectionModel(title: "Request Headers", items: requestItems))
        }

        if let headerFileds = (response as? HTTPURLResponse)?.allHeaderFields, !headerFileds.isEmpty {
            var responseItems = [NetworkFlowDetailCellModel]()
            for (key, value) in headerFileds {
                guard let keyString = key as? String else {
                    continue
                }
                if let valueString = value as? String {
                    responseItems.append(cellModel(title: keyString, detail: valueString))
                }else if let valueArray = value as? [String] {
                    let valueString = valueArray.reduce("") { (result, item) -> String in
                        return "\(result),\(item)"
                    }
                    responseItems.append(cellModel(title: keyString, detail: valueString))
                }else if let valueDict = value as? [String : String] {
                    let valueString = valueDict.reduce("") { (result, valueTuple) -> String in
                        return "\(result),\(valueTuple.key)=\(valueTuple.value)"
                    }
                    responseItems.append(cellModel(title: keyString, detail: valueString))
                }
            }
            dataSource.append(NetworkFlowDetailSectionModel(title: "Response Headers", items: responseItems))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "请求详情"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func cellModel(type: NetworkFlowDetailCellType = .normal, title: String, detail: String?) -> NetworkFlowDetailCellModel {
        return NetworkFlowDetailCellModel(type: type, text: cellText(title: title, detail: detail))
    }

    func cellText(title: String, detail: String?) -> NSAttributedString {
        let wholeString = "\(title):\(detail ?? "unknown")"
        let text = NSMutableAttributedString(string: wholeString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.black])
        text.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium), NSAttributedString.Key.foregroundColor : UIColor.gray], range: NSString(string: wholeString).range(of: "\(title):"))
        return text
    }

    //MARK: - UITableViewDataSource & UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellModel = dataSource[indexPath.section].items[indexPath.row]
        if cellModel.type == .normal {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }else {
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.attributedText = cellModel.text
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIMenuController.shared.setMenuVisible(false, animated: true)
        let cellModel = dataSource[indexPath.section].items[indexPath.row]
        if cellModel.type != .normal {
            let vc = NetworkFlowResponseDataDetailViewController(flowModel: flowModel, cellType: cellModel.type)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let cellModel = dataSource[indexPath.section].items[indexPath.row]
            UIPasteboard.general.string = cellModel.text.string
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
}

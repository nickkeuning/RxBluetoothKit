//
//  CharacteristicsTableViewController.swift
//  Example
//
//  Created by Kacper Harasim on 14.04.2016.
//  Copyright © 2016 Polidea. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift

class CharacteristicsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var service: Service!

    private let disposeBag = DisposeBag()

    @IBOutlet weak var characteristicsTableView: UITableView!
    
    private var characteristicsList: [Characteristic] = []
    private let characteristicCellId = "CharacteristicCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        characteristicsTableView.delegate = self
        characteristicsTableView.dataSource = self
        characteristicsTableView.estimatedRowHeight = 40.0
        characteristicsTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getCharacteristicsForService(service)
    }

    private func getCharacteristicsForService(service: Service) {
        service.discoverCharacteristics(nil)
            .subscribeNext { characteristics in
                self.characteristicsList = characteristics
                self.characteristicsTableView.reloadData()
            }.addDisposableTo(disposeBag)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristicsList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(characteristicCellId, forIndexPath: indexPath)
        let characteristic = characteristicsList[indexPath.row]
        if let cell = cell as? CharacteristicTableViewCell {
            cell.updateWithCharacteristic(characteristic)
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let characteristic = characteristicsList[indexPath.row]
        let actionSheet = UIAlertController(title: "Choose action", message: nil, preferredStyle: .ActionSheet)
        let turnNotificationOffAction = UIAlertAction(title: "Turn OFF notifications", style: .Default) { _ in
            self.setNotificationsState(enabled: false, characteristic: characteristic)
        }
        let turnNotificationOnAction = UIAlertAction(title: "Turn ON notifications", style: .Default) { _ in
            self.setNotificationsState(enabled: true, characteristic: characteristic)
        }

        let readValueNotificationAction = UIAlertAction(title: "Trigger value read", style: .Default) { _ in
            self.triggerValueReadForCharacteristic(characteristic)
        }

        actionSheet.addAction(turnNotificationOffAction)
        actionSheet.addAction(turnNotificationOnAction)
        actionSheet.addAction(readValueNotificationAction)

        if characteristic.properties = .

        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    private var monitorValueUpdateDisposable: Disposable?
    private func setNotificationsState(enabled enabled: Bool, characteristic: Characteristic) {
        monitorValueUpdateDisposable?.dispose()

        monitorValueUpdateDisposable = characteristic.setNotifyValue(enabled)
            .doOnNext { self.refreshCharacteristic($0) }
            .flatMap { $0.monitorValueUpdate() }
            .subscribeNext {
                self.refreshCharacteristic($0)
            }
    }


    private func triggerValueReadForCharacteristic(characteristic: Characteristic) {
        characteristic.readValue()
            .subscribeNext {
                self.refreshCharacteristic($0)
            }.addDisposableTo(disposeBag)
    }

    private func refreshCharacteristic(characteristic: Characteristic) {
        characteristicsTableView.reloadData()
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "CHARACTERISTICS"
    }
}


extension CharacteristicTableViewCell {
    func updateWithCharacteristic(characteristic: Characteristic) {
        self.UUIDLabel.text = characteristic.uuid.UUIDString
        self.isNotifyingLabel.text = characteristic.isNotifying ? "true" : "false"
        self.valueLabel.text = characteristic.value?.hexadecimalString ?? "Empty"
    }
}





//
//  ConfigureDevicesViewController.swift
//  RemoteHome
//
//  Created by John Forde on 9/11/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit
import IGListKit
import PromiseKit

class ConfigureDevicesViewController: UIViewController {

	var iotDevices: [IoTDevice] = []
	let v = ControlsView()

	lazy var adapter: ListAdapter = {
		return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
	}()

	override func loadView() {
		view = v
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Configure Devices"

		NotificationCenter.default.addObserver(self, selector: #selector(refreshDevices), name: .refreshDevices, object: nil)

		// Setup IGListView Adapter
		adapter.collectionView = v.listView
		adapter.dataSource = self

		// Load data into ListKit view
		iotDevices = DeviceDataApi.shared.devices
		self.adapter.performUpdates(animated: true)

		// And also perform a refresh
		firstly {
			DeviceDataApi.shared.refreshDeviceData()
			}.done { devices in
				self.iotDevices = devices
				self.adapter.performUpdates(animated: true)
			}.catch { error in
				print(error.localizedDescription)
		}
	}

	@objc func refreshDevices(_ notification: Notification) {
		print("Notification received. Refreshing data.")
		firstly {
			DeviceDataApi.shared.refreshDeviceData()
			}.done { devices in
				self.iotDevices = devices
				self.adapter.reloadData(completion: nil)
			}.catch { error in
				print(error.localizedDescription)
		}
	}

}

// MARK: List Adapter Data Source
extension ConfigureDevicesViewController: ListAdapterDataSource {
	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return iotDevices as [ListDiffable]
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		return ConfigDeviceSectionController()
	}

	func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}
}


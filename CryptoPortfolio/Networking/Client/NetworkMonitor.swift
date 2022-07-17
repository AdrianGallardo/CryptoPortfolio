//
//  NetworkMonitor.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 15/04/22.
//

import Foundation
import Network

final class NetworkMonitor {
	static let shared = NetworkMonitor()

	private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
	private let monitor: NWPathMonitor

	public private(set) var isConnected: Bool = false
	public private(set) var isExpensive: Bool = false
	public private(set) var connectionType: NWInterface.InterfaceType?

	private init() {
		monitor = NWPathMonitor()
	}

	public func startMonitoring() {
		print("startMonitoring")
		monitor.pathUpdateHandler = { [weak self] path in
			self?.isConnected = path.status != .unsatisfied
			self?.isExpensive = path.isExpensive
			self?.connectionType = NWInterface.InterfaceType.allCases.filter { path.usesInterfaceType($0) }.first
		}
		monitor.start(queue: queue)
	}

	public func stopMonitoring() {
		monitor.cancel()
	}
}

extension NWInterface.InterfaceType: CaseIterable {
	public static var allCases: [NWInterface.InterfaceType] = [
		.other,
		.wifi,
		.cellular,
		.loopback,
		.wiredEthernet
	]
}

extension Notification.Name {
	static let connectivityStatus = Notification.Name(rawValue: "connectivityStatusChanged")
}


@preconcurrency import MultipeerConnectivity
import Observation
import UIKit

@Observable
@MainActor
final class TelemetryBroadcaster: NSObject {

    private(set) var connectedPeerCount: Int = 0

    @ObservationIgnored private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    @ObservationIgnored private lazy var session: MCSession = {
        let s = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        s.delegate = self
        return s
    }()
    @ObservationIgnored private lazy var advertiser: MCNearbyServiceAdvertiser = {
        let a = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "minidrive-tele")
        a.delegate = self
        return a
    }()
    @ObservationIgnored private var broadcastTask: Task<Void, Never>?
    @ObservationIgnored private weak var locationService: LocationService?
    @ObservationIgnored private let encoder = JSONEncoder()

    func start(locationService: LocationService) {
        self.locationService = locationService
        advertiser.startAdvertisingPeer()
        startBroadcastLoop()
    }

    func stop() {
        broadcastTask?.cancel()
        broadcastTask = nil
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }

    private func startBroadcastLoop() {
        broadcastTask?.cancel()
        broadcastTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.sendTelemetry()
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    private func sendTelemetry() {
        guard !session.connectedPeers.isEmpty, let svc = locationService else { return }
        let model = TelemetryModel(
            speedKmh: svc.speedKmh,
            heading: svc.headingDegrees,
            altitude: svc.altitude,
            coordinate: svc.coordinate,
            timestamp: Date()
        )
        guard let data = try? encoder.encode(model) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

// MARK: - MCSessionDelegate

extension TelemetryBroadcaster: MCSessionDelegate {

    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor [weak self] in
            self?.connectedPeerCount = session.connectedPeers.count
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension TelemetryBroadcaster: MCNearbyServiceAdvertiserDelegate {

    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor [weak self] in
            guard let self else { invitationHandler(false, nil); return }
            invitationHandler(true, self.session)
        }
    }
}

@preconcurrency import MultipeerConnectivity
import Observation
import UIKit

@Observable
@MainActor
final class TelemetryReceiver: NSObject {

    private(set) var latestTelemetry: TelemetryModel?
    private(set) var isConnected: Bool = false

    @ObservationIgnored private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    @ObservationIgnored private lazy var session: MCSession = {
        let s = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        s.delegate = self
        return s
    }()
    @ObservationIgnored private lazy var browser: MCNearbyServiceBrowser = {
        let b = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "minidrive-tele")
        b.delegate = self
        return b
    }()
    @ObservationIgnored private let decoder = JSONDecoder()

    func start() {
        browser.startBrowsingForPeers()
    }

    func stop() {
        browser.stopBrowsingForPeers()
        session.disconnect()
        isConnected = false
    }
}

// MARK: - MCSessionDelegate

extension TelemetryReceiver: MCSessionDelegate {

    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor [weak self] in
            self?.isConnected = !session.connectedPeers.isEmpty
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.latestTelemetry = try? self.decoder.decode(TelemetryModel.self, from: data)
        }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceBrowserDelegate

extension TelemetryReceiver: MCNearbyServiceBrowserDelegate {

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

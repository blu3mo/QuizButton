//
//  SessionService.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2020/06/28.
//  Copyright © 2020 Shutaro Aoyama. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ConnectionServiceProtocol {
    var model: JudgeModelProtocol! { get set }
    func inject(model: JudgeModelProtocol)
    
    var peerId: MCPeerID! { get set }
    var mcSession: MCSession! { get set }

}

class MCService: NSObject, ConnectionServiceProtocol {
    
    var peerId: MCPeerID!
    var mcSession: MCSession!
    
    let serviceTypeId = "bluemoquiz"
    
    
    internal var model: JudgeModelProtocol!
    
    func inject(model: JudgeModelProtocol) {
        self.model = model
    }
    
    override init() {
        super.init()
        
        peerId = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    let dateStringFormat = "y-MM-dd H:m:ss.SSSS"
    
    func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

}

extension MCService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Debug用
        switch state {
        case .connected:
            print("connected: \(peerID.displayName)")
        case .connecting:
            print("connecting: \(peerID.displayName)")
        case .notConnected:
            print("not connected: \(peerID.displayName)")
            //self.state = .open
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decodedString = String(data: data, encoding: .utf8)
        
        var message: Message
        switch decodedString {
        case "youwin":
            message = .youWin
        default: //date
            let date = dateFromString(string: decodedString!, format: dateStringFormat)
            message = .triedDate(date)
        }
        
        model.reactMessage(message: message)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
}

extension MCService: JudgeModelConnectionOutput {
    
    var isConnected: Bool {
        get {
            return (mcSession.connectedPeers.count == 0)
        }
    }
    
    func sendMessage(message: Message) {
        var sendingString: String = ""
        
        switch message {
        case .youWin:
            sendingString = "youwin"
        case .triedDate(let date):
            sendingString = stringFromDate(date: date, format: dateStringFormat)
        }
            
        do {
            try mcSession.send(sendingString.data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("sending error") //TODO
        }
    }
    
    func advertise() {
        let mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: serviceTypeId, discoveryInfo: nil, session: self.mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func getBrowser() -> UIViewController {
        let mcBrowser = MCBrowserViewController(serviceType: serviceTypeId, session: mcSession)
        mcBrowser.delegate = self
        mcBrowser.maximumNumberOfPeers = 1
        mcBrowser.minimumNumberOfPeers = 1
        
        return mcBrowser
    }
}

extension MCService: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
}

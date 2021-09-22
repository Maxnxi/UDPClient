//
//  UdpListener.swift
//  wifiExample
//
//  Created by Maksim on 24.08.2021.
//
//https://developer.apple.com/forums/thread/662082?login=true
//https://stackoverflow.com/questions/54640996/how-to-work-with-udp-sockets-in-ios-swift?rq=1


import Foundation
import Network

protocol SocketUDPDelegate: AnyObject {
    func changeStateofSocket(state: StateOfSocket)
    func increasePacketNumber()
    func increaseErrorCounter()
}

class SocketUDP {
    
    weak var socketDelegate: SocketUDPDelegate?
    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = "192.168.4.1"
    var portUDP: NWEndpoint.Port = 9090
    
        
    init(message: String) {
        //Параметры - чтобы bind исходящий порт, не заработало
        let params = NWParameters(dtls: nil, udp: .init())
        params.requiredLocalEndpoint = NWEndpoint.hostPort(host: .ipv4(.any), port: 58787)
//        params.allowLocalEndpointReuse = true
//        params.allowFastOpen = true
//        self.connection = NWConnection(host: hostUDP, port: portUDP, using: params)
        connection = NWConnection(host: hostUDP, port: portUDP, using: params)
        connection?.stateUpdateHandler = { (newState) in
            print("This is stateUpdateHandler:")
            switch (newState) {
            case .ready:
                print("State: Ready\n")
                self.sendUDP(message: message)
                self.receiveUDP()
            case .setup:
                print("State: Setup\n")
            case .cancelled:
                print("State: Cancelled\n")
            case .preparing:
                print("State: Preparing\n")
            default:
                print("ERROR! State not defined!\n")
                self.connection?.forceCancel()
            }
        }
        connection?.start(queue: .global())
        print("SocketUDP inited")
        
    }
    
    deinit {
        closeSocket()
        print("socketUDP deinit")
    }
          
//    public func connectSendMessageReceiveAnswer(message: String) {
//        // Transmited message:
//        self.connection = NWConnection(host: hostUDP, port: portUDP, using: params)
//        self.connection.stateUpdateHandler = { (newState) in
//            print("This is stateUpdateHandler:")
//            switch (newState) {
//            case .ready:
//                print("State: Ready\n")
//                self.sendUDP(message: message)
//                self.receiveUDP()
//            case .setup:
//                print("State: Setup\n")
//            case .cancelled:
//                print("State: Cancelled\n")
//            case .preparing:
//                print("State: Preparing\n")
//            default:
//                print("ERROR! State not defined!\n")
//            }
//        }
//        self.connection.start(queue: .global())
//        
//    }

//  sub functions
    private func sendUDP(message: String) {
        guard let contentToSendUDP = message.hexadecimal else {
            print("Error in converting")
            return
        }
//  print("Data to send", contentToSendUDP as Any)
        connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed({ error in
            if error == nil {
                self.socketDelegate?.increasePacketNumber()
                print("Send succeded")
                self.socketDelegate?.changeStateofSocket(state: .pause)
            } else {
                print("Error while sending udp packet", error as Any)
                self.socketDelegate?.changeStateofSocket(state: .needToSendPreviousAgain)
            }
        })
        )
    }

          private func receiveUDP() {
            self.connection?.receiveMessage { [weak self] (data, context, isComplete, error) in
                if (isComplete) {
                    guard let stringHex = data?.hexadecimal else {
                        print("Error in receiveUDP")
                        return
                    }
                    print("Receive is complete", stringHex)
                    let dictionaryResult = DecodeLib.shared.parseBinAndReturnView(string: stringHex)
                    guard let resultStr = dictionaryResult["cmd"] as? String else {
                        print("Error in getting data from parsed in SocketUDP.receiveUDP")
                        return
                    }
                    
                    if resultStr == "ok" {
                        print("ReceiveUDP - ok")
                        self?.socketDelegate?.changeStateofSocket(state: .readyToSend)

                    }
/*
                     else if resultStr == "failed" {
                        print("ReceiveUDP - failed")
                        self?.socketDelegate?.changeStateofSocket(state: .needToSendPreviousAgain)
                        
                    } else if resultStr == "failedGuard" {
                        print("ReceiveUDP - failedGuard")
                        self?.socketDelegate?.changeStateofSocket(state: .needToSendPreviousAgain)

                    }
*/
                    else {
                        print("Else situation in receiveUDP")
                        self?.socketDelegate?.changeStateofSocket(state: .readyToSend)
                    }
                    
                    
                    
                } else if (isComplete == false && error != nil) {
                    self?.socketDelegate?.changeStateofSocket(state: .needToSendPreviousAgain)
                }
              }
          }
        
    public func closeSocket() {
        //connection.cancel()
        guard let tmpConnection = connection else {
            print("Error in closeSocket")
            return
        }
        tmpConnection.stateUpdateHandler = nil
        tmpConnection.viabilityUpdateHandler = nil
        tmpConnection.betterPathUpdateHandler = nil
        tmpConnection.pathUpdateHandler = nil
                if tmpConnection.state != .cancelled {
                    tmpConnection.cancel()
                }
            
    }
    
    func closeAllConnections() {
        connection?.forceCancel()
    }
    
}

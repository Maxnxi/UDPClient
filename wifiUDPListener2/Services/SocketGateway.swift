//
//  SocketGateway.swift
//  wifiUDPListener2
//
//  Created by Maksim on 12.09.2021.
//

import Foundation

public enum StateOfSocket {
    case readyToSend, pause, needToSendPreviousAgain, finish, finishWithError
}

class SocketGateway {
    
    //Pause Timer
    var pauseTimer = Timer()
    var countPauseSeconds: Double = 0.0 {
        didSet {
            print("Pause Timer: ", countPauseSeconds)
            if countPauseSeconds == 0.75 {
                stopPauseSendAgain()
            }
        }
    }
    
    //Counter of main loops // количество полных повторных загрузок = 1
    var inceptionCounter: Int = 0 {
        didSet {
            print("inceptionCounter didSet: ", inceptionCounter)
            if inceptionCounter == 2 {
                currentState = .finishWithError
            }
        }
    }
    
    //счетчик ошибок
    let errorLimits: Int = 3    // предельный лимит ошибок (произвольно)
    var errorCounter: Int = 0 {
        didSet {
            print("Error counter didSet: ", errorCounter)
            if errorCounter == errorLimits{
                startInceptionAgain()
            }
        }
    }
    //номер пакета для отправки (из массива)
    var numberOfPacket: Int = 0
    var packets: [Data] = [Data]()
    
    //Сокет
    let socket: SocketUDP = SocketUDP()
    
    //статус сокета
    var currentState: StateOfSocket? {
        didSet {
            pauseTimer.invalidate()
            print("Change status", currentState as Any)
            //pauseTimer.invalidate()
            
            if currentState == .readyToSend {
                //isPaused = false
                if numberOfPacket == packets.count {
                    finishState()
                } else {
                    print("Ready To send")
                    send(nmbrPckt: numberOfPacket)
                }
            } else if currentState == .needToSendPreviousAgain {
                //isPaused = false
                print("Send Again Previous")
                numberOfPacket -= 1
                errorCounter += 1
                send(nmbrPckt: numberOfPacket)
            } else if currentState == .pause {
                pauseFunc()
            } else if currentState == .finish {
                finish()
            } else if currentState == .finishWithError {
                finishWithError()
            }
        }
    }
    
    //main
    init(messageArr: [String]) {
        self.packets = [Data]()
        for str in messageArr {
            guard let binData = str.hexadecimal else {return}
            self.packets.append(binData)
        }
        socket.socketDelegate = self
    }
 
    init(packets: [[UInt8]]) {
        
        self.packets = [Data]()
        for packet in packets {
            self.packets.append(Data(packet))
        }
        socket.socketDelegate = self
    }

    deinit {
        print("Object SocketGateway deinit")
    }
        
    public func startSend() {
        currentState = .readyToSend
    }
    
    func send(nmbrPckt: Int) {
        if errorCounter == errorLimits {
            currentState = .finishWithError
        }
        socket.connectSendMessageReceiveAnswer(message: self.packets[nmbrPckt])
    }
    
    func pauseFunc() {
        //isPaused = true
        print("Pause")
        startPauseTimer()
    }
    
    func stopPauseSendAgain() {
        currentState = .needToSendPreviousAgain
        errorCounter += 1
        //isPaused = false
        //pauseTimer.invalidate()
    }
    
    func finishState() {
        currentState = .finish
    }
    
    func finish() {
        print("Finished sending Packs")
        //socket?.closeSocket()
        
        //scket.closeSocket()
    }
    
    func finishWithError() {
        print("!!! Attention !!! Finish with error")
        //socket?.closeSocket()
    }
    
//только один раз
    func startInceptionAgain() {
        errorCounter = 0
        inceptionCounter += 1
    }
    

    
}

extension SocketGateway: SocketUDPDelegate {
    func increaseErrorCounter() {
        print("Delegate works increaseErrorCounter")
        self.errorCounter += 1
    }
    
    func changeStateofSocket(state: StateOfSocket) {
        print("Delegate works changeStateofSocket")
        self.currentState = state
    }
    
    func increasePacketNumber() {
        print("Delegate works increasePacketNumber")
        self.numberOfPacket += 1
    }
    
}

extension SocketGateway {
    func startPauseTimer() {
        //pauseTimer.invalidate()
        //countPauseSeconds = 0.0
        print(#function)
        //version #3
        var countPeriods = 0.0
        pauseTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            countPeriods += 0.25
            if countPeriods >= 0.75 {
                timer.invalidate()
            }
        }
    }
}

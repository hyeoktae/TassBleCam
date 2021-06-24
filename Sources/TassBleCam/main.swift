import SwiftyGPIO //Remove this import if you are compiling manually with switfc
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import Foundation


let uarts = SwiftyGPIO.UARTs(for: .RaspberryPiPlusZero)
//var uart = uarts[0]

guard let uart = uarts?.first
else {
  exit(0)
}

uart.configureInterface(speed: .S9600, bitsPerChar: .Eight, stopBits: .One, parity: .None)

print("Ready...")

if #available(macOS 10.12, *) {
  let tRead = Thread() {
    while true {
      let s = uart.readString()
      print("Echo: "+s, terminator: "")
    }
  }
  
  
  tRead.start()
  
  var exit = false
  
  while (!exit) {
    //  let readText = uart.readString()
    //
    //  if readText.contains("exit") {
    //    exit = true
    //    break
    //  }
    
    print("Send: ", terminator: " ")
    var input = readLine(strippingNewline: false)
    exit = (input == "exit\n")
    
    if !exit {
      uart.writeString(input ?? "inputErr")
    }
    
  }
}


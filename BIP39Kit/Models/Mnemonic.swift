//
//  Mnemonic.swift
//  BIP39Kit
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation
import Crypto
import CommonCrypto

public enum MnemonicError: Error {
  case generate(String)
}

public struct Mnemonic {
  
  public let words: [String]
  
  public var formatted: String {
    return words.joined(separator: " ")
  }
  
  public init(locale: Locale = Locale.current) throws {
    try self.init(strength: 256, locale: locale)
  }
  
  public init(words: String) {
    self.words = words.components(separatedBy: " ")
  }
  
  public init(words: [String]) {
    self.words = words
  }
  
  init(entropy: String, locale: Locale = Locale.current) throws {
    guard let bytes = entropy.hexadecimal() else {
      throw MnemonicError.generate("Invalid entropic string")
    }
    
    self = try Mnemonic.generate(entropy: bytes)
  }
  
  init(strength: UInt = 128, rng: RandomNumberGenerator.Type = SecureRandomNumberGenerator.self, locale: Locale = Locale.current) throws {
    self = try Mnemonic.generate(strength: strength, rng: rng, locale: locale)
  }
  
  func salt(password: String? = nil) -> String {
    let pw = password ?? ""
    return "mnemonic\(pw)"
  }
  
  private func seed() -> Data {
    let str = self.formatted.precomposedStringWithCompatibilityMapping
    let slt = salt().precomposedStringWithCompatibilityMapping.data(using: .utf8) ?? Data()
    let data = str.pbkdf2SHA512(salt: slt, keyByteCount: 64, rounds: 2048)
    return data!
  }
  
  private func seedHex() -> String {
    return seed().hexEncodedString()
  }
  
}

extension Mnemonic {
  
  static func generate(strength: UInt = 128,
                       rng: RandomNumberGenerator.Type = SecureRandomNumberGenerator.self,
                       locale: Locale = Locale.current) throws -> Mnemonic {
    
    guard strength % 32 == 0 else {
      throw MnemonicError.generate("Incorrect strength")
    }
    guard let bytes = rng.generate(length: Int(strength / 8)) else {
      throw MnemonicError.generate("Could not generate a random number")
    }
    guard bytes.count == strength / 8 else {
      throw MnemonicError.generate("Not enough bytes in the random number")
    }
    
    return try generate(entropy: bytes)
  }
  
  static func generate(entropy bytes: Data, locale: Locale = Locale.current) throws -> Mnemonic {
    let wordlist = WordList(locale: locale)
    let bits = Binary(data: bytes)
    let checksum = deriveChecksumBits(buffer: bytes)
    let total = Binary(bytes: bits.bytes + checksum.bytes)
    let numChunks = total.bytes.count * 8 / 11
    let chunks = (0 ..< numChunks).flatMap { (index) -> Int? in
      let start = index * 11
      let endIndex = start + 11
      let size = total.bytes.count * 8
      let end = endIndex > size ? size : endIndex
      return total.bits(start ..< end)
      }

    let words = try wordlist.words(at: chunks)
    return Mnemonic(words: words)
  }
  
  static func deriveChecksumBits(buffer: Data) -> Binary {
    let ent = buffer.count * 8
    let cs = ent / 32
    let hash = buffer.sha256
    let bin = Binary(data: hash)
    let bits = bin.bits(0 ..< cs)
    let shift = 8 - cs
    return Binary(bytes: [UInt8(bits << shift)])
  }
}

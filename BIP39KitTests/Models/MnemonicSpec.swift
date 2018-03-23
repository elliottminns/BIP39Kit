//
//  MnemonicTest.swift
//  BIP39KitTests
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Quick
import Nimble
@testable import BIP39Kit

struct ProxyGenerate: RandomNumberGenerator {
  static func generate(length: Int) -> Data? {
    return "qwertyuiopasdfghjklzxcvbnm[];,./".data(using: .utf8)![0 ..< length]
  }
}

class MnemonicSpec: QuickSpec {

  override func spec() {
    describe("running with english locale") {
      let locale = Locale(identifier: "en-US")
      var mnemonic: Mnemonic?
      beforeEach {
        mnemonic = try? Mnemonic(entropy: "ffffffffffffffffffffffffffffffff", locale: locale)
      }
      
      it("should have the correct words") {
        expect(mnemonic?.words.joined(separator: " ")) == "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong"
      }
    }
    
    describe("with a byte generator") {
      let locale = Locale(identifier: "en-US")
      var mnemonic: Mnemonic?
      
      beforeEach {
        mnemonic = try? Mnemonic(rng: ProxyGenerate.self, locale: locale)
      }
      
      it("should create the correct mnemonic") {
        expect(mnemonic?.words.joined(separator: " ")) ==
          "imitate robot frame trophy nuclear regret saddle around inflict case oil spice"
      }
    }
    
    describe("created with words") {
      let phrase = "basket actual"
      let mnemonic = Mnemonic(words: phrase)
      
      it("should have the correct seed") {
        let hex = mnemonic.seedHex()
        expect(hex) == "5cf2d4a8b0355e90295bdfc565a022a409af063d5365bb57bf74d9528f494bfa4400f53d8349b80fdae44082d7f9541e1dba2b003bcfec9d0d53781ca676651f"
      }
    }
  }

}

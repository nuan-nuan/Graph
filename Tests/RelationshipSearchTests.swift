/*
* Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>. 
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*	*	Redistributions of source code must retain the above copyright notice, this
*		list of conditions and the following disclaimer.
*
*	*	Redistributions in binary form must reproduce the above copyright notice,
*		this list of conditions and the following disclaimer in the documentation
*		and/or other materials provided with the distribution.
*
*	*	Neither the name of Graph nor the names of its
*		contributors may be used to endorse or promote products derived from
*		this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import XCTest
@testable import Graph

class RelationshipSearchTests : XCTestCase, GraphDelegate {
	var graph: Graph!
	
	override func setUp() {
		super.setUp()
		graph = Graph()
	}
	
	override func tearDown() {
		graph = nil
		super.tearDown()
	}
	
	func testAll() {
		graph.clear()
		
		for i in 0..<100 {
			let n: Relationship = Relationship(type: "T1")
			n.subject = Entity(type: "S1")
			n.object = Entity(type: "O1")
			n["P1"] = 0 == i % 2 ? "V1" : 1
			n["P2"] = "V2"
			n.addGroup("G1")
			n.addGroup("G2")
		}
		
		for _ in 0..<200 {
			let n: Relationship = Relationship(type: "T2")
			n.subject = Entity(type: "S2")
			n.object = Entity(type: "O2")
			n["P2"] = "V2"
			n.addGroup("G2")
		}
		
		for _ in 0..<300 {
			let n: Relationship = Relationship(type: "T3")
			n.subject = Entity(type: "S3")
			n.object = Entity(type: "O3")
			n["P3"] = "V3"
			n.addGroup("G3")
		}
		
		graph.save { (success: Bool, error: NSError?) in
			XCTAssertTrue(success, "Cannot save the Graph: \(error)")
		}
		
		XCTAssertEqual(0, graph.searchForRelationship().count)
		
		XCTAssertEqual(100, graph.searchForRelationship(types: ["T1"]).count)
		XCTAssertEqual(300, graph.searchForRelationship(types: ["T1", "T2"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1", "T2", "T3"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["*"]).count)
		
		XCTAssertEqual(0, graph.searchForRelationship(groups: ["NONE"]).count)
		XCTAssertEqual(100, graph.searchForRelationship(groups: ["G1"]).count)
		XCTAssertEqual(300, graph.searchForRelationship(groups: ["G1", "G2"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(groups: ["G1", "G2", "G3"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(groups: ["*"]).count)
		
		XCTAssertEqual(100, graph.searchForRelationship(types: ["T1"], groups: ["G1"]).count)
		XCTAssertEqual(300, graph.searchForRelationship(types: ["T1"], groups: ["G1", "G2"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1"], groups: ["G1", "G2", "G3"]).count)
		XCTAssertEqual(300, graph.searchForRelationship(types: ["T1", "T2"], groups: ["G1"]).count)
		XCTAssertEqual(300, graph.searchForRelationship(types: ["T1", "T2"], groups: ["G1", "G2"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1", "T2"], groups: ["G1", "G2", "G3"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1", "T2", "T3"], groups: ["G1"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1", "T2", "T3"], groups: ["G1", "G2"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1", "T2", "T3"], groups: ["G1", "G2", "G3"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["*"], groups: ["G1"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["*"], groups: ["G1", "G2"]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["*"], groups: ["G1", "G2", "G3"]).count)
		
		XCTAssertEqual(100, graph.searchForRelationship(properties: [("P1", nil)]).count)
		XCTAssertEqual(50, graph.searchForRelationship(properties: [("P1", "V1")]).count)
		XCTAssertEqual(50, graph.searchForRelationship(properties: [("P1", 1)]).count)
		XCTAssertEqual(50, graph.searchForRelationship(properties: [("*", "V1")]).count)
		XCTAssertEqual(50, graph.searchForRelationship(properties: [("*", 1)]).count)
		XCTAssertEqual(100, graph.searchForRelationship(properties: [("P1", "V1"), ("P1", 1)]).count)
		XCTAssertEqual(300, graph.searchForRelationship(properties: [("P1", nil), ("P2", "V2")]).count)
		XCTAssertEqual(600, graph.searchForRelationship(properties: [("P1", nil), ("P2", "V2"), ("P3", "V3")]).count)
		XCTAssertEqual(600, graph.searchForRelationship(properties: [("P1", nil), ("P2", nil), ("P3", nil)]).count)
		XCTAssertEqual(600, graph.searchForRelationship(properties: [("*", nil)]).count)
		
		XCTAssertEqual(300, graph.searchForRelationship(types: ["T1"], properties: [("P1", nil), ("P2", nil)]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["T1"], groups: ["G3"], properties: [("P1", nil), ("P2", nil)]).count)
		XCTAssertEqual(600, graph.searchForRelationship(types: ["*"], groups: ["*"], properties: [("*", nil)]).count)
	}
	
	func testPerformance() {
		self.measureBlock() {}
	}
}

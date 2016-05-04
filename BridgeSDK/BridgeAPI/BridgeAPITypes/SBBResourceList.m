//
//  SBBResourceList.m
//
//	Copyright (c) 2014, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBResourceList.h"

@implementation SBBResourceList

#pragma mark Abstract method overrides

// Custom logic goes here.

#pragma mark Keep "total" field in sync with actual count of items
- (void)addItemsObject:(SBBBridgeObject*)value_
{
    [super addItemsObject:value_];
    self.totalValue = self.items.count;
}

- (void)removeItemsObjects
{
    [super removeItemsObjects];
    self.totalValue = self.items.count;
}

- (void)removeItemsObject:(SBBBridgeObject*)value_
{
    [super removeItemsObject:value_];
    self.totalValue = self.items.count;
}

- (void)insertObject:(SBBBridgeObject*)value inItemsAtIndex:(NSUInteger)idx {
    [super insertObject:value inItemsAtIndex:idx];
    self.totalValue = self.items.count;
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx {
    [super removeObjectFromItemsAtIndex:idx];
    self.totalValue = self.items.count;
}

- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [super insertItems:value atIndexes:indexes];
    self.totalValue = self.items.count;
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [super removeItemsAtIndexes:indexes];
    self.totalValue = self.items.count;
}

- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(SBBBridgeObject*)value {
    [super replaceObjectInItemsAtIndex:idx withObject:value];
    self.totalValue = self.items.count;
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)value {
    [super replaceItemsAtIndexes:indexes withItems:value];
    self.totalValue = self.items.count;
}

@end

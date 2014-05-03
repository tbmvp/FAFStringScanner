//
//  FAFStringScanner.m
//  oas-compile
//
//  Created by Manoah F Adams on 2013-06-28.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FAFStringScanner.h"


@implementation FAFStringScanner


- (id) initWithString:(NSString*)input {
	self = [super init];
	if (self != nil) {
		_string = [input retain];
		//NSLog(_string);
		_scanLoc = 0;
		_maxLoc = [_string length] - 1;
		_lastFind = NSMakeRange(0,0);
		alphaNums = [[@"a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 _ @" componentsSeparatedByString:@" "] retain];
		whiteSpaces = [[@" ,\t,\n" componentsSeparatedByString:@","] retain];
	}
	return self;
}

- (void) dealloc {
	[_string release];
	[alphaNums release];
	[whiteSpaces release];
	[super dealloc];
}


- (int) scanLocation {
	return _scanLoc;
}
- (void) setScanLocation:(int)loc {
	_scanLoc = loc;
}

- (void) advance:(int) count
{
	_scanLoc = _scanLoc + count;
	if (_scanLoc > _maxLoc)
	{
		_scanLoc = _maxLoc;
	}
	if (_scanLoc < 0)
	{
		_scanLoc = 0;
	}
	
}


- (BOOL) isAtEnd
{
	if (_scanLoc >= _maxLoc) return YES;
	return NO;
}



- (NSString*) readUntilString:(NSString*)findString {
	NSString* temp;
	return [self readUntilStrings:[NSArray arrayWithObject:findString] matchString:&temp];
}


- (NSRange) _findString:(NSString*)aString {
	if ([self isAtEnd]) return NSMakeRange(_maxLoc, 0);
	
	NSRange searchRange = NSMakeRange(_scanLoc, (_maxLoc-_scanLoc+1)); // +1 to include last char

	NSRange foundRange = [_string rangeOfString:aString options:NSLiteralSearch range:searchRange];

	return foundRange;
}

- (NSString*) readUntilStrings:(NSArray*)findStrings matchString:(NSString* *)string {
	
	NSEnumerator* enumerator = [findStrings objectEnumerator];
	NSString* findString;
	NSString* foundString = nil;
	NSString* readResult = nil;
	int firstFindLocation = _maxLoc;
	NSRange lastRange = NSMakeRange(_maxLoc, 0);
	NSRange bestRange = NSMakeRange(_maxLoc, 0);

	while (findString = [enumerator nextObject]) {
		lastRange = [self _findString:findString];
		if (lastRange.location != NSNotFound) {
			
			if (lastRange.location < firstFindLocation) {
				firstFindLocation = lastRange.location;
				bestRange = lastRange;
				foundString = findString;
			}
			
		}
	}
	if (firstFindLocation != _maxLoc) {
		_lastFind = bestRange;
		readResult = [_string substringWithRange:NSMakeRange(_scanLoc, (bestRange.location-_scanLoc))];
		*string = foundString;
		return readResult;
	}
	// none of the strings found, so read remainder
	readResult = [self readRemainder];
	*string = @"";
	
	return readResult;
}



- (NSString*) readUntilStringAdvancingTo:(NSString*)findString {
	NSString* result = [self readUntilString:findString];
	[self setScanLocation:_lastFind.location];
	return result;
}
- (NSString*) readUntilStringAdvancingPast:(NSString*)findString {
	NSString* result = [self readUntilString:findString];
	[self setScanLocation:(_lastFind.location + _lastFind.length)];
	return result;
}

- (NSString*) readUntilStringsAdvancingTo:(NSArray*)findStrings matchString:(NSString* *)string {
	NSString* result = [self readUntilStrings:findStrings matchString:string];
	[self setScanLocation:_lastFind.location];
	return result;
}

- (NSString*) readUntilStringsAdvancingPast:(NSArray*)findStrings matchString:(NSString* *)string {
	NSString* result = [self readUntilStrings:findStrings matchString:string];
	[self setScanLocation:(_lastFind.location + _lastFind.length)];
	return result;
}



- (NSString*) readRemainder {
	
	_lastFind = NSMakeRange(_scanLoc, (_maxLoc - _scanLoc + 1));
	return [_string substringWithRange:_lastFind];
}


- (NSString*) prevCharacter {
	if ((_scanLoc - 2) < 0) return nil;
	_lastFind = NSMakeRange((_scanLoc - 2), 1);
	return [_string substringWithRange:_lastFind];
}

- (NSString*) currentCharacter {
	if ((_scanLoc - 1) < 0) return nil;
	_lastFind = NSMakeRange((_scanLoc - 1), 1);
	return [_string substringWithRange:_lastFind];
}

- (NSString*) nextCharacter {
	if (_scanLoc > _maxLoc) return nil;
	_lastFind = NSMakeRange(_scanLoc, 1);
	return [_string substringWithRange:_lastFind];
}

- (NSString*) readCharacter {
	//if ([self isAtEnd]) return nil;
	if (_scanLoc > _maxLoc) return nil;
	_lastFind = NSMakeRange(_scanLoc, 1);
	[self advance:1];
	return [_string substringWithRange:_lastFind];
}


- (NSString*) readBalanced {
	//[self advance: -1];
	NSMutableArray* chars = [NSMutableArray new];
	int parenCount = 0;
	int bracketCount = 0;
	int braceCount = 0;
	BOOL inQuote = NO;
	
	NSString* targetChar = [self nextCharacter]; // Paren, Bracket, Brace, Quote
	if ([targetChar isEqual: @"("]) {
		targetChar = @")";
	} else if ([targetChar isEqual: @"["]) {
		targetChar = @"]";
	} else if ([targetChar isEqual: @"{"]) {
		targetChar = @"}";
	} else if ([targetChar isEqual: @"\""]) {
		targetChar = @"\"";
	} else {
		return nil;
	}
	//NSLog(@"targetChar: %@", targetChar);
	
	NSString* currentChar;
	while (currentChar = [self readCharacter]) {
		[chars addObject:currentChar];
		//NSLog(currentChar);
		//NSLog(@"prevChar: %@", [self prevCharacter]);
		//NSLog(@"inQuote: %i", inQuote);
		if (inQuote) {
			// ignore prens, brackets and braces
			if ([currentChar isEqual: @"\""] && (![[self prevCharacter] isEqual: @"\\"])) {
				// reached end of quote
				inQuote = NO;
				if ([currentChar isEqual: targetChar]) {
					return [chars componentsJoinedByString:@""];
				}
			}
		} else if ([currentChar isEqual: @"\""]) {
			inQuote = YES;
		} else {
			if ([currentChar isEqual: @"("]) {
				parenCount = parenCount + 1;
			} else if ([currentChar isEqual: @"["]) {
				bracketCount = bracketCount + 1;
			} else if ([currentChar isEqual: @"{"]) {
				braceCount = braceCount + 1;
			} else if ([currentChar isEqual: @")"]) {
				parenCount = parenCount - 1;
			} else if ([currentChar isEqual: @"]"]) {
				bracketCount = bracketCount - 1;
			} else if ([currentChar isEqual: @"}"]) {
				braceCount = braceCount - 1;
			}
			int targetCharCount;
			if ([targetChar isEqual: @")"]) {
				targetCharCount = parenCount;
			} else if ([targetChar isEqual: @"]"]) {
				targetCharCount = bracketCount;
			} else if ([targetChar isEqual: @"}"]) {
				targetCharCount = braceCount;
			}
			//NSLog(@"targetCharCount: %i", targetCharCount);
			
			if ([currentChar isEqual: targetChar] && (targetCharCount <= 0)) {
				return [chars componentsJoinedByString:@""];
			}

		}
	}
	
	return [chars componentsJoinedByString:@""];
}

- (NSString*) nextToken {
	int startLoc = _scanLoc;
	NSString* token = [self readToken];
	[self setScanLocation:startLoc];
	return token;
}


- (NSString*) readToken {
	
	NSMutableString* scanText = [NSMutableString stringWithString:@""];
	BOOL started = NO;
	//BOOL finished = NO;
	NSString* currentChar = nil;
	while ((currentChar = [self readCharacter]) && (! [self isAtEnd])) {
		//NSLog(@"currentChar: %@", currentChar);
		if ([alphaNums containsObject:currentChar]) {
			[scanText appendString:currentChar];
			started = YES;
		} else if([whiteSpaces containsObject:currentChar]) {
			if (started) break;
		} else {
			if (started) {
				break;
			} else {
				return currentChar;
			}
		}
	}
	if ( ! [self isAtEnd] ) {
		[self advance: -1]; // compensate for above readCharacter;
	} else {
		//[scanText appendString:[self readCharacter]];

	//	return currentChar;
	}
	if ([scanText isEqual:@""]) return nil;
	return scanText;
}

- (NSArray*) readTokensBalanced {
	NSMutableArray* output = [NSMutableArray new];
	
	int parenCount = 0;
	int bracketCount = 0;
	int braceCount = 0;
	
	NSString* targetChar = [self nextToken]; // Paren, Bracket, Brace, Quote
	if ([targetChar isEqual: @"("]) {
		targetChar = @")";
	} else if ([targetChar isEqual: @"["]) {
		targetChar = @"]";
	} else if ([targetChar isEqual: @"{"]) {
		targetChar = @"}";
	} else {
		return nil;
	}
	
	NSString* token = nil;
	while (token = [self readToken]) {
		[output addObject:token];

		if ([token isEqual: @"("]) {
			parenCount = parenCount + 1;
		} else if ([token isEqual: @"["]) {
			bracketCount = bracketCount + 1;
		} else if ([token isEqual: @"{"]) {
			braceCount = braceCount + 1;
		} else if ([token isEqual: @")"]) {
			parenCount = parenCount - 1;
		} else if ([token isEqual: @"]"]) {
			bracketCount = bracketCount - 1;
		} else if ([token isEqual: @"}"]) {
			braceCount = braceCount - 1;
		}
		int targetCharCount;
		if ([token isEqual: @")"]) {
			targetCharCount = parenCount;
		} else if ([token isEqual: @"]"]) {
			targetCharCount = bracketCount;
		} else if ([token isEqual: @"}"]) {
			targetCharCount = braceCount;
		}
		
		if ([token isEqual: targetChar] && (targetCharCount <= 0)) {
			return output;
		}
			
		
	}
	
	return output;
}



@end
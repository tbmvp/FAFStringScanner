//
//  FAFStringScanner.h
//  oas-compile
//
//  Created by Manoah F Adams on 2013-06-28.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAFStringScanner : NSObject
{
	NSString*	_string;
	int			_scanLoc;
	int			_maxLoc;
	NSRange		_lastFind;
	
	BOOL		shouldTokenizeQuotedStrings;

	NSArray*	alphaNums;
	NSArray*	whiteSpaces;
}


- (id) initWithString:(NSString*)input;

- (int) scanLocation;
- (void) setScanLocation:(int)loc;

/*!
\brief	advances the location cursor by the amount specified. Negative values indicate retreat.
 */
- (void) advance:(int) count;

/*!
\brief	Returns YES if the cursor is past the last character.
 */
- (BOOL) isAtEnd;

- (NSString*) readUntilString:(NSString*)findString;
- (NSString*) readUntilStringAdvancingTo:(NSString*)findString;
- (NSString*) readUntilStringAdvancingPast:(NSString*)findString;

- (NSRange) _findString:(NSString*)aString;
- (NSString*) readUntilStrings:(NSArray*)findStrings matchString:(NSString* *)string;
- (NSString*) readUntilStringsAdvancingTo:(NSArray*)findStrings matchString:(NSString* *)string;
- (NSString*) readUntilStringsAdvancingPast:(NSArray*)findStrings matchString:(NSString* *)string;

/*!
\brief	Returns a string equal to the span from the current posisiton to the end of the input string.
 */
- (NSString*) readRemainder;

- (NSArray*) readRemainingTokens;


/*!
\brief	returns the previous character, without moving.
 */
- (NSString*) prevCharacter;

/*!
\brief	returns the current character, without advancing.
 */
- (NSString*) nextCharacter;

/*!
\brief	returns the current character, and advances by 1.
 */
- (NSString*) readCharacter;

/*!
\brief Checks the next character for a parenthesis, brace, bracket, or quote, and reads until the corresponding closure.
 
 This method will not be confused by intervening balanced segments.
 If the next character is not a parenthesis, brace, bracket or quote, behaviour is undefined.
 Any brace, bracket, or parenthesis inside a quote will be ignored, whether or not it is balanced.
 Nested quotes are not supported.
 */
- (NSString*) readBalanced;

/*!
\brief	if YES when reading tokens, then if next token is a quote, will read balanced instead. Defaults to YES.
 */
- (void) setShouldTokenizeQuotedStrings: (BOOL) flag;

/*!
\brief	returns the next token, without advancing the cursor.
 */
- (NSString*) nextToken;

/*!
\brief	returns the next token, and advances the cursor to after the token.
 */
- (NSString*) readToken;

- (NSArray*) readTokensBalanced;

- (unsigned) lineCount;

@end

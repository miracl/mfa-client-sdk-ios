#include "CvXcode.h"

using namespace std;

namespace CvShared
{

static const string base64_chars = 
             "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             "abcdefghijklmnopqrstuvwxyz"
             "0123456789+/";

static inline bool IsBase64(unsigned char c)
{
	return (isalnum(c) || (c == '+') || (c == '/'));
}

void CvBase64::Encode( const uint8_t* apBytesToEncode, int aLen, OUT std::string& aTarget )
{
	int i = 0;
	unsigned char char_array_3[3];
	unsigned char char_array_4[4];

	aTarget.clear();
	
	while( aLen-- )
	{
		char_array_3[i++] = *(apBytesToEncode++);
		if( i == 3 )
		{
			char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
			char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
			char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
			char_array_4[3] = char_array_3[2] & 0x3f;

			for( i = 0; i < 4; i++ )
				aTarget += base64_chars[char_array_4[i]];
			
			i = 0;
		}
	}

	if( i )
	{
		int j = 0;
		
		for( j = i; j < 3; j++ )
			char_array_3[j] = '\0';

		char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
		char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
		char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
		char_array_4[3] = char_array_3[2] & 0x3f;

		for( j = 0; j < i + 1; j++ )
			aTarget += base64_chars[char_array_4[j]];

		while( i++ < 3 )
			aTarget += '=';
	}
}

void CvBase64::Decode( const string& aSource, OUT string& aTarget )
{
	int in_len = (int)aSource.size();
	int i = 0;
	int in_ = 0;
	unsigned char char_array_4[4], char_array_3[3];

	aTarget.clear();
	
	while( in_len-- && aSource[in_] != '=' && IsBase64(aSource[in_]) )
	{
		char_array_4[i++] = aSource[in_];
		in_++;
		if( i == 4 )
		{
			for( i = 0; i < 4; i++ )
				char_array_4[i] = (unsigned char)base64_chars.find(char_array_4[i]);

			char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
			char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
			char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

			for( i = 0; i < 3; i++ )
				aTarget += char_array_3[i];
			
			i = 0;
		}
	}

	if( i )
	{
		int j = 0;
		
		for( j = i; j < 4; j++ )
			char_array_4[j] = 0;

		for( j = 0; j < 4; j++ )
			char_array_4[j] = (unsigned char)base64_chars.find(char_array_4[j]);

		char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
		char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
		char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

		for( j = 0; j < i - 1; j++ )
			aTarget += char_array_3[j];
	}
}

static const char* hex_chars = "0123456789abcdef";

void CvHex::Encode( const uint8_t* apBytesToEncode, int aLen, OUT string& aTarget )
{
	aTarget.clear();

	for ( int i = 0; i < aLen; i++ )
	{
		char c1 = hex_chars[ apBytesToEncode[i] >> 4 ];		// High nibble
		char c2 = hex_chars[ apBytesToEncode[i] & 0x0F ];	// Low nibble	

		aTarget += c1;
		aTarget += c2;		
	}
}

void CvHex::Decode( const string& aSource, OUT string& aTarget )
{
	aTarget.resize( aSource.length()/2 );
	
	for ( size_t i = 0; i < aSource.length(); ++i )
	{
		// High nibble		
		char c = tolower( aSource[i] );
		uint8_t nibble = 0;
		
		switch( c )
		{
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				nibble = c - '0';
				break;
			case 'a':
			case 'b':
			case 'c':
			case 'd':
			case 'e':
			case 'f':
				nibble = c - 'a' + 0xA;
				break;
		}

		if ( i%2 == 0 )
			aTarget[i/2] = ( nibble << 4 );
		else
			aTarget[i/2] |= nibble;
	}
}

}

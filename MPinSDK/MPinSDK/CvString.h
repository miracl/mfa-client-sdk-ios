#ifndef CVSTRING_H
#define	CVSTRING_H

#include "CvCommon.h"

#include <string>
#include <vector>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
	#define STRCASECMP	_stricmp
	#define STRNCASECMP	_strnicmp
	#define SPRINTF		sprintf_s
#else
	#define STRCASECMP	strcasecmp
	#define STRNCASECMP	strncasecmp
	#define SPRINTF		sprintf
#endif

class CvString : public std::string
{
public:
	typedef std::string				String;
	typedef std::vector<CvString>	CStringVector;
	
	CvString()	{}
	CvString( const String& aString ) : String(aString)	{}
	CvString( const char* apString ) : String(apString)	{}
	CvString( const CvString& aString ) : String(aString)	{}
	CvString( const String& aString, size_t aPos, size_t aSize = npos ) : String(aString,aPos,aSize)	{}
	CvString( const char* apString, size_t aSize ) : String(apString,aSize)	{}
	CvString( size_t aSize, char aChar ) : String(aSize,aChar)	{}
	
	CvString( uint32_t aUint )	{ *this = aUint; }
	CvString( long aInt )	{ *this = aInt; }
	
	CvString&	Format( const char* apFormat, ... );
	CvString&	TrimLeft( const String& aChars = " \t\f\v\n\r" );
	CvString&	TrimRight( const String& aChars = " \t\f\v\n\r" );
	int			ReplaceAll( const String& aPattern, const String& aReplacement );
	void		Tokenize( const String& aDelimiters, OUT CStringVector& aTokens ) const;
	
	inline long		Long( int aBase = 10 ) const;
	inline uint32_t	Ulong( int aBase = 10 ) const;
	
	inline int		CompareNoCase( const String& aOther ) const;
	inline int		CompareNoCase( const String& aOther, size_t n ) const;
	
	inline CvString&	operator=( uint32_t aUint );
	inline CvString&	operator=( long aInt );
	
private:

};

long CvString::Long( int aBase ) const
{
	char* pEnd;
	return strtol( c_str(), &pEnd, aBase );
}

uint32_t CvString::Ulong( int aBase ) const
{
	char* pEnd;
	return (uint32_t)strtoul( c_str(), &pEnd, aBase );
}

int CvString::CompareNoCase( const String& aOther ) const
{
	return STRCASECMP( c_str(), aOther.c_str() );
}

int CvString::CompareNoCase( const String& aOther, size_t n ) const
{
	return STRNCASECMP( c_str(), aOther.c_str(), n );	
}
	
CvString& CvString::operator=( uint32_t aUint )
{
	char str[16];
	SPRINTF( str, "%u", aUint );
	*this = str;
    
    return *this;
}

CvString& CvString::operator=( long aInt )
{
	char str[16];
	SPRINTF( str, "%ld", aInt );
	*this = str;
    
    return *this;
}

std::wstring StringToWstring( const std::string& str );
std::string WstringToString( const std::wstring& str );

#endif


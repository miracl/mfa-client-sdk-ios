#include "CvString.h"

#include <stdarg.h>

#ifdef _WIN32
	#include <windows.h>
#endif

CvString& CvString::Format( const char* apFormat, ... )
{
#ifdef _WIN32

	va_list args;
	va_start( args, apFormat );

	int len = _vscprintf( apFormat, args );

	reserve(len+1);
	resize(len);

	vsnprintf_s( (char*)data(), len+1, _TRUNCATE, apFormat, args );

	va_end( args );

#elif defined (__MACH__) || defined(ANDROID)
    
    char* pFormattedStr = NULL;
    
	va_list args;
	va_start( args, apFormat );

    vasprintf( &pFormattedStr, apFormat, args );
    
    va_end( args );
    
	*this = pFormattedStr;
    
    free( pFormattedStr );
    
#else	//linux

	char* pFormattedStr = NULL;
	size_t pFormattedSize = 0;

	FILE* pFormattedFd = open_memstream( &pFormattedStr, &pFormattedSize );
	if ( pFormattedFd != NULL )
	{
		va_list args;
		va_start( args, apFormat );

		vfprintf( pFormattedFd, apFormat, args );

		va_end( args );

		fclose( pFormattedFd );

		*this = pFormattedStr;
	}

#endif

	return *this;
}

CvString& CvString::TrimLeft( const String& aChars )
{
	size_t found = find_first_not_of( aChars );

	if ( found != npos )
		erase(0,found);
	else
		clear();
    
    return *this;
}

CvString& CvString::TrimRight( const String& aChars )
{
	size_t found = find_last_not_of( aChars );

	if ( found != npos )
		erase(found+1);
	else
		clear();
    
    return *this;
}

int CvString::ReplaceAll( const String& aPattern, const String& aReplacement )
{
	if ( aPattern.empty() )
		return 0;

	size_t patternLen = aPattern.length();
	size_t replaceLen = aReplacement.length();
	int count = 0;
	
	size_t pos = find( aPattern );

	while ( pos != npos )
	{
		replace( pos, patternLen, aReplacement );
		++count;
		pos = find( aPattern, pos + replaceLen );
	}

	return count;
}

void CvString::Tokenize( const String& aDelimiters, OUT CStringVector& aTokens ) const
{
	aTokens.clear();

	size_t posStart = 0;
	size_t posEnd = find_first_of( aDelimiters );

	while ( posEnd != npos )
	{
		aTokens.push_back( substr( posStart, posEnd - posStart ) );
		
		posStart = find_first_not_of( aDelimiters, posEnd );
		
		if ( posStart != npos )
			posEnd = find_first_of( aDelimiters, posStart );
		else
			posEnd = npos;
	}
	
	if ( posStart != npos )
	{
		aTokens.push_back( substr( posStart ) );		
	}
}

using namespace std;

wstring StringToWstring( const string& str )
{
#ifdef _WIN32
	int n = (int)str.size();
	wstring wstr( n+1, L'\0' );
	MultiByteToWideChar( CP_UTF8, 0, str.c_str(), -1, (LPWSTR)wstr.data(), n+1 );
	wstr.resize( n );
	return wstr;
#else
	return wstring( str.begin(), str.end() );
#endif
}

string WstringToString( const wstring& wstr )
{
#ifdef _WIN32	
	int n = (int)wstr.size();
	string str( n+1, '\0' );
	WideCharToMultiByte( CP_ACP, 0, wstr.c_str(), -1, (LPSTR)str.data(), n+1, NULL, NULL );
	str.resize( n );
	return str;
#else
	return string( wstr.begin(), wstr.end() );	
#endif
}


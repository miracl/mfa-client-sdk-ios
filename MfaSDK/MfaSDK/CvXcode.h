#ifndef CVXCODE_H
#define	CVXCODE_H

#include "CvCommon.h"

#include <string>

namespace CvShared
{
	namespace CvBase64
	{
		void Encode( const uint8_t* apBytesToEncode, int aLen, OUT std::string& aTarget );
		void Decode( const std::string& aSource, OUT std::string& aTarget );
	}
	
	namespace CvHex
	{
		void Encode( const uint8_t* apBytesToEncode, int aLen, OUT std::string& aTarget );
		void Decode( const std::string& aSource, OUT std::string& aTarget );
	}
}

#endif	/* CVXCODE_H */


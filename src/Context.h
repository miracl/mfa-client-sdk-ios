#ifndef CONTEXT_H_
#define CONTEXT_H_

#include "def.h"
#include <MpinCoreLib/mpin_sdk_base.h>

namespace sdk_non_tee {

class Context: public MPinSDKBase::IContext {
public:
	static Context* Instance();
	virtual IHttpRequest * CreateHttpRequest() const;
	virtual void ReleaseHttpRequest(IHttpRequest *request) const;
	virtual IStorage * GetStorage(IStorage::Type type) const;
	virtual CryptoType GetMPinCryptoType() const;
	virtual ~Context();
    
private:
	Context();
	Context(Context const&){};
	Context& operator=(Context const&){ return *this;};
    
    static Context* m_pInstance;
	IStorage * m_pIstorageSecure;
	IStorage * m_pIstorageNonSecure;
};

} /* namespace store */
#endif /* CONTEXT_H_ */

#include "Context.h"
#include "HTTPConnector.h"
#include "Storage.h"
#import "User.h"

namespace sdk_non_tee {
    
    typedef store::Storage Storage;
    typedef net::HTTPConnector HttpRequest;
    
    Context* Context::m_pInstance = NULL;

    Context * Context::Instance() {
        if(m_pInstance == NULL) {
            m_pInstance = new Context();
        }
        return m_pInstance;
    }
    
    Context::Context() {
        m_pIstorageSecure = new Storage(true);
        m_pIstorageNonSecure = new Storage(false);
    }
    
    IHttpRequest * Context::CreateHttpRequest() const{
        return new HttpRequest();
    }
    
    void Context::ReleaseHttpRequest(IHttpRequest *request) const {
        RELEASE(request)
    }
    
    IStorage * Context::GetStorage(IStorage::Type type) const {
        switch (type)
        {
            case MPinSDKBase::IStorage::SECURE:
                return m_pIstorageSecure;
            case MPinSDKBase::IStorage::NONSECURE:
                return m_pIstorageNonSecure;
            default:
                return NULL;
        }
    }
    
    CryptoType Context::GetMPinCryptoType() const {
        return MPinSDKBase::CRYPTO_NON_TEE;
    }
    
    Context::~Context() {
        RELEASE(m_pIstorageSecure)
        RELEASE(m_pIstorageNonSecure)
        RELEASE(m_pInstance)
    }
    
}

module speech.windows.sphelper;

import speech.windows.sapi;
import core.sys.windows.windows;
import std.c.windows.com;

HRESULT SpEnumTokens(const WCHAR* pszCategoryId, const WCHAR* pszReqAttribs, const WCHAR* pszOptAttribs, IEnumSpObjectTokens* ppEnum)
{
    HRESULT hr = S_OK;

    ISpObjectTokenCategory cpCategory;
    hr = SpGetCategoryFromId(pszCategoryId, &cpCategory);

    if(SUCCEEDED(hr))
    {
        hr = cpCategory.EnumTokens(pszReqAttribs, pszOptAttribs, ppEnum);
    }

    return hr;
}

HRESULT SpGetCategoryFromId(const WCHAR* pszCategoryId, ISpObjectTokenCategory* ppCategory, BOOL fCreateIfNotExist = FALSE)
{
    HRESULT hr;

    ISpObjectTokenCategory cpTokenCategory;
    hr = CoCreateInstance(&CLSID_SpObjectTokenCategory, null, CLSCTX_ALL, &IID_ISpObjectTokenCategory, &cpTokenCategory);

    if(SUCCEEDED(hr))
    {
        hr = cpTokenCategory.SetId(pszCategoryId, fCreateIfNotExist);
    }

    if(SUCCEEDED(hr))
    {
        *ppCategory = cpTokenCategory;
    }

    return hr;
}

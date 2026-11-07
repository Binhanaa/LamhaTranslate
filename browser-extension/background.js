const DEFAULT_SETTINGS = {
  isEnabled: true,
  targetLanguage: "ar",
  sourceLanguage: "auto",
  smartReverseTranslation: true,
  secondaryLanguage: "en",
  triggerMode: "icon_click", // "icon_click" | "icon_hover" | "instant"
  displayStyle: "glass_card", // "glass_card" | "in_place_compact"
  windowOpacity: 0.92,
  fontSize: 15
};

chrome.runtime.onInstalled.addListener(async () => {
  const existing = await chrome.storage.local.get(Object.keys(DEFAULT_SETTINGS));
  const merged = { ...DEFAULT_SETTINGS, ...existing };
  await chrome.storage.local.set(merged);

  chrome.contextMenus.create({
    id: "lamha-translate-selection",
    title: "ترجمة النص المحدد عبر لمحة",
    contexts: ["selection"]
  });
});

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId === "lamha-translate-selection" && tab?.id && info.selectionText) {
    try {
      await chrome.tabs.sendMessage(tab.id, {
        action: "triggerTranslationFromMenu",
        text: info.selectionText
      });
    } catch {
      // Content script might not be loaded on restricted chrome:// pages
    }
  }
});

function isPredominantlyArabic(text) {
  const letters = text.match(/\p{L}/gu) || [];
  if (letters.length === 0) return false;
  const arabicLetters = text.match(/[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/g) || [];
  return arabicLetters.length / letters.length > 0.5;
}

async function fetchGoogleTranslation(text, sourceLang, targetLang) {
  const params = new URLSearchParams({
    client: "gtx",
    sl: sourceLang,
    tl: targetLang,
    dt: "t",
    dj: "1",
    q: text
  });
  params.append("dt", "bd");

  const url = `https://translate.googleapis.com/translate_a/single?${params.toString()}`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  const data = await response.json();
  const sentences = Array.isArray(data.sentences) ? data.sentences : [];
  const translatedText = sentences.map((s) => s.trans || "").join("").trim();
  const detectedSource = data.src || sourceLang;
  const dict = Array.isArray(data.dict)
    ? data.dict.slice(0, 3).map((d) => ({
        pos: d.pos || "",
        terms: Array.isArray(d.terms) ? d.terms.slice(0, 5) : []
      }))
    : [];

  return {
    originalText: text,
    translatedText: translatedText || text,
    detectedSourceLanguage: detectedSource,
    targetLanguage: targetLang,
    dictionaryEntries: dict
  };
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.action === "translateText") {
    (async () => {
      try {
        const stored = await chrome.storage.local.get(Object.keys(DEFAULT_SETTINGS));
        const settings = { ...DEFAULT_SETTINGS, ...stored };
        const cleaned = (message.text || "").trim();
        let targetLang = message.targetLang || settings.targetLanguage;
        const sourceLang = settings.sourceLanguage || "auto";

        if (!message.targetLang && settings.smartReverseTranslation) {
          if (targetLang === "ar" && isPredominantlyArabic(cleaned)) {
            targetLang = settings.secondaryLanguage || "en";
          }
        }

        let result = await fetchGoogleTranslation(cleaned, sourceLang, targetLang);

        if (
          !message.targetLang &&
          settings.smartReverseTranslation &&
          result.detectedSourceLanguage.toLowerCase().startsWith(targetLang.toLowerCase()) &&
          (settings.secondaryLanguage || "en").toLowerCase() !== targetLang.toLowerCase()
        ) {
          result = await fetchGoogleTranslation(
            cleaned,
            result.detectedSourceLanguage,
            settings.secondaryLanguage || "en"
          );
        }

        sendResponse({ ok: true, result });
      } catch (error) {
        sendResponse({ ok: false, error: error?.message || "Translation failed" });
      }
    })();
    return true;
  }
});

document.addEventListener("DOMContentLoaded", async () => {
  const keys = [
    "isEnabled",
    "targetLanguage",
    "smartReverseTranslation",
    "secondaryLanguage",
    "triggerMode",
    "fontSize"
  ];

  const stored = await chrome.storage.local.get(keys);

  const isEnabledEl = document.getElementById("isEnabled");
  const targetLangEl = document.getElementById("targetLanguage");
  const smartRevEl = document.getElementById("smartReverseTranslation");
  const secLangEl = document.getElementById("secondaryLanguage");
  const triggerModeEl = document.getElementById("triggerMode");
  const fontSizeEl = document.getElementById("fontSize");
  const fontSizeValEl = document.getElementById("fontSizeVal");

  if (typeof stored.isEnabled === "boolean") isEnabledEl.checked = stored.isEnabled;
  if (stored.targetLanguage) targetLangEl.value = stored.targetLanguage;
  if (typeof stored.smartReverseTranslation === "boolean") smartRevEl.checked = stored.smartReverseTranslation;
  if (stored.secondaryLanguage) secLangEl.value = stored.secondaryLanguage;
  if (stored.triggerMode) triggerModeEl.value = stored.triggerMode;
  if (stored.fontSize) {
    fontSizeEl.value = stored.fontSize;
    fontSizeValEl.textContent = stored.fontSize;
  }

  isEnabledEl.addEventListener("change", () => {
    chrome.storage.local.set({ isEnabled: isEnabledEl.checked });
  });

  targetLangEl.addEventListener("change", () => {
    chrome.storage.local.set({ targetLanguage: targetLangEl.value });
  });

  smartRevEl.addEventListener("change", () => {
    chrome.storage.local.set({ smartReverseTranslation: smartRevEl.checked });
  });

  secLangEl.addEventListener("change", () => {
    chrome.storage.local.set({ secondaryLanguage: secLangEl.value });
  });

  triggerModeEl.addEventListener("change", () => {
    chrome.storage.local.set({ triggerMode: triggerModeEl.value });
  });

  fontSizeEl.addEventListener("input", () => {
    fontSizeValEl.textContent = fontSizeEl.value;
    chrome.storage.local.set({ fontSize: Number(fontSizeEl.value) });
  });
});

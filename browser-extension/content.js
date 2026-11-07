(() => {
  let currentSettings = {
    isEnabled: true,
    targetLanguage: "ar",
    sourceLanguage: "auto",
    smartReverseTranslation: true,
    secondaryLanguage: "en",
    triggerMode: "icon_click",
    windowOpacity: 0.94,
    fontSize: 15
  };

  let badgeEl = null;
  let popupEl = null;
  let selectedText = "";
  let lastMousePoint = { x: 100, y: 100 };
  let dismissTimer = null;

  async function loadSettings() {
    try {
      const stored = await chrome.storage.local.get(Object.keys(currentSettings));
      currentSettings = { ...currentSettings, ...stored };
    } catch {
      // Ignore in restricted frames
    }
  }

  loadSettings();

  chrome.storage.onChanged.addListener((changes) => {
    for (const [key, change] of Object.entries(changes)) {
      currentSettings[key] = change.newValue;
    }
  });

  chrome.runtime.onMessage.addListener((msg) => {
    if (msg?.action === "triggerTranslationFromMenu" && msg.text) {
      selectedText = msg.text.trim();
      showTranslationPopup(selectedText, lastMousePoint.x, lastMousePoint.y);
    }
  });

  function isSystemDarkMode() {
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
  }

  function removeBadge() {
    if (dismissTimer) {
      clearTimeout(dismissTimer);
      dismissTimer = null;
    }
    if (badgeEl) {
      badgeEl.remove();
      badgeEl = null;
    }
  }

  function removePopup() {
    if (popupEl) {
      popupEl.remove();
      popupEl = null;
    }
  }

  function clampPosition(x, y, width, height) {
    const pad = 10;
    const clampedX = Math.max(pad, Math.min(x, window.innerWidth - width - pad));
    const clampedY = Math.max(pad, Math.min(y, window.innerHeight - height - pad));
    return { x: clampedX, y: clampedY };
  }

  function createTriggerBadge(x, y) {
    removeBadge();

    badgeEl = document.createElement("button");
    badgeEl.id = "lamha-trigger-badge";
    if (!isSystemDarkMode()) {
      badgeEl.classList.add("lamha-light-surface");
    }
    badgeEl.title = "Translate selection (Lamha)";

    const svgNS = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(svgNS, "svg");
    svg.setAttribute("viewBox", "0 0 24 24");
    const path = document.createElementNS(svgNS, "path");
    path.setAttribute(
      "d",
      "M12.87 15.07l-2.54-2.51.03-.03A17.52 17.52 0 0014.07 6H17V4h-7V2H8v2H1v2h11.17C11.5 7.92 10.44 9.75 9 11.35 8.07 10.32 7.3 9.19 6.69 8h-2c.73 1.63 1.73 3.17 2.98 4.56l-5.09 5.02L4 19l5-5 3.11 3.11.76-2.04zM18.5 10h-2L12 22h2l1.12-3h4.75L21 22h2l-4.5-12zm-2.62 7l1.62-4.33L19.12 17h-3.24z"
    );
    svg.appendChild(path);
    badgeEl.appendChild(svg);

    const pos = clampPosition(x + 12, y - 36, 30, 30);
    badgeEl.style.left = `${pos.x}px`;
    badgeEl.style.top = `${pos.y}px`;

    badgeEl.addEventListener("mousedown", (e) => {
      e.preventDefault();
      e.stopPropagation();
    });

    badgeEl.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const text = selectedText;
      removeBadge();
      showTranslationPopup(text, x, y);
    });

    if (currentSettings.triggerMode === "icon_hover") {
      badgeEl.addEventListener("mouseenter", () => {
        const text = selectedText;
        removeBadge();
        showTranslationPopup(text, x, y);
      });
    }

    document.documentElement.appendChild(badgeEl);

    dismissTimer = setTimeout(() => {
      removeBadge();
    }, 4000);
  }

  async function showTranslationPopup(text, x, y) {
    removeBadge();
    removePopup();

    popupEl = document.createElement("div");
    popupEl.id = "lamha-popup-card";
    if (!isSystemDarkMode()) {
      popupEl.classList.add("lamha-light-surface");
    }

    const pos = clampPosition(x - 40, y + 16, 360, 140);
    popupEl.style.left = `${pos.x}px`;
    popupEl.style.top = `${pos.y}px`;

    const loadingEl = document.createElement("div");
    loadingEl.className = "lamha-body";
    loadingEl.style.fontSize = "13px";
    loadingEl.textContent = "Translating...";
    popupEl.appendChild(loadingEl);

    popupEl.addEventListener("mousedown", (e) => e.stopPropagation());
    document.documentElement.appendChild(popupEl);

    try {
      const response = await chrome.runtime.sendMessage({
        action: "translateText",
        text
      });

      if (!popupEl) return;
      popupEl.replaceChildren();

      if (!response?.ok || !response.result) {
        const errDiv = document.createElement("div");
        errDiv.className = "lamha-body";
        errDiv.textContent = "Could not connect to translation service.";
        popupEl.appendChild(errDiv);
        return;
      }

      const { translatedText, detectedSourceLanguage, targetLanguage, dictionaryEntries } = response.result;
      const isRTL = /^(ar|fa|ur|he)/i.test(targetLanguage);

      const header = document.createElement("div");
      header.className = "lamha-header";

      const actionsGroup = document.createElement("div");
      actionsGroup.className = "lamha-actions";

      const closeBtn = document.createElement("button");
      closeBtn.className = "lamha-icon-btn";
      closeBtn.title = "Close (Esc)";
      closeBtn.textContent = "✕";
      closeBtn.addEventListener("click", removePopup);

      const speakBtn = document.createElement("button");
      speakBtn.className = "lamha-icon-btn";
      speakBtn.title = "Listen";
      speakBtn.textContent = "🔊";
      speakBtn.addEventListener("click", () => {
        const utterance = new SpeechSynthesisUtterance(translatedText);
        utterance.lang = targetLanguage;
        window.speechSynthesis.cancel();
        window.speechSynthesis.speak(utterance);
      });

      const copyBtn = document.createElement("button");
      copyBtn.className = "lamha-icon-btn";
      copyBtn.title = "Copy translation";
      copyBtn.textContent = "📋";
      copyBtn.addEventListener("click", async () => {
        await navigator.clipboard.writeText(translatedText);
        copyBtn.textContent = "✓";
      });

      actionsGroup.appendChild(closeBtn);
      actionsGroup.appendChild(speakBtn);
      actionsGroup.appendChild(copyBtn);

      const flagMap = {
        ar: "🇸🇦", en: "🇺🇸", fr: "🇫🇷", es: "🇪🇸", de: "🇩🇪", tr: "🇹🇷",
        ru: "🇷🇺", "zh-cn": "🇨🇳", ja: "🇯🇵", ko: "🇰🇷", it: "🇮🇹",
        pt: "🇵🇹", nl: "🇳🇱", hi: "🇮🇳", ur: "🇵🇰", fa: "🇮🇷"
      };
      const flagCircle = document.createElement("span");
      flagCircle.className = "lamha-icon-btn";
      flagCircle.style.fontSize = "13px";
      flagCircle.title = `${detectedSourceLanguage.toUpperCase()} → ${targetLanguage.toUpperCase()}`;
      flagCircle.textContent = flagMap[(targetLanguage || "ar").toLowerCase()] || "🌐";

      header.appendChild(actionsGroup);
      header.appendChild(flagCircle);

      const body = document.createElement("div");
      body.className = "lamha-body";
      body.dir = isRTL ? "rtl" : "ltr";
      body.style.direction = isRTL ? "rtl" : "ltr";
      body.style.textAlign = isRTL ? "right" : "left";
      body.style.fontSize = `${currentSettings.fontSize || 15}px`;
      body.textContent = isRTL ? `\u200F${translatedText}` : translatedText;

      if (Array.isArray(dictionaryEntries) && dictionaryEntries.length > 0) {
        const dictContainer = document.createElement("div");
        dictContainer.className = "lamha-dict";
        dictContainer.dir = isRTL ? "rtl" : "ltr";
        for (const item of dictionaryEntries) {
          const line = document.createElement("div");
          line.textContent = `• ${item.pos ? `[${item.pos}] ` : ""}${item.terms.join(", ")}`;
          dictContainer.appendChild(line);
        }
        body.appendChild(dictContainer);
      }

      popupEl.appendChild(header);
      popupEl.appendChild(body);
    } catch {
      if (popupEl) {
        popupEl.textContent = "Translation error.";
      }
    }
  }

  document.addEventListener("mousedown", (e) => {
    if (badgeEl && !badgeEl.contains(e.target)) {
      removeBadge();
    }
    if (popupEl && !popupEl.contains(e.target)) {
      removePopup();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      removeBadge();
      removePopup();
    }
  });

  document.addEventListener("mouseup", (e) => {
    if (!currentSettings.isEnabled) return;
    if ((badgeEl && badgeEl.contains(e.target)) || (popupEl && popupEl.contains(e.target))) {
      return;
    }

    lastMousePoint = { x: e.clientX, y: e.clientY };

    setTimeout(() => {
      const sel = window.getSelection();
      const text = sel ? sel.toString().trim() : "";
      if (!text || text.length < 1 || text.length > 3500 || !/\p{L}/u.test(text)) {
        return;
      }

      selectedText = text;

      if (currentSettings.triggerMode === "instant") {
        showTranslationPopup(selectedText, e.clientX, e.clientY);
      } else {
        createTriggerBadge(e.clientX, e.clientY);
      }
    }, 15);
  });
})();

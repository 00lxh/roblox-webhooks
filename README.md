# 📦 WebhookService (Roblox)

<p align="center">
  <img src="https://img.shields.io/badge/Roblox-Library-red?style=for-the-badge&logo=roblox">
  <img src="https://img.shields.io/badge/Webhooks-Discord-blue?style=for-the-badge&logo=discord">
  <img src="https://img.shields.io/badge/Status-Stable-green?style=for-the-badge">
  <img src="https://img.shields.io/badge/License-Protected-orange?style=for-the-badge">
</p>

---

## 📖 Introduction

**WebhookService** is a universal system designed to simplify the use of webhooks between **Discord and Roblox** in a clean, fast, and easy-to-use way.

It provides a structured and powerful API with built-in validation, event handling, and reusable embed presets.

---

## 📑 Table of Contents

- Installation
- Basic Usage
- Documentation
- Events (Binds)
- Presets
- Important Notes
- License

---

## ⚙️ Installation

```lua
local WebhookService = loadstring(game:HttpGet("https://raw.githubusercontent.com/00lxh/roblox-webhooks/main/source.lua"))();
```

---

## 🚀 Basic Usage

```lua
local webhook = WebhookService.new();

webhook
    :SetURL("YOUR_WEBHOOK_URL")
    :SetAvatar({
        username = "Bot",
        avatar_url = "https://example.com/avatar.png"
    })

webhook:SendMessage("Hello world");
```

---

## 📚 Documentation

### WebhookService.new

Creates a new webhook instance.

```lua
local webhook = WebhookService.new();
```

---

### SetURL

Sets the webhook URL.

```lua
webhook:SetURL("https://discord.com/api/webhooks/...");
```

---

### SetCustomProxy

```lua
webhook:SetCustomProxy("my-proxy.com");
```

---

### SetPreset

```lua
webhook:SetPreset("kick");
```

---

### SetAvatar

```lua
webhook:SetAvatar({
    username = "My Bot",
    avatar_url = "https://img.com/avatar.png"
});
```

---

### SendMessage

```lua
webhook:SendMessage("Hello from Roblox");
```

---

### SendEmbed

```lua
webhook:SendEmbed({
    description = "Hello from Roblox"
});
```

---

### AddLinkButton

```lua
local button = webhook:AddLinkButton("Open", "https://google.com");
```

---

### BindEvent

```lua
webhook:BindEvent("OnMessageSend", function(data)
    print("Message sent");
end);
```

---

### UnbindEvent

```lua
webhook:UnbindEvent("OnMessageSend");
```

---

### Destroy

```lua
webhook:Destroy();
```

---

### GetWebhook

```lua
local self = webhook:GetWebhook();
```

---

## 🔔 Events (Binds)

### OnChanged

Triggered when:
- Preset changes
- Username changes
- Avatar changes
- Proxy changes

Data:
(type, property, value)

---

### OnMessageSend

Triggered when:
- SendMessage is called

Data:
data

---

### OnEmbedSend

Triggered when:
- SendEmbed is called

Data:
embed

---

## 🎨 Presets

### kick

```lua
webhook:SetPreset("kick");
webhook:SendEmbed(player, "Exploiting");
```

Includes:
- Player info
- Account age
- Server info
- Red color
- Timestamp

---

### Log

```lua
webhook:SetPreset("Log");
webhook:SendEmbed(player, "Action performed");
```

Includes:
- Player info
- Server info
- Message
- Orange color

---

## ⚠️ Important Notes

- SetURL is required
- Requires request support
- Uses proxy automatically
- Presets override SendEmbed

---

## 📜 License

IMPORTANT

- Do not redistribute without credit
- No commercial use without permission
- Must keep attribution

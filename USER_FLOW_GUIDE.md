# 📲 QR Scanner - Complete User Flow Guide

## User Flows

### Flow 1: Scan QR Code
```
┌────────────────────────────────────────┐
│   QR Scanner Screen                    │
│   ✓ Point camera at QR code            │
│   📸 Scanning: ON                      │
├────────────────────────────────────────┤
│   [Enter Code Manually]  [Copy Sample] │
└────────────────────────────────────────┘
           ↓ (Barcode detected)
┌────────────────────────────────────────┐
│   Processing...                        │
│   (CircularProgressIndicator)          │
└────────────────────────────────────────┘
           ↓ (Equipment found)
┌────────────────────────────────────────┐
│   Equipment Detail Screen              │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│   Basketball                           │
│   ID: EQ-0001                          │
│   Category: Ball Sports                │
│   Status: Available                    │
│                                        │
│   [Issue Equipment]                    │
└────────────────────────────────────────┘
           ↓ (Button click)
┌────────────────────────────────────────┐
│   Equipment updated: Borrowed          │
│   (Snackbar notification)              │
└────────────────────────────────────────┘
           ↓ (Back button / navigation back)
┌────────────────────────────────────────┐
│   QR Scanner Screen                    │
│   ✓ Resume scanning                    │
└────────────────────────────────────────┘
```

### Flow 2: Manual Code Entry
```
┌────────────────────────────────────────┐
│   QR Scanner Screen                    │
│   ✓ Point camera at QR code            │
│   📸 Scanning: ON                      │
├────────────────────────────────────────┤
│   [Enter Code Manually]  [Copy Sample] │
└────────────────────────────────────────┘
           ↓ (Tap "Enter Code Manually")
┌────────────────────────────────────────┐
│   ▲ Enter QR code or equipment id      │
│   ┌──────────────────────────────────┐ │
│   │ [Enter equipment code...]        │ │
│   └──────────────────────────────────┘ │
│                                        │
│   [Cancel]               [Lookup]      │
└────────────────────────────────────────┘
           ↓ (Type: EQ-0001 and tap Lookup)
┌────────────────────────────────────────┐
│   Processing...                        │
└────────────────────────────────────────┘
           ↓ (Equipment found)
┌────────────────────────────────────────┐
│   Equipment Detail Screen              │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│   Basketball                           │
│   ID: EQ-0001                          │
│   Category: Ball Sports                │
│   Status: Available                    │
│                                        │
│   [Issue Equipment]                    │
└────────────────────────────────────────┘
```

### Flow 3: Not Found
```
Scan QR / Enter Code Manually
      ↓
  Processing...
      ↓
  Equipment NOT FOUND
      ↓
┌────────────────────────────────────────┐
│   ✗ No equipment found for that code   │
│   (Snackbar notification)              │
└────────────────────────────────────────┘
      ↓
  Resume Scanning
```

---

## 🎯 Key Features

### Scanner Screen Features
- **Live Camera Feed** - Real-time QR scanning
- **Torch Toggle** - Flash light icon in AppBar
- **Close Button** - Exit scanner
- **Manual Entry** - Fallback if camera unavailable
- **Copy Sample QR** - For testing with generated QR codes
- **Status Display** - Shows "Scanning: ON" or "Scanning: OFF"

### Detail Screen Features
- **Full Equipment Info**
  - Equipment name (headline)
  - Equipment ID (EQ-0001)
  - Category (Ball Sports, Racket Sports, etc.)
  - Status (Available or Borrowed)

- **Action Buttons**
  - If Available: "Issue Equipment" → Changes status to Borrowed
  - If Borrowed: "Return Equipment" → Changes status to Available

- **Real-time Updates**
  - Status updates immediately in Firestore
  - No need to refresh
  - Back button returns to scanner

---

## 💾 Data Persistence

### Firestore Collection: `equipment`

**Example Document:**
```json
{
  "equipmentId": "EQ-0001",
  "name": "Basketball",
  "category": "Ball Sports",
  "quantity": 10,
  "status": "Available",
  "description": "Official size basketball for training",
  "qrCodeValue": "{\"equipmentId\":\"EQ-0001\",\"v\":1,\"ts\":0}",
  "createdAt": "2026-02-26T10:30:00Z",
  "updatedAt": "2026-02-26T10:35:00Z"
}
```

**Fields:**
- `equipmentId` - Unique identifier (used for lookups)
- `name` - Display name
- `category` - Equipment category
- `quantity` - Total items in inventory
- `status` - "Available" or "Borrowed"
- `qrCodeValue` - JSON for QR scanning
- `createdAt`, `updatedAt` - Timestamps

---

## 🔍 Search & Lookup Logic

When user scans or enters a code, the app searches for equipment in this order:

1. **Local Cache** - Check loaded equipment list first (fast)
2. **By equipmentId** - Query: `equipmentId == "EQ-0001"`
3. **By qrCodeValue** - Query: `qrCodeValue == "...json..."`
4. **By Document ID** - Match Firestore doc ID directly

This multi-level lookup ensures maximum compatibility.

---

## ⚙️ Demo Equipment IDs

For testing, use any of these equipment IDs:

- `EQ-0001` → Basketball
- `EQ-0002` → Soccer Ball
- `EQ-0003` → Tennis Racket
- `EQ-0004` → Badminton Shuttle
- `EQ-0005` → Volleyball
- `EQ-0006` → Cricket Bat
- `EQ-0007` → Yoga Mat
- `EQ-0008` → Dumbbells Set

Or paste full QR payload:
```
{"equipmentId":"EQ-0001","v":1,"ts":0}
```

---

## 🧪 Testing Checklist

- [ ] Seed demo equipment via cloud upload button
- [ ] Scan QR code with camera → Navigates to detail
- [ ] Enter equipment ID manually → Navigates to detail
- [ ] Click "Issue Equipment" → Status changes to Borrowed
- [ ] Click "Return Equipment" → Status changes to Available
- [ ] Back button → Resumes scanning
- [ ] Status persists after returning to scanner
- [ ] Firestore console shows status updates

---

## 📱 Device Requirements

- **Camera:** Required for QR scanning
- **Permissions:** Camera permission must be granted
- **Firebase:** Cloud Firestore collection "equipment" must exist
- **Authentication:** User must be logged in

---

## 🆘 Troubleshooting

**Q: Camera not working?**
A: Check camera permissions in app settings. Grant permission for camera access.

**Q: Equipment not found?**
A: Verify equipment exists in Firestore. Use cloud upload button to seed demo data.

**Q: Status not changing?**
A: Check Firebase connection. Ensure you have write permissions to Firestore.

**Q: Back button not responding?**
A: Use Android back gesture or tap the back arrow in AppBar.

**Q: Navigation not working?**
A: Ensure you're logged in. Check console for route errors.

---

## 📞 Support

For issues or questions:
1. Check Firestore console for collection existence
2. Review Flutter console for error messages
3. Verify Firebase authentication is working
4. Check device camera permissions
5. Test with demo equipment IDs

---

**Version:** Final 1.0  
**Status:** Production Ready ✅  
**Last Updated:** February 26, 2026

# Firestore Equipment Collection & QR Scanner Implementation

## 📋 Overview
The SportiQ application now includes a complete QR code scanning system integrated with Firestore's equipment collection. This guide documents the structure, demo data, and workflow.

---

## 🗄️ Firestore Collection Structure

### Collection: `equipment`
Stores all available sports equipment in the system.

#### Document Schema
```json
{
  "id": "auto_generated_by_firestore",
  "equipmentId": "EQ-0001",
  "name": "Basketball",
  "category": "Ball Sports",
  "quantity": 10,
  "status": "Available",
  "description": "Official size basketball for training and matches",
  "qrCodeValue": "{\"equipmentId\":\"EQ-0001\",\"v\":1,\"ts\":0}",
  "createdAt": "2026-02-23T10:30:00Z",
  "updatedAt": "2026-02-23T10:30:00Z"
}
```

#### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `id` | String (auto) | Firestore document ID |
| `equipmentId` | String | Unique identifier (e.g., EQ-0001) |
| `name` | String | Equipment display name |
| `category` | String | Category (Ball Sports, Racket Sports, Fitness, etc.) |
| `quantity` | Number | Total quantity available |
| `status` | String | Current status (Available, Borrowed) |
| `description` | String | Brief equipment description |
| `qrCodeValue` | String | JSON payload encoded in QR code |
| `createdAt` | Timestamp | Creation timestamp |
| `updatedAt` | Timestamp | Last update timestamp |

---

## 📦 Demo Equipment Data

The following equipment documents are seeded into Firestore:

### 1. Basketball (EQ-0001)
- **Status:** Available
- **Quantity:** 10
- **Category:** Ball Sports
- **Description:** Official size basketball for training and matches
- **QR Payload:** `{"equipmentId":"EQ-0001","v":1,"ts":0}`

### 2. Soccer Ball (EQ-0002)
- **Status:** Available
- **Quantity:** 15
- **Category:** Ball Sports
- **Description:** Professional soccer ball

### 3. Tennis Racket (EQ-0003)
- **Status:** Borrowed
- **Quantity:** 8
- **Category:** Racket Sports
- **Description:** Graphite tennis racket with grip

### 4. Badminton Shuttlecock (EQ-0004)
- **Status:** Available
- **Quantity:** 50
- **Category:** Racket Sports
- **Description:** Pack of 12 shuttlecocks

### 5. Volleyball (EQ-0005)
- **Status:** Available
- **Quantity:** 6
- **Category:** Ball Sports
- **Description:** Official volleyball for indoor use

### 6. Cricket Bat (EQ-0006)
- **Status:** Available
- **Quantity:** 5
- **Category:** Bat Sports
- **Description:** Wooden cricket bat for practice

### 7. Yoga Mat (EQ-0007)
- **Status:** Available
- **Quantity:** 20
- **Category:** Fitness
- **Description:** Non-slip yoga mat for fitness classes

### 8. Dumbbells Set (EQ-0008)
- **Status:** Borrowed
- **Quantity:** 3
- **Category:** Fitness
- **Description:** Set of adjustable dumbbells

---

## 🔄 Equipment Status Flow

```
Available ──────Issue──────> Borrowed
   ▲                             │
   │                             │
   └─────────Return─────────────┘
```

**Status Transitions:**
- **Available → Borrowed:** When a student issues/borrows equipment
- **Borrowed → Available:** When a student returns equipment

---

## 📸 Scanner Workflow & Screenshots

### Figure 1: QR Scanner Screen
**Location:** `/scan` route in the app

**UI Elements:**
- Live camera feed (top 80% of screen)
- Bottom card showing:
  - "Point camera at QR code" (idle state)
  - "Scanning: ON" status indicator
- Action buttons:
  - "Enter Code Manually" (outline button with edit icon)
  - "Copy Sample QR" (elevated button with QR code icon)
  - Cloud-upload icon (debug mode only - to seed data)

**Interaction Flow:**
```
User opens scanner
         ↓
   Points camera at QR code
         ↓
   App detects barcode (auto-focus)
         ↓
   Firestore lookup by:
   - equipmentId
   - qrCodeValue
   - document id
         ↓
   Equipment found?
   YES → Persistent card shown
   NO  → "No equipment found" snackbar
```

### Figure 2: Equipment Details Card (After Successful Scan)
**Display Location:** Bottom of scan screen (replaces idle card)

**Card Contents:**
```
┌─────────────────────────────────┐
│  Basketball                     │  ← Equipment name (bold, 18pt)
├─────────────────────────────────┤
│  ID: EQ-0001                    │
│  Category: Ball Sports          │
│  Status: Available              │
├─────────────────────────────────┤
│  [Issue Equipment]     [✕]      │  ← Status-based actions
└─────────────────────────────────┘
```

**Dynamic Buttons Based on Status:**
- **If Available:** Shows "Issue Equipment" button
- **If Borrowed:** Shows "Return Equipment" button
- **Close Button:** "✕" closes card and resumes scanning

**Actions:**
- Tap "Issue Equipment" → Updates Firestore status to "Borrowed"
- Tap "Return Equipment" → Updates Firestore status to "Available"
- Tap "✕" → Clears card, resumes scanning

---

## 🎯 Manual Code Entry Flow

**User Flow:**
1. Tap "Enter Code Manually" button
2. Dialog appears with text field
3. Paste or type:
   - Equipment ID: `EQ-0001`
   - QR Payload: `{"equipmentId":"EQ-0001","v":1,"ts":0}`
4. Tap "Lookup" button
5. If found:
   - Navigates to `/borrow_form` with equipment data
   - Student can complete the borrow workflow
6. If not found:
   - Shows "No equipment found for that code" snackbar
   - Resumes scanning

---

## 🔧 Debug Features (Development Only)

### Seed Sample Equipment
**Button:** Cloud-upload icon in QR scanner (debug mode only)

**Function:** `seedSampleEquipment()`
- Creates/updates all 8 demo equipment documents in Firestore
- Logs to console on success/failure
- Shows snackbar with confirmation

**Accessible in:** Debug builds via `kDebugMode` check

### Copy Sample QR
**Button:** "Copy Sample QR" in scanner
- Copies `{"equipmentId":"EQ-0001","v":1,"ts":0}` to clipboard
- Use with external QR generator to create scannable image
- File: `sample_qr.png` (generated in project root)

---

## 📊 Firestore Collections Reference

### Collection: `equipment`
- **Auto-scaling:** Spark plan compatible
- **Indexes:** Uses simple field lookups (equipmentId, qrCodeValue)
- **Typical Read Cost:** 1-3 reads per scan operation

### Collection: `scan_history` (Auto-created)
- **Purpose:** Logs all scan events for audit trail
- **Fields:** equipmentId, scannedBy, rawValue, action, timestamp
- **Fields:** Useful for analytics and debugging

---

## 🧪 Testing Checklist

### Prerequisites
- [ ] Firebase project: `sportiq-824eb`
- [ ] Android/iOS permissions: CAMERA, POST_NOTIFICATIONS
- [ ] Flutter app running on Windows/Android/iOS

### Test Scenarios

**1. Scan via Camera**
- [ ] Tap "Scan Equipment" in student dashboard
- [ ] Allow camera permission
- [ ] Open `sample_qr.png` on another device
- [ ] Point camera at QR code
- [ ] Equipment card appears with details
- [ ] Tap "Issue Equipment"
- [ ] Status updates to "Borrowed" in Firestore
- [ ] Snackbar shows "Equipment updated: Borrowed"

**2. Manual Code Entry**
- [ ] Tap "Enter Code Manually"
- [ ] Type `EQ-0001`
- [ ] Tap "Lookup"
- [ ] Redirected to `/borrow_form`
- [ ] Complete borrow workflow

**3. Debug Seed**
- [ ] Open scanner in debug mode
- [ ] Tap cloud-upload icon
- [ ] Snackbar shows "Seeded sample equipment"
- [ ] Open Firebase Console
- [ ] Check `equipment` collection has 8 documents

**4. Return Equipment**
- [ ] Issue equipment (status → Borrowed)
- [ ] Scan same QR again
- [ ] Card shows "Return Equipment" button
- [ ] Tap "Return Equipment"
- [ ] Status updates to "Available" in Firestore

---

## 🚀 Integration Points

### Files Modified/Created
- `lib/features/equipment/qr_scanner_screen.dart` - Scanner UI with manual entry
- `lib/features/equipment/qr_payload.dart` - Payload generator utility
- `lib/features/equipment/dev_seed.dart` - Demo data seeding
- `lib/providers/equipment_provider.dart` - Firestore CRUD & lookups
- `sample_qr.png` - Scannable QR code image

### Dependencies
- `mobile_scanner` - Camera & QR detection
- `permission_handler` - Runtime permissions
- `cloud_firestore` - Firestore integration
- `provider` - State management
- `qrcode[pil]` - QR generation (Python utility)

---

## 📝 Notes

- All demo equipment is seeded with realistic statuses
- QR payloads include equipment ID and timestamp for future scalability
- Firestore stays within Spark plan limits (no complex queries)
- Scan history logged for audit and analytics
- Manual entry supports multiple lookup formats (ID, QR, payload)

---

**Last Updated:** February 23, 2026
**Firestore Project:** sportiq-824eb
**App Version:** LAB 9 - QR Scanner Implementation

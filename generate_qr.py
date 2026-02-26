import qrcode
import json

# Sample payload for equipment EQ-0001
payload = json.dumps({"equipmentId": "EQ-0001", "v": 1, "ts": 0})

# Generate QR code
qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr.add_data(payload)
qr.make(fit=True)

# Create image
img = qr.make_image(fill_color="black", back_color="white")

# Save to workspace
output_path = "sample_qr.png"
img.save(output_path)
print(f"✅ QR code generated: {output_path}")
print(f"📦 Payload: {payload}")

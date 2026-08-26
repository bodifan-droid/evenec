import qrcode
from qrcode.image.svg import SvgPathImage
from pathlib import Path

# Посилання тимчасово можна буде змінити після публікації GitHub
URL = "https://github.com/your-username/evenec/tree/main/playground/evenec-retail"

output = Path("assets/qr")
output.mkdir(parents=True, exist_ok=True)

img = qrcode.make(URL, image_factory=SvgPathImage)
img.save(output / "github-playground.svg")

print("✅ QR created:", output / "github-playground.svg")
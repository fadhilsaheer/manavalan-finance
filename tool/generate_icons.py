"""Generate native launcher/splash assets after `flutter test tool/render_icon_test.dart`.
Requires Pillow for build-time image resizing; the app itself has no Python dependency.
"""
import json
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
source = Image.open(root / 'assets/icon/app-icon.png').convert('RGBA')
opaque = Image.new('RGB', source.size, '#1e1e2e')
opaque.paste(source, mask=source.getchannel('A'))
opaque.save(root / 'assets/icon/app-icon.png')
for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
    opaque.resize((size, size), Image.Resampling.LANCZOS).save(root / f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
icons = root / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
for entry in json.loads((icons / 'Contents.json').read_text())['images']:
    if 'filename' in entry:
        size = round(float(entry['size'].split('x')[0]) * float(entry['scale'].rstrip('x')))
        opaque.resize((size, size), Image.Resampling.LANCZOS).save(icons / entry['filename'])
launch = root / 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
for suffix, size in [('', 96), ('@2x', 192), ('@3x', 288)]:
    opaque.resize((size, size), Image.Resampling.LANCZOS).save(launch / f'LaunchImage{suffix}.png')

#!/bin/bash
# TIFF output keeps a MakerNote whose offsets count from the start of the EXIF TIFF stream (Canon, Sony,
# Panasonic, old Nikon...): a JPEG with a hand-made Canon-style note, both byte orders, goes to .yaif then
# .tif, and the note's string offset must point at the string in the .tif. Python 3 only.
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d)
trap 'rm -rf $T' EXIT
fail=0
for o in '<' '>'; do
  python3 - "$o" $T/a.jpg <<'PY' || fail=1
import struct, sys
o, out = sys.argv[1], sys.argv[2]
p = lambda f, *a: struct.pack(o + f, *a)
make, model, typ = b'Canon\0', b'Canon EOS R6\0', b'Canon EOS R6 Type\0'
mn_off = 8 + 2 + 3 * 12 + 4 + 2 + 12 + 4 + len(make) + len(model)
mn_off += mn_off & 1
typ_off = mn_off + 2 + 12 + 4
mn = p('H', 1) + p('HHII', 6, 2, len(typ), typ_off) + p('I', 0) + typ
exif_off = 8 + 2 + 3 * 12 + 4
data = exif_off + 2 + 12 + 4
t = (b'II*\0' if o == '<' else b'MM\0*') + p('I', 8)
t += p('H', 3) + p('HHII', 271, 2, len(make), data) + p('HHII', 272, 2, len(model), data + len(make)) + p('HHII', 34665, 4, 1, exif_off) + p('I', 0)
t += p('H', 1) + p('HHII', 37500, 7, len(mn), mn_off) + p('I', 0) + make + model
t += b'\0' * (mn_off - len(t)) + mn
app = b'Exif\0\0' + t
j = open('test/corpus/photo_like.jpg', 'rb').read()
open(out, 'wb').write(j[:2] + b'\xff\xe1' + struct.pack('>H', len(app) + 2) + app + j[2:])
PY
  ./yaif encode $T/a.jpg $T/a.yaif -m lossless >/dev/null 2>&1 && ./yaif decode $T/a.yaif $T/a.tif >/dev/null 2>&1 || { echo "FAIL $o: yaif"; fail=1; continue; }
  python3 - "$o" $T/a.tif <<'PY' && echo "OK   maker note offsets ($o)" || { echo "FAIL maker note offsets ($o)"; fail=1; }
import struct, sys
o = sys.argv[1]; d = open(sys.argv[2], 'rb').read()
pos = d.find(b'Canon EOS R6 Type')
i = d.find(struct.pack(o + 'HHI', 6, 2, 18))
sys.exit(0 if pos > 0 and i > 0 and struct.unpack(o + 'I', d[i + 8:i + 12])[0] == pos else 1)
PY
done
exit $fail

#!/bin/bash
GAME=$1
REGION=$2

# Construct the filename: game_region (e.g., seasons_us, ages_jp)
FILENAME="${GAME}_${REGION}"

echo "Comparing to vanilla ROM MD5 checksum..."
if md5sum -c ${FILENAME}.md5 2>/dev/null; then
    exit 0
fi

# MD5 mismatch: do a bank-by-bank comparison with the reference ROM
GAME_CAP="$(echo "${GAME:0:1}" | tr '[:lower:]' '[:upper:]')${GAME:1}"
REGION_UP="$(echo "$REGION" | tr '[:lower:]' '[:upper:]')"
REFERENCE="../${GAME_CAP} ${REGION_UP} Reference.gbc"

if [ ! -f "$REFERENCE" ]; then
    echo "Reference ROM not found: $REFERENCE"
    exit 1
fi

python3 - "${FILENAME}.gbc" "$REFERENCE" <<'EOF'
import sys

BANK_SIZE = 0x4000
built_path, ref_path = sys.argv[1], sys.argv[2]

with open(built_path, 'rb') as f:
    built = f.read()
with open(ref_path, 'rb') as f:
    ref = f.read()

total_banks = len(ref) // BANK_SIZE
print()
print("Bank-by-bank comparison vs reference ROM:")
print("  Bank  | Match %   | Bytes matched")
print("--------|-----------|---------------")
total_matched = 0
total_bytes = total_banks * BANK_SIZE
for bank in range(total_banks):
    s = bank * BANK_SIZE
    e = s + BANK_SIZE
    b = built[s:e]
    r = ref[s:e]
    n = min(len(b), len(r))
    matched = sum(b[i] == r[i] for i in range(n))
    total_matched += matched
    pct = matched / BANK_SIZE * 100
    print(f"  {bank:02x}    | {pct:6.2f}%   | [{matched}/{BANK_SIZE}]")
print("--------|-----------|---------------")
total_pct = total_matched / total_bytes * 100
print(f"  Total | {total_pct:6.2f}%   | [{total_matched}/{total_bytes}]")
EOF

#!/bin/sh
# mock_run.sh — 沙箱测试 install.sh
# 用假命令模拟 apk/npm/wget/tar，验证 install.sh 逻辑正确性
set -eu

PASS_COUNT=0
FAIL_COUNT=0

assert() {
  if eval "$2"; then
    echo "PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL: $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    exit 1
  fi
}

# ── 创建临时目录 ──
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

LOG_DIR="$TMPDIR/logs"
mkdir -p "$TMPDIR/bin" "$LOG_DIR" "$TMPDIR/fakehome" "$TMPDIR/fakeprofiled"

# ── fake apk ──
cat > "$TMPDIR/bin/apk" << 'FAKEAPK'
#!/bin/sh
echo "apk $@" >> "$LOG_DIR/apk.log"
exit 0
FAKEAPK
chmod +x "$TMPDIR/bin/apk"

# ── fake npm ──
cat > "$TMPDIR/bin/npm" << 'FAKENPM'
#!/bin/sh
echo "npm $@" >> "$LOG_DIR/npm.log"
exit 0
FAKENPM
chmod +x "$TMPDIR/bin/npm"

# ── fake wget（输出合法 tar.gz 到 stdout）──
cat > "$TMPDIR/bin/wget" << 'FAKEWGET'
#!/bin/sh
echo "wget $@" >> "$LOG_DIR/wget.log"
TMPWGET=$(mktemp -d)
mkdir -p "$TMPWGET/pi-stepfun-main"
echo "dummy" > "$TMPWGET/pi-stepfun-main/dummy.txt"
tar cz -C "$TMPWGET" pi-stepfun-main
rm -rf "$TMPWGET"
FAKEWGET
chmod +x "$TMPDIR/bin/wget"

# ── fake tar（记录调用 + 创建 dummy 文件到目标目录）──
cat > "$TMPDIR/bin/tar" << 'FAKETAR'
#!/bin/sh
echo "tar $@" >> "$LOG_DIR/tar.log"
# 解析 -C 后面的目录参数，创建 dummy 文件以模拟解压成功
C_DIR=""
NEXT_C=0
for arg in "$@"; do
  if [ "$NEXT_C" = 1 ]; then
    C_DIR="$arg"
    NEXT_C=0
  fi
  case "$arg" in
    -C) NEXT_C=1 ;;
  esac
done
if [ -n "$C_DIR" ] && [ -d "$C_DIR" ]; then
  mkdir -p "$C_DIR"
  echo "dummy" > "$C_DIR/dummy.txt"
fi
exit 0
FAKETAR
chmod +x "$TMPDIR/bin/tar"

# ── 设置环境变量 ──
# 清理 PATH：去掉 nvm 等用户目录，只保留系统基础路径 + fake bin
# 确保 command -v pi 找不到已安装的 pi
export PATH="$TMPDIR/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOME="$TMPDIR/fakehome"
export PROFILE_D="$TMPDIR/fakeprofiled"
export STEPFUN_API_KEY=test123
export LOG_DIR

# ── 运行 install.sh ──
sh /Users/davidyao/project/pi-stepfun/install.sh
EXIT_CODE=$?

echo ""
echo "=== Assertions ==="

# 1. 退出码断言
assert "exit code is 0" "[ $EXIT_CODE -eq 0 ]"

# 2. apk 调用断言
assert "apk.log exists and has records" \
  "[ -f '$LOG_DIR/apk.log' ] && grep -q 'apk' '$LOG_DIR/apk.log'"

# 3. npm 调用断言
assert "npm.log exists and has records" \
  "[ -f '$LOG_DIR/npm.log' ] && grep -q 'npm' '$LOG_DIR/npm.log'"

# 4. Key 文件内容断言
assert "key file contains test123" \
  "[ -f '$PROFILE_D/stepfun_api_key.sh' ] && grep -q 'test123' '$PROFILE_D/stepfun_api_key.sh'"

# 5. Key 文件权限断言 (600)
FILE_MODE=$(stat -f '%Lp' "$PROFILE_D/stepfun_api_key.sh" 2>/dev/null || stat -c '%a' "$PROFILE_D/stepfun_api_key.sh" 2>/dev/null)
assert "key file permissions are 600 (got $FILE_MODE)" "[ '$FILE_MODE' = '600' ]"

# ── 汇总 ──
echo ""
echo "=== Results: $PASS_COUNT passed, $FAIL_COUNT failed ==="

# 清理由 trap 处理
exit $FAIL_COUNT

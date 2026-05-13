#!/bin/bash
# cxx_link_wrapper.sh - C++ 链接器包装脚本
#
# 在调用真正的 c++ 链接器之前，找到所有 CGO 生成的 _cgo_main.o 文件
#（包含 _main 符号的 .o 文件），将其中的 _main 重命名为 __cgo_dummy_main，
# 避免与 Go 运行时的 main() 产生重复符号错误。
#
# 用法：
#   go build -ldflags="-extld=/path/to/cxx_link_wrapper.sh" ...
# 或：
#   CXX_WRAPPER=/path/to/cxx_link_wrapper.sh go build ...

REAL_CXX="${REAL_CXX:-/usr/bin/c++}"
FIX_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIX_SCRIPT="${FIX_SCRIPT_DIR}/fix_cgo_main.py"

# 收集所有参数
args=("$@")

# 找到所有包含 _main 符号的 .o 文件（排除 go.o）
new_args=()
tmp_files=()

for arg in "${args[@]}"; do
    replaced=0
    if [[ "$arg" == *.o ]] && [[ "$arg" != *"go.o" ]]; then
        # 检查是否包含 _main 符号
        if nm "$arg" 2>/dev/null | grep -q " T _main"; then
            tmp_file=$(mktemp "${TMPDIR:-/tmp}/cxx_wrapper_XXXXXX.o")
            tmp_files+=("$tmp_file")
            python3 "$FIX_SCRIPT" "$arg" "$tmp_file" 2>/dev/null
            if [ $? -eq 0 ] && [ -f "$tmp_file" ]; then
                new_args+=("$tmp_file")
                replaced=1
            else
                rm -f "$tmp_file"
            fi
        fi
    fi
    if [ $replaced -eq 0 ]; then
        new_args+=("$arg")
    fi
done

# 调用真正的 c++ 链接器
"$REAL_CXX" "${new_args[@]}"
exit_code=$?

# 清理临时文件
for f in "${tmp_files[@]}"; do
    rm -f "$f"
done

exit $exit_code
